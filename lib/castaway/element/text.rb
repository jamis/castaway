require 'castaway/element/base'

module Castaway
  module Element

    class Text < Element::Base
      declarative_accessor :font_size, :kerning

      def initialize(production, scene, string)
        super(production, scene)

        @string = string
        @gravity = 'Center'
        @font = 'TimesNewRoman'
        @font_size = Castaway::Delta[24]
        @background = 'transparent'
        @kerning = Castaway::Delta[0]
        @fill = @stroke = nil
      end

      def fill(color)
        @fill = color
        self
      end

      def stroke(color)
        @stroke = color
        self
      end

      def background(color)
        @background = color
        self
      end

      def gravity(gravity)
        @gravity = gravity
        self
      end

      def font(font)
        @font = font
        self
      end

      # `t` is the time value relative to the entrance of this element
      def _prepare_canvas(t, canvas)
        canvas.xc @background

        font_size = self.font_size[t]
        kerning = self.kerning[t]

        canvas.pointsize font_size

        commands = [ "gravity #{@gravity}", "font '#{@font}'" ]
        commands << "fill #{@fill}" if @fill
        commands << "stroke #{@stroke}" if @stroke
        commands << format('kerning %.1f', kerning) if kerning != 0
        commands << "text 0,0 '#{@string}'"

        canvas.draw commands.join(' ')
      end
    end

  end
end
