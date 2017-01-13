require 'castaway/point'

module Castaway
  class Box
    def self.from_size(size)
      new(
        Point.new(0, 0),
        Point.new(size.width - 1, 0),
        Point.new(size.width - 1, size.height - 1),
        Point.new(0, size.height - 1))
    end

    def initialize(a, b, c, d, other = {})
      @a = a
      @b = b
      @c = c
      @d = d
      @other_points = other.dup
    end

    def []=(id, point_of_interest)
      @other_points[id] = point_of_interest
      self
    end

    def [](id)
      @other_points[id]
    end

    def scale(factor)
      a = @a * factor
      b = @b * factor
      c = @c * factor
      d = @d * factor

      others = @other_points.each_with_object({}) do |(k, v), h|
        h[k] = v * factor
      end

      Box.new(a, b, c, d, others)
    end

    def rotate(degrees)
      rads = degrees * Math::PI / 180.0

      a = @a.rotate(rads)
      b = @b.rotate(rads)
      c = @c.rotate(rads)
      d = @d.rotate(rads)

      others = @other_points.each_with_object({}) do |(k, v), h|
        h[k] = v.rotate(rads)
      end

      Box.new(a, b, c, d, others)
    end

    def bounds
      x1, x2 = [ @a.x, @b.x, @c.x, @d.x ].minmax
      y1, y2 = [ @a.y, @b.y, @c.y, @d.y ].minmax

      # translate to origin
      x2 -= x1
      y2 -= y1
      others = @other_points.each_with_object({}) do |(k, v), h|
        h[k] = v.translate(-x1, -y1)
      end

      Box.new(Point.new(0, 0), Point.new(x2, 0),
              Point.new(x2, y2), Point.new(0, y2), others)
    end

    def to_s
      "#{@a}-#{@b}-#{@c}-#{@d}"
    end
  end
end
