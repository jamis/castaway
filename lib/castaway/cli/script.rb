require 'castaway/production'

module Castaway
  module CLI
    class Script
      extend GLI::App

      def self.description
        'Display the given program as a script'
      end

      def self.define(command)
        command.action do |_globals, _options, args|
          exit_now!('you have to supply a castaway program') if args.empty?

          production = Castaway::Production.from_script(args.first)

          production.new.scenes.each.with_index do |scene, idx|
            mark = scene.start || "##{idx+1}"
            puts "[#{mark}] #{scene.title}"
            puts scene.script if scene.script
            puts
          end
        end
      end
    end
  end
end
