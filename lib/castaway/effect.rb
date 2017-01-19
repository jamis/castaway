module Castaway
  module Effect

    @effects = {}
    def self.register(name, &implementation)
      @effects[name] = implementation
    end

    def self.invoke(name, element, options)
      @effects.fetch(name).call(element, options)
    end

    register :dissolve_in do |element, options|
      element.alpha(0 => 0.0, options[:speed] => 1.0)
    end

    register :dissolve_out do |element, options|
      element.alpha(element.tail(options[:speed]) => 1.0, element.tail => 0.0)
    end

    register :pan do |element, options|
      dx = case options[:horizontal]
           when nil then 0
           when true, 1, :right then
             element.production.resolution.width - element.size.width
           when false, -1, :left then
             element.size.width - element.production.resolution.width
           else
             raise ArgumentError,
                   "unsupported horizontal: #{options[:horizontal].inspect}"
           end

      dy = case options[:vertical]
           when nil then 0
           when true, 1, :down then
             element.production.resolution.height - element.size.height
           when false, -1, :up then
             element.size.height - element.production.resolution.height
           else
             raise ArgumentError,
                   "unsupported vertical: #{options[:vertical].inspect}"
           end

      type = options[:type] || :linear
      from = options[:from] || 0.0
      to   = options[:to]   || element.duration

      p0 = Castaway::Point.new(0, 0)
      p1 = Castaway::Point.new(dx, dy)

      element.at(from => p0, to => p1)
    end
  end
end
