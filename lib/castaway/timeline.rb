require 'logger'
require 'fileutils'

module Castaway

  class Timeline
    attr_reader :resolution, :fps

    def initialize(resolution, fps)
      @resolution = resolution
      @elements = []
      @fps = fps

      @cached_command = nil
      @cached_file = nil
    end

    def add(element)
      @elements << element
    end

    def duration
      @elements.map(&:t2).max
    end

    def render_frame(frame, name: 'frame')
      t = frame / fps.to_f

      signature = nil
      tool = MiniMagick::Tool::Convert.new.tap do |convert|
        convert << '-size' << resolution.to_geometry
        convert.xc 'black'

        @elements.sort_by(&:t1).each do |element|
          next unless element.alive_at?(t)
          element.render_at(t, convert)
        end

        convert.colorspace 'sRGB'
        convert.type 'TrueColor'
        convert.depth '16'

        signature = convert.command
        convert << "PNG48:#{name}.png"
      end

      if signature != @cached_command
        _log frame, t, tool.command.join(' ')
        @cached_command = signature
        @cached_file = name
        tool.call
      else
        old = "#{@cached_file}.png"
        new = "#{name}.png"
        _log frame, t, "duplicate #{old} as #{new}"
        _link old, new
      end
    end

    def _link(old, new)
      # FIXME: detect whether linking is supported, and fallback to copy
      # if not.

      FileUtils.ln(old, new)
    end

    def _logger
      @_logger ||= Logger.new('build.log').tap do |logger|
        logger.formatter = lambda do |severity, _datetime, _progname, msg|
          "#{severity}: #{msg}\n"
        end
      end
    end

    def _log(frame, t, msg)
      _logger.info { format('[%d:%.2fs] %s', frame, t, msg) }
    end
  end

end
