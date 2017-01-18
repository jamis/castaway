module Castaway
  class Delta
    def self.[](value)
      new(0 => value)
    end

    def initialize(definition)
      @sorted_t = definition.keys.sort
      @sorted_v = @sorted_t.map { |t| definition[t] }
    end

    def [](t)
      return _reify(@sorted_v.first) if t < @sorted_t.first

      @sorted_t.each.with_index do |t1, idx|
        if t < (@sorted_t[idx + 1] || 0)
          t_span = @sorted_t[idx + 1] - t1
          ratio = (t - t1).to_f / t_span

          v1 = _reify(@sorted_v[idx])
          v2 = _reify(@sorted_v[idx + 1])

          v_span = v2 - v1
          return v1 + v_span * ratio
        end
      end

      _reify(@sorted_v.last)
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
