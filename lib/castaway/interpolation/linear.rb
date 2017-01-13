module Castaway
  module Interpolation

    # A linear interpolation between two values
    class Linear
      attr_reader :start, :finish

      def initialize(start, finish)
        @start = start
        @finish = finish
        @delta = finish - start
      end

      def [](t)
        if t < 0
          @start
        elsif t > 1
          @finish
        else
          @delta * t + @start
        end
      end
    end

  end
end
