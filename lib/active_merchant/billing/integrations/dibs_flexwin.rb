require File.dirname(__FILE__) + '/dibs_flexwin/error.rb'
require File.dirname(__FILE__) + '/dibs_flexwin/common.rb'
require File.dirname(__FILE__) + '/dibs_flexwin/helper.rb'
require File.dirname(__FILE__) + '/dibs_flexwin/notification.rb'
require File.dirname(__FILE__) + '/dibs_flexwin/return.rb'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      # To start with DIBS FlexWin, follow the instructions for installing
      # ActiveMerchant as a plugin, as described on
      # http://www.activemerchant.org/.
      #
      # The plugin will automatically add the ActionView helper for
      # ActiveMerchant, which will allow you to make the DIBS FlexWin payments.
      # The idea behind the helper is that it generates an invisible
      # forwarding screen that will automatically redirect the user.
      # So you would collect all the information about the order and then
      # simply render the hidden form, which redirects the user to DIBS.
      #
      # The syntax for the controller:
      #
      #  class PaymentsController < ApplicationController
      #    include ActiveMerchant::Billing::Integrations::DibsFlexwin::Controller
      #    ActiveMerchant::Billing::Integrations::DibsFlexwin::Controller.checkout_action = "checkout_action"
      #
      #    # Setting the interface in test mode. Remove in production mode.
      #    ActiveMerchant::Billing::Base.integration_mode = :test
      #
      #    # To turn off CSRF for DIBS callback urls.
      #    skip_before_filter :verify_authenticity_token, :only => [:redirect_approved_action, :redirect_canceled_action]
      #
      #  end
      #
      # The syntax of the helper is as follows:
      #
      #    <% payment_service_for 'order id', 'dibs_merchantid',
      #                                 :service => :dibs_flexwin,
      #                                 :amount => 5000, # amount in cents. ( 50.00 * 100)
      #                                 :currency => "NOK",
      #                                 :security_key1 => "this_is_key1",
      #                                 :security_key2 => "this_is_key2",
      #                                 :html => { :id => 'payment-form' } do |service| %>
      #
      #      <% service.notify_url callback_backend_url( 'order id' ) -%>
      #      <% service.return_url approved_payment_url( 'order id' ) -%>
      #      <% service.cancel_return_url canceled_payment_url( 'order id' ) -%>
      #    <% end %>
      #
      # The notify_url is the URL that the DIBS Automatic callback will be
      # sent. You can handle the notification in your controller action as
      # follows:
      #
      #   class NotificationController < ApplicationController
      #     include ActiveMerchant::Billing::Integrations
      #
      #     def callback
      #       notification = DibsFlexwin::Notification.new( request.raw_post, {
      #         :remote_ip     => request.remote_ip,
      #         :merchant      => "testmerchant",
      #         :security_key1 => "this_is_key1",
      #         :security_key2 => "this_is_key2"
      #       })
      #
      #       begin
      #         notification.acknowledge
      #
      #         if notification.potential_fraud?
      #           logger.warn { "Got a potential fraud. Look into it." }
      #         elsif notification.complete?
      #           logger.info { "Got a completed notification, updated order and other stuff." }
      #         else
      #           logger.warn { "Transaction declined. #{notification.status()}"}
      #         end
      #
      #       rescue ActiveMerchant::Billing::Integrations::DibsFlexwin::Error => e
      #         logger.warn { "Got a DIBS error: #{e.message}" }
      #       rescue => e
      #         logger.warn("Illegal notification received: #{e.message}")
      #       ensure
      #         head(:ok)
      #       end
      #     end
      #   end
      module DibsFlexwin
        URL = 'https://payment.architrade.com/paymentweb/start.action'

        def self.service_url
          URL
        end

        def self.notification(post, options = {})
          Notification.new(post, options)
        end

        def self.return( query_string, options = {})
          Return.new( query_string, options)
        end
      end
    end
  end
end
