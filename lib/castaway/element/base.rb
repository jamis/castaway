require 'castaway/animation'
require 'castaway/effect'
require 'castaway/point'

module Castaway
  module Element

    class Base
      attr_reader :production, :scene
      attr_reader :position, :size

      # reevaluated at each render, represents the value of the attributes at
      # the current point in time.
      attr_reader :attributes

      class Attribute < Struct.new(:_initial, :fn)
        def initial
          if _initial.respond_to?(:call)
            _initial.call
          else
            _initial
          end
        end

        def [](memo, value)
          fn[memo, value]
        end
      end

      class Tail < Struct.new(:owner, :amount)
        def to_f
          owner.duration - amount
        end
      end

      def initialize(production, scene)
        @production = production
        @scene = scene

        @enter = 0
        @exit = scene.duration
        @position = Castaway::Point.new(0, 0)
        @size = production.resolution

        @animations = Hash.new { |h, k| h[k] = [] }
        @attribute_defs = {}

        attribute(:alpha, 1.0) { |memo, value| memo * value }
        attribute(:position, -> { position }) { |memo, value| memo + value }
        attribute(:size, -> { @size }) { |memo, value| memo * value }
      end

      # `t` is relative to the beginning of the production
      def alive_at?(t)
        t.between?(t1, t2)
      end

      def attribute(name, initial, fn = nil, &block)
        @attribute_defs[name] = Attribute.new(initial, fn || block)
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
          @position = args.first
        elsif args.length == 2
          @position = Castaway::Point.new(args[0], args[1])
        else
          raise ArgumentError, 'expected 1 or 2 arguments to #at'
        end

        self
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

      def scale(scale)
        @scale = scale
        self
      end

      def rotate(angle)
        @angle = angle
        self
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

      def animate(attribute, options = {})
        options = options.dup
        %i( from to ).each { |a| options[a] = _convert(options[a]) }
        @animations[attribute] << Animation.from_options(options)
        self
      end

      def path(points)
        current = @position # not #position, which may give us a translated point
        prior_t = 0
        p0 = Castaway::Point.new(0, 0)

        points.keys.sort.each do |time|
          delta = points[time] - current

          animate(:position, type: :linear, from: prior_t, to: time,
                             initial: p0, final: delta)

          current = points[time]
          prior_t = time
        end
      end

      def tail(value = 0.0)
        Tail.new(self, value)
      end

      # `t` is the global time value, relative to the beginning of the
      # production.
      def render_at(t, canvas)
        _evaluate_attributes!(t)

        alpha    = attributes[:alpha] || 1.0
        size     = attributes[:size] || production.resolution
        position = attributes[:position] || Castaway::Point.new(0, 0)

        return if alpha <= 0.0 || size.empty?

        canvas.stack do |stack|
          _prepare_canvas(t, stack)
          stack.geometry size.to_geometry
          _transform(stack)
          stack.geometry position.to_geometry unless position.zero?
        end

        _composite(canvas, alpha)
      end

      def _transform(canvas)
        return unless @scale || @angle

        canvas.virtual_pixel 'transparent'

        distort = "#{@scale || '1'} #{@angle || '0'}"
        canvas.distort.+('ScaleRotateTranslate', distort.strip)
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

      def _evaluate_attributes!(t)
        @attributes = @attribute_defs.keys.each.with_object({}) do |type, map|
          list = @animations[type]
          map[type] = _evaluate_animation_list(type, t, list)
        end
      end

      def _evaluate_animation_list(type, t, list)
        list.reduce(@attribute_defs[type].initial) do |memo, animation|
          # animations are always specified relative to the "enter" time of
          # element they are attached to.
          relative_t = t - t1
          if relative_t < animation.from
            memo
          else
            result = animation[relative_t]
            @attribute_defs[type][memo, result]
          end
        end
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
