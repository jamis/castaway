require 'castaway/times'

module Castaway
  class Production
    module ClassMethods
      include Castaway::Times

      # Returns an Array of Castaway::Scene objects corresponding to the
      # scenes that have been defined.
      def scenes
        @scenes ||= []
      end

      # Returns a Hash, mapping ids to either direct values (path names), or
      # blocks (which are intended to configure a soundclip).
      def soundclips
        @soundclips ||= {}
      end

      # Declare a new soundclip with the given `id`. If a `value` is given, it
      # is expected to be a path to a sound file. For example:
      #
      #     soundclip :narration, resource('narration.mp3')
      #
      # If a block is given, it is expected to accept a single parameter
      # (a Chaussettes::Clip instance), and configure the soundclip on that
      # instance.
      #
      #     soundclip :theme do |clip|
      #       clip.in resource('theme.mp3')
      #       clip.chain.
      #         trim(0, 15).     # grab the first 15s of the clip
      #         fade(0.5, 0, 5)  # fade in 0.5s, and then out 5s at the end
      #     end
      def soundclip(id, value = nil, &block)
        if value.nil? && !block
          soundclips[id]
        else
          soundclips[id] = value || block
        end
      end

      # Declare the soundtrack for the production. Every production may have
      # zero or one soundtracks. The block you provide here should accept a
      # single parameter--a `Chausettes::Clip` instance--which must be populated
      # with the desired audio for the production.
      #
      #     soundtrack do |clip|
      #       clip.in(
      #         duck(soundclip(:theme),
      #              clip: soundclip[:narration], at: 3)
      #       )
      #     end
      def soundtrack(&block)
        if block
          @soundtrack = block
        else
          @soundtrack
        end
      end

      # Returns a list of paths that will be searched for resources. By
      # default, the searched paths are 'sounds' and 'images'. See the
      # #resource method for how to add paths to this list.
      def resource_paths
        @resource_paths ||= %w( sounds images )
      end

      # Returns the output path to be used for generated files, like frames and
      # intermediate audio. It defaults to 'build'. See the #output method for
      # how to set this value.
      def output_path
        @output_path ||= 'build'
      end

      # Adds the given path to the list of paths that will be searched by
      # Castaway for resources. (See #resource_paths)
      def resource_path(path)
        resource_paths << path
      end

      # Looks for a file with the given name in the defined resource paths
      # (see #resource_paths). Returns the path to the file if it is found in
      # one of the paths, otherwise raises `Errno::ENOENT`.
      def resource(name)
        resource_paths.each do |path|
          full = File.join(path, name)
          return full if File.exist?(full)
        end

        raise Errno::ENOENT, "no such resource #{name} found"
      end

      # Declares the directory to be used for storing intermediate media, like
      # frames and audio. (See #output_path)
      def output(path)
        @output_path = path
      end

      # Declares a new scene with the given name. Although it is not required
      # that all scenes have unique names, it is recommended. The given block
      # is invoked, without arguments, when the scene is constructed. (See
      # Castaway::Scene)
      def scene(name, &block)
        scenes << [name, block]
      end

      # Declares the end-time of the production. If this is not set, your final
      # scene will likely be truncated.
      def finish(finish)
        scene(nil) { start finish }
      end

      # Parses the given value into a float representing a number of seconds.
      # See Castaway::Times.
      def time(value)
        _parse_time(value)
      end

      # Declares a pointer using the image at the given `path`. If an `:id`
      # option is given, it will be used to identify the pointer. Otherwise,
      # it will use the default identifier. See Castaway::Scene.
      def pointer(path, options = {})
        id = options[:id] || :default
        pointers[id] = [path, options]
      end

      # Returns a Hash of pointer declarations, mapping ids to path/option
      # data.
      def pointers
        @pointers ||= {}
      end

      # Treats the given `file` as a Castaway script, and evaluates it in the
      # context of a new, anonymous subclass of Castaway::Production. This new
      # subclass is returned.
      def from_script(file)
        Class.new(self) do
          class_eval File.read(file), file
        end
      rescue Exception => e
        puts "#{e.class} (#{e.message})"
        puts e.backtrace
        abort
      end
    end
  end
end
