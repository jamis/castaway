require 'test_setup'

module Element
  class BaseTest < Minitest::Test
    def setup
      @production = Castaway::Production.new
      @scene = Castaway::Scene.new('Test Scene', @production)
      @element = Castaway::Element::Base.new(@production, @scene)
    end

    def test_at_with_single_point_parameter_becomes_delta_position
      p0 = Castaway::Point.new(10, 20)
      @element.at(p0)
      assert_equal p0, @element.position[0]
      assert_equal p0, @element.position[1]
    end

    def test_at_with_single_delta_parameter_uses_delta
      p0 = Castaway::Point.new(10, 20)
      p1 = Castaway::Point.new(15, 30)
      @element.at(Castaway::Delta.new(0 => p0, 5 => p1))
      assert_equal p0, @element.position[0]
      assert_equal Castaway::Point.new(13, 26), @element.position[3]
      assert_equal p1, @element.position[5]
    end

    def test_at_with_single_hash_parameter_configures_delta
      p0 = Castaway::Point.new(10, 20)
      p1 = Castaway::Point.new(15, 30)
      @element.at(0 => p0, 5 => p1)
      assert_equal p0, @element.position[0]
      assert_equal Castaway::Point.new(13, 26), @element.position[3]
      assert_equal p1, @element.position[5]
    end

    def test_at_with_two_parameters_configures_delta_with_new_point
      p0 = Castaway::Point.new(10, 20)
      @element.at(p0.x, p0.y)
      assert_equal p0, @element.position[0]
      assert_equal p0, @element.position[1]
    end

    def test_scale_with_zero_parameters_returns_current_scale
      assert_equal 1, @element.scale[0]
    end

    def test_scale_with_one_numeric_parameter_configures_delta_with_value
      @element.scale 0.5
      assert_equal 0.5, @element.scale[0]
    end

    def test_scale_with_one_hash_parameter_configures_delta_with_hash
      @element.scale 0 => 1, 2 => 0.2
      assert_equal 0.6, @element.scale[1]
    end

    def test_scale_with_delta_parameter_uses_delta
      delta = Castaway::Delta.new(0 => 1, 2 => 0.2)
      @element.scale delta
      assert_equal 0.6, @element.scale[1]
    end

    def test_rotate_with_zero_parameters_returns_current_rotate
      assert_equal 0, @element.rotate[0]
    end

    def test_rotate_with_one_numeric_parameter_configures_delta_with_value
      @element.rotate 45
      assert_equal 45, @element.rotate[0]
    end

    def test_rotate_with_one_hash_parameter_configures_delta_with_hash
      @element.rotate 0 => 0, 2 => 90
      assert_equal 45, @element.rotate[1]
    end

    def test_rotate_with_delta_parameter_uses_delta
      delta = Castaway::Delta.new(0 => 0, 2 => 90)
      @element.rotate delta
      assert_equal 45, @element.rotate[1]
    end

    def test_alpha_with_zero_parameters_returns_current_alpha
      assert_equal 1, @element.alpha[0]
    end

    def test_alpha_with_one_numeric_parameter_configures_delta_with_value
      @element.alpha 0.5
      assert_equal 0.5, @element.alpha[0]
    end

    def test_alpha_with_one_hash_parameter_configures_delta_with_hash
      @element.alpha 0 => 0, 2 => 1
      assert_equal 0.5, @element.alpha[1]
    end

    def test_alpha_with_delta_parameter_uses_delta
      delta = Castaway::Delta.new(0 => 0, 2 => 1)
      @element.alpha delta
      assert_equal 0.5, @element.alpha[1]
    end
  end
end
