require 'castaway/scene'

module Castaway
  class Production
    module Scenes

      # Returns the duration of the production, in seconds.
      def duration
        @scenes.last.finish
      end

      # Returns the first scene with the given title.
      def scene(title)
        @scenes.find { |s| s.title == title }
      end

      def resource(name)
        self.class.resource(name)
      end

      def pointers
        self.class.pointers
      end

      def _build_scenes
        @scenes = self.class.scenes.map do |(name, config)|
          Castaway::Scene.new(name, self).configure(&config)
        end

        @scenes = @scenes.sort_by(&:start)

        @scenes.each.with_index do |scene, index|
          scene.update_from_next(@scenes[index + 1])
        end
      end

    end
  end
end
