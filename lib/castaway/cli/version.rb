require 'castaway/version'

module Castaway
  module CLI
    class Version
      def self.description
        "Report the current version (#{Castaway::VERSION})"
      end

      def self.define(command)
        command.action do |_globals, _options, _args|
          puts "v#{Castaway::VERSION}"
        end
      end
    end
  end
end
