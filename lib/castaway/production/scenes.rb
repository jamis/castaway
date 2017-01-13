require 'castaway/scene'

module Castaway
  class Production
    module Scenes

      def pointers
        self.class.pointers
      end

      def duration
        @scenes.last.finish
      end

      def scene(title)
        @scenes.find { |s| s.title == title }
      end

      def resource(name)
        self.class.resource(name)
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
