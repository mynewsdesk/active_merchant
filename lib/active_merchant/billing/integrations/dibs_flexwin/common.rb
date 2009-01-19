require 'digest/md5'

module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module DibsFlexwin
        module Common

          # This is used to generate the md5 sent to DIBS
          def md5_checksum( key1, key2, merchant, orderid, currency, amount )
            Digest::MD5.hexdigest( key2 +
              Digest::MD5.hexdigest( key1 +
                "merchant=#{merchant}&orderid=#{orderid}&currency=#{currency}&amount=#{amount}"
              )
            )
          end

          # This is used to check the md5 received from DIBS
          def md5_authkey( key1, key2, transact,currency, amount)
            Digest::MD5.hexdigest( key2 +
              Digest::MD5.hexdigest( key1 + "transact=#{transact}&amount=#{amount}&currency=#{currency}")
            )
          end

          CURRENCY_CODES = {
            :dkk  => '208',
            :eur  => '978',
            :usd  => '840',
            :gbp  => '826',
            :sek  => '752',
            :aud  => '036',
            :cad  => '124',
            :isk  => '352',
            :jpy  => '392',
            :nzd  => '554',
            :nok  => '578',
            :chf  => '756',
            :try  => '949'
          }.with_indifferent_access

          LANGUAGE_CODES = {
            :da => "Danish (default)",
            :sv => "Swedish",
            :no => "Norwegian",
            :en => "English",
            :nl => "Dutch",
            :de => "German",
            :fr => "French",
            :fi => "Finnish",
            :es => "Spanish",
            :it => "Italian",
            :fo => "Faroese",
            :pl => "Polish"
          }.with_indifferent_access

          TERMINAL_COLORS = {
            :sand => "sand",
            :grey => "grey",
            :blue => "blue"
          }.with_indifferent_access

          DECORATOR_TYPES = {
            :default => "Description",
            :basal => "Description",
            :rich => "Description"
          }.with_indifferent_access

          PAYMENT_METHODS = {
            # For credit card transactions the parameter paytype
            # attains one of the following values:
            'ACCEPT'     => 'Accept card',
            'ACK'        => 'Albertslund Centrum Kundekort',
            'AMEX'       => 'American Express',
            'AMEX(DK)'   => 'American Express (Danish card)',
            'BHBC'       => 'Bauhaus Best card',
            'CCK'        => 'Computer City Customer Card',
            'CKN'        => 'CityKort Næstved',
            'COBK'       => 'COOP Bank Card',
            'DIN'        => 'Diners Club',
            'DIN(DK)'    => 'Diners Club (Danish card)',
            'DK'         => 'Dankort',
            'ELEC VISA'  => 'Electron (Danish card)',
            'EWORLD'     => 'Electronic World Credit Card',
            'FCC'        => 'Ford Credit Card',
            'FCK'        => 'Frederiksberg Centret Kundekort',
            'FFK'        => 'Forbrugsforeningen Card',
            'FSC'        => 'Fisketorvet Shopping Card',
            'FSBK'       => 'Frispar Bank card',
            'FSSBK'      => 'FöreningsSparbanken Bank card',
            'GSC'        => 'Glostrup Shopping Card',
            'GRA'        => 'Graphium',
            'HBSBK'      => 'Handelsbanken Bank card',
            'HMK'        => 'HM Konto (Hennes og Mauritz)',
            'ICASBK'     => 'ICA Bank card',
            'IBC'        => 'Inspiration Best Card',
            'IKEA'       => 'IKEA kort',
            'JPSBK'      => 'JP Bankkort',
            'JCB'        => 'JCB (Japan Credit Bureau)',
            'LIC(DK)'    => 'Lærernes IndkøbsCentral (Denmark)',
            'LIC(SE)'    => 'Lærernes IndkøbsCentral (Sweden)',
            'MC'         => 'Mastercard',
            'MC(DK)'     => 'Mastercard (Danish card)',
            'MC(SE)'     => 'Mastercard (Swedish card)',
            'MTRO'       => 'Maestro',
            'MTRO(DK)'   => 'Maestro (Danish card)',
            'MEDM'       => 'Medmera card',
            'MERLIN(DK)' => 'Merlin Credit card (Danish card)',
            'MOCA'       => 'Mobilcash',
            'NSBK'       => 'Nordea Bank card',
            'OESBK'      => 'Östgöta Enskilda bank card',
            'PGSBK'      => 'PostGirot Bank card',
            'Q8SK'       => 'Q8 Service card',
            'Q8LIC'      => 'Q8 Service card',
            'RK'         => 'Rejsekonto',
            'SLV'        => 'Silvan card',
            'SBSBK'      => 'Skandiabanken Bank card',
            'S/T'        => 'Spies/Tjæreborg card',
            'SBC'        => 'Spies Best Card',
            'SBK'        => 'Swedish bank card',
            'SEBSBK'     => 'Swedish bank card (SEB)',
            'TKTD'       => 'Tjæreborg Customer card',
            'TUBC'       => 'Toys R Us - BestCard',
            'TLK'        => 'Tæppeland card',
            'VSC'        => 'Vestsjællandscentret card',
            'V-DK'       => 'VISA/Dankort',
            'VEKO'       => 'VEKO card (Danish card)',
            'VISA'       => 'VISA card',
            'VISA(DK)'   => 'VISA (Danish card)',
            'VISA(SE)'   => 'VISA (Swedish card)',
            'ELEC'       => 'VISA Electron (Danish card)',
            'WOCO'       => 'Wonderful Copenhagen Card',
            'AAK'        => 'Århus City Card',

            # For non-credit card transactions the parameter paytype
            # attains one of the following values:

            :ABN         => 'ABN AMRO iDeal Payment',
            :AKTIA       => 'Aktia Web Payment',
            :DNB         => 'Danske Netbetaling (Danske Bank)',
            :EDK         => 'eDankort',
            :ELV         => 'Bank Einzug (eOLV)',
            :EW          => 'eWire',
            :FSB         => 'Swedbank Direktbetalning',
            :GIT         => 'Getitcard',
            :ING         => 'ING iDeal Payment',
            :NDB         => 'Nordea Solo-E betaling (Sweden)',
            :SEB         => 'SEB Direktbetalning',
            :SHB         => 'SHB Direktbetalning',
            :SOLO        => 'Nordea Solo-E betaling',
            :VAL         => 'Valus'
          }.with_indifferent_access
        end
      end
    end
  end
end
