require File.dirname(__FILE__) + '/../../../test_helper'

class DibsFlexwinNotificationTest < Test::Unit::TestCase
  include ActiveMerchant::Billing::Integrations

  def setup
    @dibs_flexwin_complete = DibsFlexwin::Notification.new( http_raw_data_complete,
      :remote_ip => 'this_is_remote_ip',
      :security_key1 => "this_is_key1",
      :security_key2 => "this_is_key2",
      :currency => 578,
      :amount => 9995
    )
    @dibs_flexwin_pot_fraud = DibsFlexwin::Notification.new( http_raw_data_pot_fraud,
      :remote_ip => 'this_is_remote_ip',
      :security_key1 => "this_is_key1",
      :security_key2 => "this_is_key2",
      :currency => 578,
      :amount => 9995
    )
  end

  def test_notification
    assert_instance_of DibsFlexwin::Notification, @dibs_flexwin_complete
    assert_instance_of DibsFlexwin::Notification, @dibs_flexwin_pot_fraud
  end

  def test_accessors
    assert @dibs_flexwin_complete.complete?
    assert !@dibs_flexwin_complete.potential_fraud?
    assert !@dibs_flexwin_pot_fraud.complete?
    assert @dibs_flexwin_pot_fraud.potential_fraud?
    assert_equal "APPROVED", @dibs_flexwin_complete.status
    assert_equal "12345678", @dibs_flexwin_complete.transaction_id
    assert_equal 9995, @dibs_flexwin_complete.gross_cents
    assert_equal 578, @dibs_flexwin_complete.currency
    assert @dibs_flexwin_complete.test?
  end

  def test_compositions
    #assert_equal Money.new(3166, 'USD'), @dibs_flexwin.amount
  end

  # Replace with real successful acknowledgement code
  def test_acknowledgement
    #assert @dibs_flexwin_complete.acknowledge
  end

  def test_respond_to_acknowledge
    assert @dibs_flexwin_complete.respond_to?(:acknowledge)
    assert @dibs_flexwin_pot_fraud.respond_to?(:acknowledge)
  end

  private
  def http_raw_data_complete
    "authkey=b7e7190eb2f8718e936bee9c7bd6fc85&transact=12345678"
  end

  def http_raw_data_pot_fraud
    http_raw_data_complete + "&suspect=yes&severity=7"
  end
end
