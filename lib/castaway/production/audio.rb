require 'chaussettes'

module Castaway
  class Production
    module Audio

      def _produce_soundtrack(range)
        block = self.class.soundtrack
        return nil unless block

        _next_filename('.aiff').tap do |filename|
          Chaussettes::Clip.new do |clip|
            instance_exec(clip, &block)
            clip.chain.trim range.start_time, range.end_time - range.start_time
            clip.out(filename)
            clip.run
          end
        end
      end

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

    end
  end
end
