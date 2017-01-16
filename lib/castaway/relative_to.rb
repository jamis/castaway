require 'mini_magick'
require 'castaway/point'

module Castaway
  class RelativeTo
    def initialize(image_file_name, production)
      path = production.resource(image_file_name)
      image = MiniMagick::Image.new(path)
      @width = image.width.to_f
      @height = image.height.to_f
      @production = production
    end

    def position(x, y)
      Castaway::Point.new(x / @width, y / @height) * @production.resolution
    end
  end
end
