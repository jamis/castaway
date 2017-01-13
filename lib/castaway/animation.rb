require 'castaway/interpolation'

module Castaway

  class Animation
    attr_reader :from, :to, :duration

    def self.from_options(options)
      factory = Castaway::Interpolation.lookup(options)
      initial = options[:initial] || 0.0
      final = options[:final] || (initial + 1.0)
      interpolator = factory.new(initial, final)

      from  = options[:from] ||
              raise(ArgumentError, 'animations require `from` time')
      to    = options[:to] ||
              (options[:length] ? from + options[:length] : nil) ||
              raise(ArgumentError, 'animations require `to` or `length`')

      new(interpolator, from, to)
    end

    def initialize(interpolator, from, to)
      @interpolator = interpolator
      @from = from.to_f
      @to = to.to_f
      @duration = @to - @from
    end

    def [](t)
      # adjust t to 0..1
      adjusted_t = duration.zero? ? 1.0 : (t - from) / duration.to_f
      @interpolator[adjusted_t]
    end
  end

end
