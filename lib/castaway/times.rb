module Castaway
  module Times
    def _parse_time(spec)
      _parse_numeric_time(spec) ||
        _parse_timespec_time(spec) ||
        raise(ArgumentError, "unsupported time #{spec.inspect}")
    end

    def _parse_numeric_time(spec)
      if spec.is_a?(Numeric)
        spec
      elsif spec =~ /^\d+(\.\d+)?s?$/
        spec.to_f
      end
    end

    def _parse_timespec_time(spec)
      return unless spec =~ /^(\d+)(?::(\d+))?(?::(\d+))?(\.\d+)?$/

      a = Regexp.last_match(1)
      b = Regexp.last_match(2)
      c = Regexp.last_match(3)
      d = Regexp.last_match(4)

      time = [c, b, a].compact.each.with_index.reduce(0) do |m, (v, i)|
        m + v.to_i * 60**i
      end

      time += d.to_f if d
      time
    end
  end
end
