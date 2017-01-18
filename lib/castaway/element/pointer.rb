require 'castaway/element/still'
require 'castaway/box'
require 'castaway/point'

module Castaway
  module Element

    class Pointer < Element::Still
      class HotspotDelta
        def initialize(pointer)
          @pointer = pointer
        end

        def [](t)
          @pointer.raw_position[t] - @pointer.hotspot_at(t)
        end
      end

      def initialize(production, scene, id)
        path, options = production.pointers.fetch(id)
        super(production, scene, path)

        @box = Box.from_size(@size)
        @box[:hotspot] = Castaway::Point.make(options[:hotspot] || [0, 0])

        ideal_width = production.resolution.width * options[:scale]
        sx = ideal_width.to_f / @size.width

        scale(sx)
      end

      def hotspot_at(t)
        @box.
          scale(scale[t]).
          rotate(rotate[t]).
          bounds[:hotspot]
      end

      alias raw_position position

      def position
        HotspotDelta.new(self)
      end
    end

  end
end
