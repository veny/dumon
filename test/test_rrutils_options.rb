require 'test/unit'
require 'rrutils'

###
# This class tests Rrutils::Options module.
class TestRrutilsOptions < Test::Unit::TestCase
  include Rrutils::Options

  def test_verify_options_preconditions
    assert_raise ArgumentError do verify_options(nil, {:a => 'A'}); end
    assert_raise ArgumentError do verify_options('a string', {:a => 'A'}); end
    assert_raise ArgumentError do verify_options({:b => 'B'}, nil); end
    assert_raise ArgumentError do verify_options({:b => 'B'}, {}); end
    assert_raise ArgumentError do verify_options({:b => 'B'}, 'a string'); end
  end

  def test_verify_options
    opt_pattern = {:a => :mandatory, :b => :optional, :c => 'predefined', :d => [1, false]}
    assert_nothing_thrown do verify_options({:a => 'A', :b => 'B', :c => 'C', :d => 1}, opt_pattern); end
    assert_nothing_thrown do verify_options({:a => 'A', :d => 1}, opt_pattern); end

    # missing mandatory
    assert_raise ArgumentError do verify_options({}, opt_pattern); end
    assert_raise ArgumentError do verify_options({:a => 'A'}, opt_pattern); end
    assert_raise ArgumentError do verify_options({:d => 1}, opt_pattern); end
    assert_raise ArgumentError do verify_options({:a => nil, :d => 1}, opt_pattern); end
    assert_raise ArgumentError do verify_options({:a => 'A', :d => nil}, opt_pattern); end
    # unknown key
    assert_raise ArgumentError do verify_options({:a => 'A', :z => 2}, opt_pattern); end
    # value not in predefined set
    assert_raise ArgumentError do verify_options({:a => 'A', :d => 3}, opt_pattern); end
  end

  def test_verify_and_sanitize_options
    opt_pattern = {:a => 'A', :b => 'B'}
    options = {:a => 'X'}
    opts = verify_and_sanitize_options(options, opt_pattern)
    assert_equal 2, opts.size
    assert_equal 'X', opts[:a]
    assert_equal 'B', opts[:b]

    # :optional cannot be set as default value
    opt_pattern = {:a => :optional, :b => 'B'}
    options = {}
    opts = verify_and_sanitize_options(options, opt_pattern)
    assert_equal 1, opts.size
    assert !opts.include?(:a)
    assert_equal 'B', opts[:b]
  end

end
