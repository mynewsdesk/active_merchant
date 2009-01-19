require File.dirname(__FILE__) + '/../../../test_helper'

class DibsFlexwinReturnTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def test_return
    r = DibsFlexwin::Return.new( 'authkey=b7e7190eb2f8718e936bee9c7bd6fc85&transact=12345678', {
                                 :security_key1 => "this_is_key1",
                                 :security_key2 => "this_is_key2",
                                 :currency => 578,
                                 :amount => 9995
    })
    assert r.success?
  end  
end

