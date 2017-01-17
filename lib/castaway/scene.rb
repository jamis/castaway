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

    # Declares (or returns) the time value (in seconds) for the start of this
    # scene. Any value parsable by Castaway::Times will be accepted.
    def start(value = nil)
      return @start unless value
      @start = _parse_time(value)
    end

    # Parses and returns the seconds corresponding to the given value. See
    # Castaway::Times.
    def time(value)
      _parse_time(value)
    end

    # Returns a new Castaway::RelativeTo instance for the resource with the
    # given file name. This is useful for positioning pointers in a
    # resolution-independent way.
    def relative_to_image(name)
      RelativeTo.new(name, production)
    end

    # Sets (or returns) the script corresponding to the current scene.
    # This is not used, except informationally.
    def script(*args)
      if args.empty?
        @script
      elsif args.length == 1
        @script = _strip(args.first)
      else
        raise ArgumentError, 'script expects 0 or 1 argument'
      end
    end

    # Declare the plan to be used for constructing the scene. Within the plan,
    # scene elements are declared and configured.
    #
    #     plan do
    #       matte(:black).enter(-0.5).in(:dissolve, speed: 0.5)
    #     end
    #
    # See #matte, #still, #text, #sprite, and #pointer.
    def plan(&block)
      @plan = block
    end

    def construct(timeline)
      @_timeline = timeline
      instance_eval(&@plan) if @plan
    ensure
      remove_instance_variable :@_timeline
    end

    # Returns a new Castaway::Element::Matte element with the given color, and
    # adds it to the timeline.
    def matte(color)
      Element::Matte.new(production, self, color).tap do |element|
        _timeline.add(element)
      end
    end

    # Returns a new Castaway::Element::Still element for the given filename,
    # and adds it to the timeline. It will be forced to fill the entire frame.
    def still(filename)
      _still(filename, true)
    end

    # Returns a new Castaway::Element::Still element for the given filename,
    # and adds it to the timeline. It's native dimensions will be preserved.
    def sprite(filename)
      _still(filename, false)
    end

    # Returns a new Castaway::Element::Pointer element and adds it to the
    # timeline. If an `id` is given, the pointer declared with that `id` is
    # used.
    def pointer(id = :default)
      Element::Pointer.new(production, self, id).tap do |pointer|
        _timeline.add(pointer)
      end
    end

    # Returns a new Castaway::Element::Text element with the given text, and
    # adds it to the timeline.
    def text(string)
      Element::Text.new(production, self, string).tap do |text|
        _timeline.add(text)
      end
    end

    # Returns a Castaway::Point with the given coordinates multiplied by the
    # resolution. This let's you declare coordinates as fractions of the frame
    # size, so that they work regardless of the final rendered resolution.
    def relative_position(x, y)
      Castaway::Point.new(x, y) * production.resolution
    end

    def update_from_next(neighbor)
      @finish = neighbor.nil? ? @start : neighbor.start
      @duration = @finish - @start
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
