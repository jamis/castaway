require 'castaway/colors'

module Castaway
  class Color
    def self.create(arg)
      if arg.is_a?(String) || arg.is_a?(Symbol)
        from_string(arg)
      elsif arg.is_a?(Integer)
        from_hex(arg)
      else
        raise ArgumentError, "cannot create color with #{arg.inspect}"
      end
    end

    def self.from_string(string)
      string = string.to_s.downcase

      if string =~ /^#?([a-f0-9]{6})/
        from_hex(($1.to_i(16) << 8) + 0xff)
      elsif string =~ /^#?([a-f0-9]{8})/
        from_hex($1.to_i(16))
      else
        r, g, b, a = COLORS[string.to_sym]
        raise ArgumentError, "unknown color spec #{string.inspect}" unless r
        new(r, g, b, a)
      end
    end

    def self.from_hex(hex)
      r = (hex & 0xff000000) >> 24
      g = (hex & 0x00ff0000) >> 16
      b = (hex & 0x0000ff00) >>  8
      a = (hex & 0x000000ff) >>  0

      new(r, g, b, a)
    end

    attr_reader :r, :g, :b, :a

    def initialize(r, g, b, a=0xff)
      @r = r
      @g = g
      @b = b
      @a = a
    end

    def +(color)
      Color.new(r + color.r, g + color.g, b + color.b, a + color.a)
    end

    def -(color)
      Color.new(r - color.r, g - color.g, b - color.b, a - color.a)
    end

    def *(factor)
      Color.new(r * factor, g * factor, b * factor, a * factor)
    end

    def to_imagemagick
      format('rgba(%d,%d,%d,%d)', r.to_i, g.to_i, b.to_i, a.to_i)
    end
  end
end
