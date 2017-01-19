module Castaway
  class Delta
    def self.[](value)
      new(0 => value)
    end

    def initialize(definition)
      @definition = definition
    end

    def [](t)
      sorted_t, sorted_v = _sorted
      return _reify(sorted_v.first) if t < sorted_t.first

      sorted_t.each.with_index do |t1, idx|
        t2 = _reify(sorted_t[idx + 1] || 0)

        if t < t2
          t1 = _reify(t1)

          t_span = t2 - t1
          ratio = (t - t1).to_f / t_span

          v1 = _reify(sorted_v[idx])
          v2 = _reify(sorted_v[idx + 1])

          v_span = v2 - v1
          return v1 + v_span * ratio
        end
      end

      _reify(sorted_v.last)
    end

    def _sorted
      @_sorted ||= begin
        sorted_t = @definition.keys.map { |t| _reify(t) }.sort
        sorted_v = sorted_t.map { |t| _reify(@definition[t]) }
        [ sorted_t, sorted_v ]
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
