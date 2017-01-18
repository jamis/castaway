module Castaway
  class EmbeddedAudio
    attr_reader :source, :element, :delay

    def initialize(source, element, delay = 0, duration = nil)
      @source = source
      @source = element.production.resource(@source) if @source.is_a?(String)

      @element = element
      @delay = delay
      @duration = duration
    end

    def start
      @element.t1 + delay
    end

    def duration
      @duration || @element.duration
    end
  end
end
