require 'test_setup'

class DeltaTest < Minitest::Test
  Reifiable = Struct.new(:reify)

  def test_delta_should_interpolate_values
    delta = Castaway::Delta.new(0 => 1, 1 => 5)
    assert_equal 1, delta[0]
    assert_equal 3, delta[0.5]
    assert_equal 5, delta[1]
  end

  def test_delta_should_interpolate_multiple_points
    delta = Castaway::Delta.new(0 => 1, 1 => 3, 2 => 7)
    assert_equal 1, delta[0]
    assert_equal 2, delta[0.5]
    assert_equal 5, delta[1.5]
  end

  def test_delta_should_be_v0_when_t_is_before_t0
    delta = Castaway::Delta.new(0 => 1, 1 => 5)
    assert_equal 1, delta[-1]
  end

  def test_delta_should_be_vn_when_t_is_before_tn
    delta = Castaway::Delta.new(0 => 1, 1 => 5)
    assert_equal 5, delta[2]
  end

  def test_class_brackets_should_return_a_single_valued_delta
    delta = Castaway::Delta[5]
    assert_equal 5, delta[-1]
    assert_equal 5, delta[0]
    assert_equal 5, delta[1]
  end

  def test_interpolation_should_reify_case_where_t_is_less_than_beginning
    delta = Castaway::Delta[Reifiable.new(5)]
    assert_equal 5, delta[-1]
  end

  def test_interpolation_should_reify_case_where_t_is_after_the_end
    delta = Castaway::Delta.new(0 => Reifiable.new(0), 1 => Reifiable.new(10))
    assert_equal 10, delta[2]
  end

  def test_interpolation_should_reify_interpolated_case
    delta = Castaway::Delta.new(0 => Reifiable.new(0), 1 => Reifiable.new(10))
    assert_equal 5, delta[0.5]
  end
end
