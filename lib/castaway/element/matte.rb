require 'castaway/element/base'
require 'castaway/color'

module Castaway
  module Element

    class Matte < Element::Base
      declarative_accessor :color, converter: :_convert_color

      def initialize(production, scene, color = :black)
        super(production, scene)
        @color = Castaway::Delta[Castaway::Color.create(color)]
      end

      # `t` is a time value relative to the entrance of this element
      def _prepare_canvas(t, canvas)
        canvas.xc @color[t].to_imagemagick
      end

      def _convert_color(arg)
        Castaway::Color.create(arg)
      end
    end

  end
end
