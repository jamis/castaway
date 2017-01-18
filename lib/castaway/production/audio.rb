require 'chaussettes'

module Castaway
  class Production
    module Audio

      attr_reader :embedded_clips

      def initialize
        @embedded_clips = []
        super
      end

      # Returns the filename associated with the soundclip with the given id.
      # If the soundclip was declared with a block, the block will be evaluated
      # with a new `Chaussettes::Clip` instance, and the a temporary filename
      # containing the resulting audio will be returned,
      def soundclip(id)
        @soundclips ||= {}
        @soundclips[id] ||= begin
          definition = self.class.soundclip(id)
          raise "no soundclip #{id.inspect}" unless definition

          case definition
          when String then
            definition
          when Proc then
            _next_filename('.aiff').tap do |filename|
              Chaussettes::Clip.new do |clip|
                instance_exec(clip, &definition)
                clip.out(filename)
                clip.run
              end
            end
          else
            raise ArgumentError, "can't use #{definition.inspect} as soundclip"
          end
        end
      end

      # Ducks the `basis` audio beneath the given `overlays`. Each overlay
      # should be a hash containing at least a `:clip` key, corresponding to
      # a filename to be used for the overlay clip. Additional keys are:
      #
      # * `:at` (default 0, where in `basis` the overlay should be applied)
      # * `:adjust` (default 0.5, how much the basis audio should be reduced)
      # * `:speed` (default 0.5, how many seconds the fade in/out should take)
      #
      # Returns a new filename representing the results of the duck operation.
      def duck(basis, *overlays)
        _next_filename('.aiff').tap do |result|
          Chaussettes::Clip.new do |clip|
            clip.mix.out result

            count = overlays.reduce(0) do |total, options|
              total + _duck(clip, basis, options)
            end

            # restore volume
            clip.chain.vol count

            clip.run
          end
        end
      end

      def _duck(clip, basis, options)
        adjust = options[:adjust] || 0.5
        speed = options[:speed] || 0.5

        state = {
          input: basis, overtrack: options[:clip],
          at: options[:at] || 0,
          adjust: adjust, speed: speed,
          info: Chaussettes::Info.new(options[:clip]),
          right_delay: adjust * speed, left_delay: (1 - adjust) * speed
        }

        count =  _build_intro(clip, state)
        count += _build_middle(clip, state)
        count += _build_last(clip, state)
        count +  _build_overlay(clip, state)
      end

      def _build_intro(clip, state)
        Chaussettes::Clip.new do |c|
          c.in(state[:input])
          c.out(device: :stdout).type(:aiff).rate(48_000).channels(2)
          c.chain.fade(0, state[:at] + state[:right_delay],
                       state[:speed], type: :linear)

          clip.in(c).type :aiff
        end

        1
      end

      def _build_middle(clip, state)
        Chaussettes::Clip.new do |c|
          c.in(state[:input])
          c.out(device: :stdout).type(:aiff).rate(48_000).channels(2)
          c.chain.
            trim(state[:at], state[:info].duration).
            vol(state[:adjust]).
            pad(state[:at])

          clip.in(c).type :aiff
        end

        1
      end

      def _build_last(clip, state)
        return 0 unless state[:at] + state[:info].duration < duration

        Chaussettes::Clip.new do |c|
          c.in(state[:input])
          c.out(device: :stdout).type(:aiff).rate(48_000).channels(2)
          c.chain.trim(state[:at] + state[:info].duration - state[:left_delay]).
            fade(state[:speed], type: :linear).
            pad(state[:at] + state[:info].duration - state[:left_delay])

          clip.in(c).type :aiff
        end

        1
      end

      def _build_overlay(clip, state)
        Chaussettes::Clip.new do |c|
          c.in(state[:overtrack])
          c.out(device: :stdout).type(:aiff).rate(48_000).channels(2)
          c.chain.pad(state[:at])

          clip.in(c).type :aiff
        end

        1
      end

      def _produce_soundtrack(range)
        block = self.class.soundtrack
        soundtrack = if block
          _next_filename('.aiff').tap do |output|
            Chaussettes::Clip.new do |clip|
              instance_exec(clip, &block)
              clip.out(output)
              clip.run
            end
          end
        end

        soundtrack = _mix_embedded_audio(soundtrack)
        _clip_audio(range, soundtrack)
      end

      def _mix_embedded_audio(soundtrack)
        return soundtrack unless embedded_clips.any?

        _next_filename('.aiff').tap do |output|
          Chaussettes::Clip.new do |clip|
            clip.in(soundtrack) if soundtrack

            embedded_clips.each do |embed|
              clip.in(_build_embedded_clip(embed))
            end

            count = embedded_clips.count
            count += 1 if soundtrack
            clip.mix if count > 1

            clip.out(output)
            clip.run
          end
        end
      end

      def _build_embedded_clip(info)
        _next_filename('.aiff').tap do |output|
          Chaussettes::Clip.new do |clip|
            clip.in(info.source)

            clip.chain.tap do |chain|
              chain.trim(0, info.duration) if info.duration
              chain.pad(info.start) if info.start > 0
            end

            clip.out(output)
            clip.run
          end
        end
      end

      def _clip_audio(range, soundtrack)
        return nil unless soundtrack

        info = Chaussettes::Info.new(soundtrack)
        return soundtrack if range.duration >= info.duration

        clipped = _next_filename('.aiff')
        Chaussettes::Clip.new do |clip|
          clip.in(soundtrack)
          clip.chain.trim range.start_time, range.end_time - range.start_time
          clip.out(clipped)
          clip.run
        end

        clipped
      end
    end
  end
end
