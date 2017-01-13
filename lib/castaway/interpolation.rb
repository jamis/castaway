module Castaway

  module Interpolation
    def self.lookup(options)
      _lookup_by_class(options) ||
        _lookup_by_type(options) ||
        raise(ArgumentError, "cannot find interpolation for #{value.inspect}")
    end

    def self._lookup_by_class(options)
      options[:interpolator]
    end

    def self._lookup_by_type(options)
      case options[:type]
      when :linear, nil then Castaway::Interpolation::Linear
      end
    end
  end

end

require 'castaway/interpolation/linear'
