require 'test/unit'
require 'dumon'

###
# This class tests Dumon::OutDeviceManager class.
class TestOutDeviceManager < Test::Unit::TestCase

  def test_BF15

    Dumon::XrandrManager.class_eval do
        def stool # mock the instance method to produce expected output
            xrand_out = <<nxo
Screen 0: minimum 8 x 8, current 3520 x 1080, maximum 16384 x 16384
VGA-0 disconnected (normal left inverted right x axis y axis)
LVDS-0 connected 1600x900+1920+0 (normal left inverted right x axis y axis) 345mm x 194mm
1600x900 60.0*+ 50.0

DP-0 disconnected (normal left inverted right x axis y axis)
DP-1 disconnected (normal left inverted right x axis y axis)
DP-2 disconnected (normal left inverted right x axis y axis)
DP-3 disconnected (normal left inverted right x axis y axis)
DP-4 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 531mm x 299mm
1920x1080 60.0*+ 59.9 50.0 30.0 30.0 25.0

1680x1050 60.0

1440x900 59.9

1280x1024 75.0 60.0

1280x720 60.0 59.9 50.0

1152x864 60.0

1024x768 75.0 70.1 60.0

800x600 75.0 72.2 60.3 56.2

720x576 50.0 25.0

720x480 59.9 30.0

640x480 75.0 72.8 59.9 59.9

DP-5 disconnected (normal left inverted right x axis y axis)
nxo
            "echo \"#{xrand_out}\""
        end
    end
    omanager = Dumon::XrandrManager.new
    omanager.read
    outs = omanager.outputs
    assert_not_nil outs
    assert_equal 2, outs.keys.size
    assert outs.keys.include? 'LVDS-0'
    assert outs.keys.include? 'DP-4'
    assert_equal 1, outs['LVDS-0'][:resolutions].size
    assert_equal 11, outs['DP-4'][:resolutions].size
  end

end
