module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DibsFlexwin
        class Notification < ActiveMerchant::Billing::Integrations::Notification
          include RequiresParameters
          include Common

          self.production_ips = [ '85.236.67.1', '85.236.67.2' ]

          def initialize(post, options )
            requires!( options, :security_key1, :security_key2, :remote_ip, :currency, :amount)
            super
            @recurring = false
          end

          def recurring?
            @recurring
          end

          def complete?
            "APPROVED" == status()
          end

          def potential_fraud?
            "POTENTIAL_FRAUD" == status()
          end

          def status
            return "POTENTIAL_FRAUD" if params.key?('suspect') && params.key?('severity') && params['severity'].to_i > 5
            return "APPROVED" if acknowledge
            return "UNKNOWN"
          end

          def transaction_id
            params['transact']
          end

          def currency
            return @options[:currency] if @options[:currency].to_i > 0
            CURRENCY_CODES[@options[:currency].to_s.downcase.to_sym]
          end

          def amount
            gross_cents
          end

          # When was this payment received by the client.
          def received_at
            Time.now
          end

          def security_key
            params['authkey']
          end

          # the money amount we received in X.2 decimal.
          def gross
            sprintf("%.2f", gross_cents.to_f / 100)
          end

          def gross_cents
            @options[:amount].to_i
          end

          # Was this a test transaction?
          def test?
            ActiveMerchant::Billing::Base.integration_mode == :test
          end

          # Acknowledge the transaction to DibsFlexwin. This method has to be called after a new
          # apc arrives. DibsFlexwin will verify that all the information we received are correct and will return a
          # ok or a fail.
          #
          # Example:
          #
          #   def callback
          #     notification = DibsFlexwin::Notification.new( request.raw_post, {
          #       :remote_ip     => request.remote_ip,
          #       :merchant      => "testmerchant",
          #       :security_key1 => "this_is_key1",
          #       :security_key2 => "this_is_key2"
          #     })
          #
          #     begin
          #       notification.acknowledge
          #
          #       if notification.potential_fraud?
          #         logger.warn { "Got a potential fraud. Look into it." }
          #       elsif notification.complete?
          #         logger.info { "Got a completed notification, updated order and other stuff." }
          #       else
          #         logger.warn { "Transaction declined. #{notification.status()}"}
          #       end
          #
          #     rescue ActiveMerchant::Billing::Integrations::DibsFlexwin::Error => e
          #       logger.warn { "Got a DIBS error: #{e.message}" }
          #     rescue => e
          #       logger.warn("Illegal notification received: #{e.message}")
          #     ensure
          #       head(:ok)
          #     end
          #   end
          def acknowledge
            raise StandardError, "Invalid sender (#{@options[:remote_ip]})." unless valid_sender?(@options[:remote_ip])
            return true unless params.include?("authkey")
            raise ArgumentError, "Missing security_key1 or security_key2." unless @options[:security_key1] && @options[:security_key2]

            rkey = md5_authkey_preauth( @options[:security_key1], @options[:security_key2],
                                transaction_id(),
                                currency()
            )

            if (rkey.eql?(security_key()))
              @recurring = true
              return true
            end

            key = md5_authkey( @options[:security_key1], @options[:security_key2],
                                transaction_id(),
                                currency(),
                                gross_cents()
            )

            key_match = key.eql?(security_key())
            raise ActiveMerchant::Billing::Integrations::DibsFlexwin::Error, "Invalid authkey" unless key_match

            key_match
          end
 private

          # Take the posted data and move the relevant data into a hash
          def parse(post)
            @raw = post
            for line in post.split('&')
              key, value = *line.scan( %r{^(\w+)\=(.*)$} ).flatten
              params[key] = value
            end
          end
        end
      end
    end
  end
end
