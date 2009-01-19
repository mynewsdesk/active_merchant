module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DibsFlexwin
        class Return < ActiveMerchant::Billing::Integrations::Return
          include RequiresParameters
          include Common

          def initialize( query_string, options )
            requires!( options, :security_key1, :security_key2, :currency, :amount)
            @options = options
            super( query_string )
          end

          def currency
            return @options[:currency] if @options[:currency].to_i > 0
            CURRENCY_CODES[@options[:currency].to_s.downcase.to_sym]
          end

          def success?
            key = md5_authkey( @options[:security_key1], @options[:security_key2],
                               params["transact"],
                               currency(),
                               @options[:amount]
            )
            key == params["authkey"]
          end
        end
      end
    end
  end
end
