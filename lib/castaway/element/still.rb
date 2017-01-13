require 'castaway/element/base'
require 'mini_magick'

module Castaway
  module Element

    class Still < Element::Base
      attr_reader :filename, :info

      def initialize(production, scene, filename, full: false)
        super(production, scene)

        @filename = production.resource(filename)
        @info = MiniMagick::Image.new(@filename)

        @size = if full
                  # scale to production resolution
                  production.resolution
                else
                  # use native image size
                  Castaway::Size.new(@info.width, @info.height)
                end
      end

      def _prepare_canvas(_t, canvas)
        canvas << @filename
      end
    end

  end
end
