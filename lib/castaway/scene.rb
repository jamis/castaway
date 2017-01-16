require 'castaway/element/matte'
require 'castaway/element/still'
require 'castaway/element/pointer'
require 'castaway/element/text'
require 'castaway/relative_to'
require 'castaway/times'

module Castaway
  class Scene
    include Castaway::Times

    attr_reader :title
    attr_reader :production

    attr_reader :finish, :duration

    attr_reader :_timeline

    def initialize(title, production)
      @title = title
      @production = production
    end

    def configure(&block)
      instance_eval(&block)
      self
    end

    def start(value = nil)
      return @start unless value
      @start = _parse_time(value)
    end

    def time(value)
      _parse_time(value)
    end

    def relative_to_image(name)
      RelativeTo.new(name, production)
    end

    def script(*args)
      if args.empty?
        @script
      elsif args.length == 1
        @script = _strip(args.first)
      else
        raise ArgumentError, 'script expects 0 or 1 argument'
      end
    end

    def plan(&block)
      @plan = block
    end

    def construct(timeline)
      @_timeline = timeline
      instance_eval(&@plan) if @plan
    ensure
      remove_instance_variable :@_timeline
    end

    def matte(color)
      Element::Matte.new(production, self, color).tap do |element|
        _timeline.add(element)
      end
    end

    def still(filename)
      _still(filename, true)
    end

    def sprite(filename)
      _still(filename, false)
    end

    def pointer(id = :default)
      Element::Pointer.new(production, self, id).tap do |pointer|
        _timeline.add(pointer)
      end
    end

    def text(string)
      Element::Text.new(production, self, string).tap do |text|
        _timeline.add(text)
      end
    end

    def update_from_next(neighbor)
      @finish = neighbor.nil? ? @start : neighbor.start
      @duration = @finish - @start
    end

    def relative_position(x, y)
      Castaway::Point.new(x, y) * production.resolution
    end

    def _still(filename, full)
      Element::Still.new(production, self, filename, full: full).
        tap do |element|
          _timeline.add(element)
        end
    end

    def _strip(text)
      if text =~ /^(\s+)\S/
        indent = Regexp.last_match(1)
        text.gsub(/^#{indent}/, '')
      else
        text
      end
    end
  end
end
