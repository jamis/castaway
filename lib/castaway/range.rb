require 'castaway/times'

module Castaway

  class Range
    include Castaway::Times

    attr_accessor :start_frame, :end_frame

    def self.at_frame(production, frame)
      new(production).tap do |range|
        range.start_frame = frame
        range.end_frame = frame
      end
    end

    def self.at_time(production, time)
      new(production).tap do |range|
        range.start_time = time
        range.end_time = time
      end
    end

    def self.at_scene(production, title)
      new(production).tap do |range|
        range.start_scene = title
        range.end_scene = title
      end
    end

    def initialize(production)
      @production = production
      @start_frame = 0
      self.end_time = production.duration
    end

    def truncated?
      start_frame > 0 || end_time < @production.duration
    end

    def duration
      (end_frame - start_frame) / @production.fps.to_f
    end

    def start_time=(t)
      @start_frame = (_parse_time(t) * @production.fps).floor
    end

    def start_time
      @start_frame / @production.fps.to_f
    end

    def end_time=(t)
      @end_frame = (_parse_time(t) * @production.fps).ceil
    end

    def end_time
      @end_frame / @production.fps.to_f
    end

    def start_scene=(title)
      scene = @production.scene(title)
      raise ArgumentError, "no scene named #{title.inspect}" unless scene
      self.start_time = scene.start
    end

    def end_scene=(title)
      scene = @production.scene(title)
      raise ArgumentError, "no scene named #{title.inspect}" unless scene
      self.end_time = scene.finish
    end
  end

end
