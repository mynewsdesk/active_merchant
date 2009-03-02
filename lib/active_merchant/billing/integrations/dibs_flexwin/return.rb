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
            @recurring = false
            super( query_string )
          end

          def currency
            return @options[:currency] if @options[:currency].to_i > 0
            CURRENCY_CODES[@options[:currency].to_s.downcase.to_sym]
          end

          def success?
            rkey = md5_authkey_preauth( @options[:security_key1], @options[:security_key2],
                                params["transact"],
                                currency()
            )

            if (rkey == params["authkey"])
              @recurring = true
              return true
            end

            key = md5_authkey( @options[:security_key1], @options[:security_key2],
                               params["transact"],
                               currency(),
                               @options[:amount]
            )
            key == params["authkey"]
          end

          def recurring?
            return true if @recurring
            rkey = md5_authkey_preauth( @options[:security_key1], @options[:security_key2],
                                params["transact"],
                                currency()
            )
            @recurring = (params["authkey"] == rkey)
          end
        end
      end
    end
  end
end
