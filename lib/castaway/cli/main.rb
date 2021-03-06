require 'gli'
require 'castaway'
require 'castaway/cli/build'
require 'castaway/cli/script'
require 'castaway/cli/version'

module Castaway
  module CLI
    class Main
      extend GLI::App

      program_desc 'Build screencasts from a script'

      desc Castaway::CLI::Script.description
      command(:build) { |c| Castaway::CLI::Build.define(c) }

      desc Castaway::CLI::Script.description
      command(:script) { |c| Castaway::CLI::Script.define(c) }

      desc Castaway::CLI::Version.description
      command(:version) { |c| Castaway::CLI::Version.define(c) }

      on_error do |exception|
        $stderr.puts "exception: #{exception.class} (#{exception.message})"
        exception.backtrace.each do |item|
          $stderr.puts "- #{item}"
        end
        false
      end
    end
  end
end
