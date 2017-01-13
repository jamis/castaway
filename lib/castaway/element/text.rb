require 'castaway/element/base'

module Castaway
  module Element

    class Text < Element::Base
      def initialize(production, scene, string)
        super(production, scene)

        @string = string
        @gravity = 'Center'
        @font = 'TimesNewRoman'
        @font_size = 24
        @background = 'transparent'
        @kerning = 0
        @fill = @stroke = nil

        attribute(:font_size, 1) { |memo, value| memo * value }
        attribute(:kerning, -> { @kerning }) { |memo, value| memo + value }
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

      def kerning(kerning)
        @kerning = kerning
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

      def font_size(size)
        @font_size = size
        self
      end

      def _prepare_canvas(t, canvas)
        canvas.xc @background

        font_size = @font_size * attributes[:font_size]
        kerning = attributes[:kerning]

        canvas.pointsize font_size

        commands = [ "gravity #{@gravity}", "font '#{@font}'" ]
        commands << "fill #{@fill}" if @fill
        commands << "stroke #{@stroke}" if @stroke
        commands << format('kerning %.1f', kerning) if kerning
        commands << "text 0,0 '#{@string}'"

        canvas.draw commands.join(' ')
      end
    end

  end
end
