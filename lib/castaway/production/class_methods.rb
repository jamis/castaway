module Castaway
  class Production
    module ClassMethods
      def scenes
        @scenes ||= []
      end

      def soundclips
        @soundclips ||= {}
      end

      def soundclip(id, value = nil, &block)
        if value.nil? && !block
          soundclips[id]
        else
          soundclips[id] = value || block
        end
      end

      def soundtrack(&block)
        if block
          @soundtrack = block
        else
          @soundtrack
        end
      end

      def resource_paths
        @resource_paths ||= %w( sounds images )
      end

      def output_path
        @output_path ||= 'build'
      end

      def resource_path(path)
        resource_paths << path
      end

      def resource(name)
        resource_paths.each do |path|
          full = File.join(path, name)
          return full if File.exist?(full)
        end

        raise Errno::ENOENT, "no such resource #{name} found"
      end

      def output(path)
        @output_path = path
      end

      def scene(name, &block)
        scenes << [name, block]
      end

      def finish(finish)
        scene(nil) { start finish }
      end

      def pointer(path, options = {})
        id = options[:id] || :default
        pointers[id] = [path, options]
      end

      def pointers
        @pointers ||= {}
      end

      def produce(options = {})
        new(options).produce
      end

      def from_script(file)
        Class.new(self) do
          class_eval File.read(file), file
        end
      end
    end
  end
end
