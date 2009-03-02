module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DibsFlexwin
        # The syntax for the recurring class:
        #
        #  *** Remember to set :recurring => true in the payment_service_for-helper. ***
        #
        #  class PaymentsController < ApplicationController
        #    include ActiveMerchant::Billing::Integrations
        #
        #    # Setting the interface in test mode. Remove in production mode.
        #    ActiveMerchant::Billing::Base.integration_mode = :test
        #
        #    # Code for performing a recurring payment.
        #    def recurring
        #      rec = DibsFlexwin::Recurring.new( <orderid>, <merchant id>,
        #             :security_key1 => <this_is_key1>,
        #             :security_key2 => <this_is_key2>,
        #             :currency      => <currency>,
        #             :amount        => <amount>,
        #             :ticket        => <transaction_id from notify_url>
        #      )
        #
        #      begin
        #        rec.capture_now
        #
        #        if rec.potential_fraud?
        #          logger.warn { "Got a potential fraud. Look into it." }
        #        elsif rec.complete?
        #          logger.info { "Got a completed capture, updated order and other stuff." }
        #        else
        #          logger.warn { "Transaction declined. #{rec.status()}, #{rec.reason_code()}, #{rec.reason}"}
        #        end
        #
        #      rescue ActiveMerchant::Billing::Integrations::DibsFlexwin::Error => e
        #        logger.warn { "Got a DIBS error: #{e.message}" }
        #      rescue => e
        #        logger.warn("Illegal notification received: #{e.message}")
        #      end
        #    end
        # 
        class Recurring
          include PostsData
          include RequiresParameters
          include Common

          attr_reader :params
          attr_reader :response

          def initialize( order, merchant, options = {} )
            requires!( options, :security_key1, :security_key2, :currency, :amount, :ticket)

            @key1 = options.delete(:security_key1)
            @key2 = options.delete(:security_key2)
            @ticket = options.delete(:ticket)

            @params = PostData.new
            @params['orderid'] = order
            @params['merchant'] = merchant
            @params['textreply'] = "true"
            @params['fullreply'] = "true"
            @params['amount'] = options.delete(:amount)
            self.ticket= @ticket
            self.currency= options.delete(:currency)

            @params['test'] = "yes" if ActiveMerchant::Billing::Base.integration_mode == :test

          end

          def ticket=( ticket )
            @params['ticket'] = ticket
          end

          def account( account )
            @params['account'] = account
          end

          def transaction_id
            @response['transact']
          end

          def currency
            @params['currency']
          end

          def gross_cents
            @params['amount'].to_i
          end

          def test?
            ActiveMerchant::Billing::Base.integration_mode == :test
          end

          def reason_code
            @response['reason'].to_i
          end

          def reason
            AUTH_REASON_CODES[reason_code]
          end
          def security_key
            @response['authkey']
          end

          def complete?
            "APPROVED" == status()
          end

          def potential_fraud?
            "POTENTIAL_FRAUD" == status()
          end

          def status
            return "POTENTIAL_FRAUD" if @response.key?('suspect') && @response.key?('severity') && @response['severity'].to_i > 5
            return "DECLINED" if @response.key?("status") and @response["status"] == "DECLINED"
            return "APPROVED" if success?
            return "UNKNOWN"
          end

          def success?
            return false if @response.include?("status") and @response["status"] != "ACCEPTED"
            raise ArgumentError, "Missing security_key1 or security_key2." unless @key1 && @key2
            key = md5_authkey( @key1, @key2,
                               transaction_id(),
                               currency(),
                               gross_cents()
            )
            key_match = key.eql?(security_key())
            raise ActiveMerchant::Billing::Integrations::DibsFlexwin::Error, "Invalid authkey" unless key_match
            key_match
          end

          def capture_now( )
            @params['capturenow'] = "yes"
            capture
          end

private
          def capture
            @params['md5key'] = md5_checksum_ticket( @key1, @key2, @params['merchant'], @params['orderid'], @params['currency'], @params['amount'], @ticket )
            r = ssl_post( DibsFlexwin.recurring_url, @params.to_s,
              'User-Agent'     => "Active Merchant -- http://activemerchant.org"
            )
            @response = parse(r)
          end

          def currency=( currency_code )
            if currency_code.is_a?(Fixnum)
              @params['currency'] = currency_code
              return
            end
            raise StandardError, "Invalid currency code #{currency_code} specified." unless CURRENCY_CODES.include?(currency_code.to_s.downcase.to_sym)
            @params['currency'] = CURRENCY_CODES[currency_code.to_s.downcase.to_sym]
          end

          def parse(query_string)
            return {} if query_string.blank?

            query_string.split('&').inject({}) do |memo, chunk|
              next if chunk.empty?
              key, value = chunk.split('=', 2)
              next if key.empty?
              value = value.nil? ? nil : CGI.unescape(value)
              memo[CGI.unescape(key)] = value
              memo
            end
          end
        end
      end
    end
  end
end
