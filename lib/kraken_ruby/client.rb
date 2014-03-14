require 'httparty'
require 'hashie'
require 'base64' # <--- had to change this from "require 'Base64'"; getting "load error"
require 'addressable/uri'


module Kraken
  class Client
    include HTTParty

    def initialize(api_key=nil, api_secret=nil, options={})
      @api_key      = api_key
      @api_secret   = api_secret
      @api_version  = options[:version] ||= '0'
      @base_uri     = options[:base_uri] ||= 'https://api.kraken.com'
    end
    
    ###########################
    ###### Fundamentals #######
    ###########################
    def api_version
      @api_version
    end

    ###########################
    ###### Public Data ########
    ###########################

    def server_time
      get_public 'Time'
    end

    def assets(*args)
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      if !args.empty?
        opts[:asset] = comma_delimit(*args)
      end
      get_public 'Assets', opts
    end

    def asset_pairs(*args)
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      if !args.empty?
        args.each do |arg|
          raise ArgumentError if !arg.is_a?(String) && !arg.is_a?(Symbol)
        end
        opts[:pair] = comma_delimit(*args)
      end
      get_public 'AssetPairs', opts
    end

    def ticker(*args)
      raise ArgumentError if args.empty?
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      args.each do |arg|
        raise ArgumentError if !arg.is_a?(String) && !arg.is_a?(Symbol)
      end
      opts[:pair] = comma_delimit(*args)
      get_public 'Ticker', opts
    end
    
    def ohlc(*args)
      raise ArgumentError if args.empty? || args.count > 2
      raise ArgumentError if !args.first.is_a?(String) && !args.first.is_a?(Symbol)
      raise ArgumentError if args.count == 2 && !args.last.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      opts[:pair] = args.shift
      get_public 'OHLC', opts
    end
    
    def order_book(*args)
      raise ArgumentError if args.empty? || args.count > 2
      raise ArgumentError if !args.first.is_a?(String) && !args.first.is_a?(Symbol)
      raise ArgumentError if args.count == 2 && !args.last.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      opts[:pair] = args.shift
      get_public 'Depth', opts
    end

    def trades(*args)
      raise ArgumentError if args.empty? || args.count > 2
      raise ArgumentError if !args.first.is_a?(String) && !args.first.is_a?(Symbol)
      raise ArgumentError if args.count == 2 && !args.last.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      opts[:pair] = args.shift
      get_public 'Trades', opts
    end

    def spread(*args)
      raise ArgumentError if args.empty? || args.count > 2
      raise ArgumentError if !args.first.is_a?(String) && !args.first.is_a?(Symbol)
      raise ArgumentError if args.count == 2 && !args.last.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      opts[:pair] = args.shift
      get_public 'Spread', opts
    end

    def get_public(method, opts={})
      url = @base_uri + '/' + @api_version + '/public/' + method
      r = self.class.get(url, query: opts)
      hash = Hashie::Mash.new(JSON.parse(r.body))
      hash[:result]
    end

    ######################
    ##### Private Data ###
    ######################

    def balance#(opts={})
      post_private 'Balance', {} #opts
    end

    def trade_balance(*args)
      raise ArgumentError if args.count > 2
      raise ArgumentError if args.count == 2 && !args.last.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      if args.first.is_a?(String) || args.first.is_a?(Symbol)
        opts[:asset] = args.shift
      end
      post_private 'TradeBalance', opts
    end

    def open_orders(*args)
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      post_private 'OpenOrders', opts
    end
    
    def closed_orders(*args)
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      post_private 'ClosedOrders', opts
    end

    def query_orders(*args)
      raise ArgumentError if args.empty? || args.first.is_a?(Hash)
      
      if args.last.is_a?(Hash)
        opts = args.pop
      else
        opts = {}
      end
      if !args.empty?
        args.each do |arg|
          raise ArgumentError if !arg.is_a?(String) && !arg.is_a?(Symbol)
        end
        opts[:txid] = comma_delimit(*args)
      end
      post_private 'QueryOrders', opts
    end

    def trade_history(opts={})
      post_private 'TradesHistory', opts
    end

    def query_trades(tx_ids, opts={})
      opts['txid'] = tx_ids
      post_private 'QueryTrades', opts
    end

    def open_positions(tx_ids, opts={})
      opts['txid'] = tx_ids
      post_private 'OpenPositions', opts
    end

    def ledgers_info(opts={})
      post_private 'Ledgers', opts
    end

    def query_ledgers(ledger_ids, opts={})
      opts['id'] = ledger_ids
      post_private 'QueryLedgers', opts
    end

    def trade_volume(asset_pairs)
      opts['pair'] = asset_pairs
      post_private 'TradeVolume', opts
    end

    #### Private User Trading (Still experimental!) ####

    def add_order(opts={})
      required_opts = %w{pair, type, ordertype, volume}
      opts.keys.each do |key|
        unless required_opts.include?(1) 
          raise "Required options, not given. Input must include #{required_opts}"
        end
      end
      post_private 'AddOrder', opts
    end
    
    def cancel_order(opts={})
      # TODO: write me
    end

    #######################
    #### Generate Signed ##
    ##### Post Request ####
    #######################

    private

      def post_private(method, opts={})
        opts['nonce'] = nonce
        post_data = encode_options(opts)

        headers = {
          'API-Key' => @api_key,
          'API-Sign' => generate_signature(method, post_data, opts) 
        }

        url = @base_uri + url_path(method)
        r = self.class.post(url, { headers: headers, body: post_data }).parsed_response
        r['error'].empty? ? Hashie::Mash.new(r['result']) : r['error']
      end

      def nonce
        # no need to sleep, pretty sure... just needed to take into account
        # time on a smaller scale (hence Time.now.to_f * 10000). apparently
        # .to_f on Time instances returns a fractional timestamp.
        # this all ensures the numbers are increasing quickly enough to
        # constitute a valid nonce.
        (Time.now.to_f*10000000).to_i.to_s.ljust(16,'0')
      end

      def encode_options(opts)
        uri = Addressable::URI.new
        uri.query_values = opts
        uri.query
      end

      def generate_signature(method, post_data, opts={})
        key = Base64.decode64(@api_secret)
        message = generate_message(method, opts, post_data)
        generate_hmac(key, message)
      end

      def generate_message(method, opts, data)
        digest = OpenSSL::Digest.new('sha256', opts['nonce'].to_s + data).digest
        url_path(method) + digest
      end

      def generate_hmac(key, message)
        Base64.strict_encode64(OpenSSL::HMAC.digest('sha512', key, message))
      end

      def url_path(method)
        '/' + @api_version + '/private/' + method
      end
      
      def arg_vals(*args)
        
      end
      
      def arg_opts(*args)
        
      end
      
      def comma_delimit(*values)
        str = values.shift.to_s
        values.each do |value|
          raise ArgumentError if !value.is_a?(String) && !value.is_a?(Symbol)
          str += ",#{value.to_s}"
        end
        str
      end

  end
end
