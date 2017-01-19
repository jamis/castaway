require 'castaway/animation'
require 'castaway/delta'
require 'castaway/effect'
require 'castaway/embedded_audio'
require 'castaway/point'

module Castaway
  module Element

    class Base
      def self.declarative_accessor(*names)
        options = names.last.is_a?(Hash) ? names.pop : {}
        arg = if options[:converter]
                "#{options[:converter]}(arg)"
              else
                "arg"
              end

        names.each do |name|
          class_eval <<-RUBY, __FILE__, __LINE__+1
            def #{name}(arg = nil)
              if arg.nil?
                @#{name}
              else
                @#{name} = _argument_to_delta(#{arg})
                self
              end
            end
          RUBY
        end
      end

      class Tail < Struct.new(:owner, :amount)
        def to_f
          owner.duration - amount
        end

        alias reify to_f
      end

      attr_reader :production, :scene
      attr_reader :position, :size

      declarative_accessor :scale, :rotate, :alpha

      def initialize(production, scene)
        @production = production
        @scene = scene

        @enter = 0
        @exit = scene.duration
        @size = production.resolution

        @position = Castaway::Delta[Castaway::Point.new(0, 0)]
        @scale    = Castaway::Delta[1]
        @rotate   = Castaway::Delta[0]
        @alpha    = Castaway::Delta[1]
      end

      # `t` is relative to the beginning of the production
      def alive_at?(t)
        t.between?(t1, t2)
      end

      # Return start time for this element, relative to the beginning of the
      # production.
      def t1
        _absolute(enter)
      end

      # Return exit time for this element, relative to the beginning of the
      # production.
      def t2
        _absolute(exit)
      end

      # Specify or return the start time for this element, relative to the
      # beginning of the scene.
      def enter(t = nil)
        if t
          @enter = _convert(t)
          self
        else
          @enter
        end
      end

      # Specify or return the exit time for this element, relative to the
      # beginning of the scene.
      def exit(t = nil)
        if t
          @exit = _convert(t)
          self
        else
          @exit
        end
      end

      def duration
        @exit - @enter
      end

      def at(*args)
        if args.length == 1
          _at_arity1(args.first)
        elsif args.length == 2
          _at_arity2(*args)
        else
          raise ArgumentError, 'expected 1 or 2 arguments to #at'
        end

        self
      end

      def _argument_to_delta(arg)
        if arg.is_a?(Hash)
          Castaway::Delta.new(arg)
        elsif arg.is_a?(Castaway::Delta)
          arg
        else
          Castaway::Delta[arg]
        end
      end

      def _at_arity1(arg)
        @position = _argument_to_delta(arg)
      end

      def _at_arity2(x, y)
        @position = Castaway::Delta[Castaway::Point.new(x, y)]
      end

      def gravity(specification)
        s = size

        left = 0
        hcenter = (production.resolution.width - s.width) / 2.0
        right = production.resolution.width - s.width

        top = 0
        vcenter = (production.resolution.height - s.height) / 2.0
        bottom = production.resolution.height - s.height

        x, y = case specification
          when :northwest then [left,    top    ]
          when :north     then [hcenter, top    ]
          when :northeast then [right,   top    ]
          when :west      then [left,    vcenter]
          when :center    then [hcenter, vcenter]
          when :east      then [right,   vcenter]
          when :southwest then [left,    bottom ]
          when :south     then [hcenter, bottom ]
          when :southeast then [right,   bottom ]
          else
            raise ArgumentError, "invalid gravity #{specification.inspect}"
          end

        at(x, y)
      end

      def size(*args)
        if args.empty?
          @size
        elsif args.length == 2
          width, height = args
          @size = if width.nil?
                    @size.with_height(height)
                  elsif height.nil?
                    @size.with_width(width)
                  else
                    Castaway::Size.new(width, height)
                  end
          self
        else
          raise ArgumentError, 'expected 0 or 2 arguments to #size'
        end
      end

      def in(type, options = {})
        effect(:"#{type}_in", options)
      end

      def out(type, options = {})
        effect(:"#{type}_out", options)
      end

      def effect(type, options = {})
        Castaway::Effect.invoke(type, self, options)
        self
      end

      def path(points)
        warn '#path is deprecated -- use #at with Hash instead'
        at(points)
      end

      def play(sound, after: 0, duration: nil)
        audio = Castaway::EmbeddedAudio.new(sound, self, after, duration)
        production.embedded_clips << audio
        self
      end

      def tail(value = 0.0)
        Tail.new(self, value)
      end

      # `t` is the global time value, relative to the beginning of the
      # production.
      def render_at(t, canvas)
        relative_t = t - t1

        alpha = self.alpha[relative_t]
        scale = self.scale[relative_t]

        return if alpha <= 0.0 || scale.abs <= 0.001

        size     = self.size
        position = self.position[relative_t]
        rotate   = self.rotate[relative_t]

        canvas.stack do |stack|
          _prepare_canvas(relative_t, stack)
          stack.geometry size.to_geometry
          _transform(stack, scale, rotate)
          stack.geometry position.to_geometry unless position.zero?
        end

        _composite(canvas, alpha)
      end

      def _transform(canvas, scale, angle)
        return unless scale != 1 || angle != 0

        canvas.virtual_pixel 'transparent'

        distort = "#{scale} #{angle}"
        canvas.distort.+('ScaleRotateTranslate', distort)
      end

      def _composite(canvas, alpha)
        if alpha < 0.99995 # the point where %.2f rounds alpha*100 to 100
          canvas.compose 'blend'
          canvas.define format('compose:args=%.2f', alpha * 100)
        else
          canvas.compose 'src-over'
        end

        canvas.composite
      end

      def _absolute(t)
        scene.start + t
      end

      def _convert(t)
        t && t.to_f
      end
    end

  end
end
