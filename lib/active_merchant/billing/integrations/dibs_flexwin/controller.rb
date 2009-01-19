module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DibsFlexwin
        module Controller
          # Set checkout_action the the action generating the payment form.
          mattr_accessor :checkout_action
          self.checkout_action = "checkout"

          # Overriding default functionality. This will prevent
          # authenticity_token to be added to DIBS FlexWin form.
          def protect_against_forgery?
            if self.checkout_action.is_a?(Array)
              return false if self.checkout_action.include?(params[:action])
            elsif self.checkout_action.is_a?(String)
              return false if params[:action] == self.checkout_action
            end
            super
          end
        end
      end
    end
  end
end
