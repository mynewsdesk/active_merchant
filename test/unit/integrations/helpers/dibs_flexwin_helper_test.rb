require File.dirname(__FILE__) + '/../../../test_helper'

class DibsFlexwinHelperTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations
  
  def setup
    @helper = DibsFlexwin::Helper.new( '3993', 'testmerchant', 
      :amount => 1000,
      :currency => 'NOK',
      :security_key1 => "this_is_key1",
      :security_key2 => "this_is_key2"
    )
  end
 
  def test_basic_helper_fields
    assert_field 'merchant', 'testmerchant'
    assert_field 'amount', '1000'
    assert_field 'orderid', '3993'
  end

  def test_unknown_mapping
    assert_nothing_raised do
      @helper.company_address :address => '500 Dwemthy Fox Road'
    end
  end
end
