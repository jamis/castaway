module Castaway

  class Point < Struct.new(:x, :y)
    def self.make(*args)
      if args.length == 1 && args[0].is_a?(Array)
        new(args[0][0], args[0][1])
      elsif args.length == 1 && args[0].is_a?(Point)
        args[0]
      else
        raise ArgumentError, "can't make a point from #{args.inspect}"
      end
    end

    def *(factor)
      if factor.respond_to?(:x)
        Point.new(x * factor.x, y * factor.y)
      elsif factor.respond_to?(:width)
        Point.new(x * factor.width, y * factor.height)
      else
        Point.new(x * factor, y * factor)
      end
    end

    def -(pt)
      Point.new(x - pt.x, y - pt.y)
    end

    def +(pt)
      Point.new(x + pt.x, y + pt.y)
    end

    def zero?
      x == 0 && y == 0
    end

    def translate(dx, dy)
      Point.new(x + dx, y + dy)
    end

    def scale(sx, sy = sx)
      Point.new(x * sx, y * sy)
    end

    def rotate(radians)
      cos = Math.cos(radians)
      sin = Math.sin(radians)

      nx = x * cos - y * sin
      ny = y * cos + x * sin

      Point.new(nx, ny)
    end

    def to_s
      format('(%.2f, %.2f)', x, y)
    end

    def to_geometry
      format('+%.2f+%.2f', x, y)
    end
  end

end
