require File.dirname(__FILE__) + '/../../test_helper'

class DibsFlexwinModuleTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def test_notification_method
    assert_instance_of( DibsFlexwin::Notification,
      DibsFlexwin.notification('authkey=b9952f284f8a88417a9e99dad7149e0b&transact=12345678',
        :remote_ip => "this_is_remote_ip",
        :security_key1 => "this_is_key1",
        :security_key2 => "this_is_key2",
        :currency => 578,
        :amount => 9995
      )
    )
  end
end
