module Castaway
  class Delta
    class Leg
      attr_reader :initial, :final

      def initialize(t1, v1, t2, v2)
        @t1 = t1
        @t2 = t2
        @initial = v1
        @final = v2
        @duration = t2 - t1
        @distance = v2 - v1
      end

      def >(t)
        @t1 > t
      end

      def contains?(t)
        t.between?(@t1, @t2)
      end

      def at(t)
        ratio = (t - @t1).to_f / @duration
        @initial + @distance * ratio
      end
    end

    class ConstantLeg
      def initialize(v)
        @v = v
      end

      def >(_t)
        false
      end

      def contains?(_t)
        true
      end

      def at(_t)
        @v
      end
    end

    def self.[](value)
      new(0 => value)
    end

    def initialize(definition)
      @definition = definition
    end

    def [](t)
      return _legs.first.initial if _legs.first > t

      _legs.each do |leg|
        return leg.at(t) if leg.contains?(t)
      end

      _legs.last.final
    end

    def _legs
      @_legs ||= begin
        reified_t = @definition.keys.
                    map { |t| [t, _reify(t)] }.
                    sort_by(&:last)
        original_t = reified_t.map(&:first)
        sorted_t = reified_t.map(&:last)

        # we have to key off of the original (unreified) t,
        # because that's what the original definition has uses.
        sorted_v = original_t.map { |t| _reify(@definition[t]) }

        if sorted_t.length == 1
          [ ConstantLeg.new(sorted_v.first) ]
        else
          (0..(sorted_t.length - 2)).map do |idx|
            t1 = sorted_t[idx]
            t2 = sorted_t[idx + 1]
            v1 = sorted_v[idx]
            v2 = sorted_v[idx + 1]
            Leg.new(t1, v1, t2, v2)
          end
        end
      end
    end

    def _reify(value)
      if value.respond_to?(:reify)
        value.reify
      else
        value
      end
    end
  end
end
