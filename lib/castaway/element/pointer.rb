require 'castaway/element/still'
require 'castaway/box'
require 'castaway/point'

module Castaway
  module Element

    class Pointer < Element::Still
      def initialize(production, scene, id)
        path, options = production.pointers.fetch(id)
        super(production, scene, path)

        @box = Box.from_size(@size)
        @box[:hotspot] = Castaway::Point.make(options[:hotspot] || [0, 0])

        ideal_width = production.resolution.width * options[:scale]
        sx = ideal_width.to_f / @size.width

        scale(sx)
      end

      def hotspot
        @box.
          scale(@scale || 0).
          rotate(@angle || 0).
          bounds[:hotspot]
      end

      def position
        @position - hotspot
      end
    end

  end
end
