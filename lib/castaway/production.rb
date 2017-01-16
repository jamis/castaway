require 'fileutils'
require 'castaway/range'
require 'castaway/size'
require 'castaway/timeline'
require 'ruby-progressbar'

require 'castaway/production/class_methods'
require 'castaway/production/audio'
require 'castaway/production/scenes'

module Castaway
  class Production
    extend Castaway::Production::ClassMethods
    include Castaway::Production::Audio
    include Castaway::Production::Scenes

    attr_reader :options
    attr_reader :current_scene, :scenes
    attr_reader :resolution, :fps

    def initialize(options = {})
      @options = options
      @resolution = _translate_resolution(options[:resolution] || '480p')
      @deliverable = options[:deliverable]
      @fps = options[:fps] || 30

      _build_scenes
    end

    def produce(range = Castaway::Range.new(self))
      FileUtils.mkdir_p(self.class.output_path)

      timeline = _construct_timeline
      _produce_frames(timeline, range)
      soundtrack = _produce_soundtrack(range)
      _produce_movie(soundtrack)
    end

    def deliverable
      @deliverable ||= begin
        if self.class.name
          self.class.name.split(/::/).last.
            gsub(/([^A-Z]+)([A-Z]+)/) { "#{$1}-#{$2.downcase}" }.
            gsub(/([^0-9]+)([0-9]+)/) { "#{$1}-#{$2}" }.
            downcase + '.mp4'
        else
          'production.mp4'
        end
      end
    end

    def _construct_timeline
      Castaway::Timeline.new(resolution, fps).tap do |timeline|
        @scenes.each { |scene| scene.construct(timeline) }
      end
    end

    def _template(ext = nil)
      File.join(self.class.output_path, format('frame-%s%s', '%05d', ext))
    end

    def _produce_frames(timeline, range)
      template = _template

      start_frame = range.start_frame
      end_frame   = range.end_frame

      progress_end = end_frame - start_frame + 1
      progress = ProgressBar.create(starting_at: 0, total: progress_end)

      start_frame.upto(end_frame) do |f|
        timeline.render_frame(f, name: format(template, f - start_frame))
        progress.increment
      end
    end

    def _produce_movie(soundtrack)
      FileUtils.rm_f(deliverable)

      ffmpeg = Chaussettes::Tool.new('ffmpeg')
      ffmpeg << '-thread_queue_size' << 8192
      ffmpeg << '-r' << fps << '-s' << resolution.to_resolution
      ffmpeg << '-i' << _template('.png') << '-i' << soundtrack
      ffmpeg << '-vcodec' << 'libx264'
      ffmpeg << '-preset' << 'veryslow' << '-tune' << 'stillimage'
      ffmpeg << '-crf' << 23 << '-pix_fmt' << 'yuv420p' << '-acodec' << 'aac'
      ffmpeg << deliverable

      puts ffmpeg.to_s
      system(ffmpeg.to_s)
    end

    def _construct_scene(scene, definition)
      instance_exec(scene, &definition)
    ensure
      @current_scene = nil
    end

    def _translate_resolution(res)
      case res
      when Castaway::Size then res
      when Array then Castaway::Size.new(res.first.to_i, res.last.to_i)
      when /^(\d+)p$/ then _hd_resolution(Regexp.last_match(1))
      when Integer then _hd_resolution(res)
      when /^(\d+)x(\d+)$/ then
        Castaway::Size.new(Regexp.last_match(1).to_i, Regexp.last_match(2).to_i)
      else raise ArgumentError,
                 "don't know how to turn #{res.inspect} into resolution"
      end
    end

    def _hd_resolution(rows)
      rows = rows.to_i
      cols = rows * 16 / 9.0
      Castaway::Size.new(cols.ceil, rows)
    end

    def _next_filename(ext = nil)
      @next_filename ||= 0
      File.join(self.class.output_path,
                format('__%04d%s', @next_filename += 1, ext))
    end
  end
end
