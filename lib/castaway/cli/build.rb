require 'castaway/production'
require 'castaway/range'

module Castaway
  module CLI
    class Build
      extend GLI::App

      def self.description
        'Builds the given castaway production'
      end

      def self.define(command)
        command.desc 'The resolution at which to generate the frames'
        command.flag %i(r resolution), default_value: '540p'

        command.desc 'How many frames per second to generate'
        command.flag %i(f fps), default_value: 29.97, type: Float

        command.desc 'The frame from which to start producing frames'
        command.flag %i(start-frame), default_value: 0

        command.desc 'The frame after which to stop producing frames'
        command.flag %i(end-frame)

        command.desc 'The scene from which to start producing frames'
        command.flag %i(start-scene)

        command.desc 'The scene after which to stop producing frames'
        command.flag %i(end-scene)

        command.desc 'The time from which to start producing frames'
        command.flag %i(start-time)

        command.desc 'The time after which to stop producing frames'
        command.flag %i(end-time)

        command.desc 'What to call the resulting movie'
        command.flag %i(o output)

        command.action do |_globals, options, args|
          exit_now!('you have to supply a castaway program') if args.empty?

          definition = Castaway::Production.from_script(args.first)
          new(definition, args.first, options)
        end
      end

      def initialize(definition, name, options)
        deliverable = File.basename(name, File.extname(name)) + '.mp4'

        production = definition.new(
          resolution: options[:resolution],
          fps: options[:fps],
          deliverable: options[:output] || deliverable)

        range = Castaway::Range.new(production)

        if options['start-time']
          range.start_time = options['start-time']
        elsif options['start-scene']
          range.start_scene = options['start-scene']
        elsif options['start-frame']
          range.start_frame = options['start-frame']
        end

        if options['end-time']
          range.end_time = options['end-time']
        elsif options['end-scene']
          range.end_scene = options['end-scene']
        elsif options['end-frame']
          range.end_frame = options['end-frame']
        end

        production.produce(range)
      end
    end
  end
end
