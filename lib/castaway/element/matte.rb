require 'castaway/element/base'

module Castaway
  module Element

    class Matte < Element::Base
      attr_reader :color

      def initialize(production, scene, color)
        super(production, scene)
        @color = color
      end

      def _prepare_canvas(_t, canvas)
        canvas.xc @color
      end
    end

  end
end
