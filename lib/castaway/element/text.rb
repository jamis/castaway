require 'castaway/element/base'
require 'castaway/color'

module Castaway
  module Element

    class Text < Element::Base
      declarative_accessor :font_size, :kerning
      declarative_accessor :background, :fill, :stroke,
                           converter: :_convert_color

      def initialize(production, scene, string)
        super(production, scene)

        @string = string
        @gravity = 'Center'
        @font = 'TimesNewRoman'
        @font_size = Castaway::Delta[24]
        @background = Castaway::Delta[Castaway::Color.create(:transparent)]
        @kerning = Castaway::Delta[0]
        @fill = @stroke = nil
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
        canvas.xc @background[t].to_imagemagick

        kerning = self.kerning[t]
        fill = self.fill[t] if self.fill
        stroke = self.stroke[t] if self.stroke

        canvas.pointsize font_size[t]

        commands = [ "gravity #{@gravity}", "font '#{@font}'" ]
        commands << "fill #{fill.to_imagemagick}" if fill
        commands << "stroke #{stroke.to_imagemagick}" if stroke
        commands << format('kerning %.1f', kerning) if kerning != 0
        commands << "text 0,0 '#{@string}'"

        canvas.draw commands.join(' ')
      end

      def _convert_color(arg)
        Castaway::Color.create(arg)
      end
    end

  end
end
