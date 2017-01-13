module Castaway

  class Size < Struct.new(:width, :height)
    def *(factor)
      if factor.is_a?(Size)
        Size.new(width * factor.width, height * factor.height)
      else
        Size.new(width * factor, height * factor)
      end
    end

    def present?
      width || height
    end

    def empty?
      (width || 0).zero? && (height || 0).zero?
    end

    def aspect_ratio
      @aspect_ratio ||= width.to_f / height
    end

    def with_height(height)
      Size.new((aspect_ratio * height).to_i, height.to_i)
    end

    def with_width(width)
      Size.new(width.to_i, (width / aspect_ratio).to_i)
    end

    def to_s
      format('(%.2f, %.2f)', width, height)
    end

    def to_geometry
      format('%.2fx%.2f', width, height).tap do |geometry|
        geometry << '!' if width && height
      end
    end

    def to_resolution
      format('%dx%d', width || 0, height || 0)
    end
  end

end
