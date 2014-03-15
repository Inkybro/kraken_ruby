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
      raise ArgumentError if !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:asset] = comma_delimit(*args)
      end
      get_public 'Assets', opts
    end

    def asset_pairs(*args)
      raise ArgumentError if !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = comma_delimit(*args)
      end
      get_public 'AssetPairs', opts
    end

    def ticker(*args)
      raise ArgumentError if !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = comma_delimit(*args)
      else
        raise ArgumentError
      end
      get_public 'Ticker', opts
    end
    
    def ohlc(*args)
      raise ArgumentError if !single_string_arg?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = args.shift
      else
        raise ArgumentError
      end
      get_public 'OHLC', opts
    end
    
    def order_book(*args)
      raise ArgumentError if !single_string_arg?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = args.shift
      else
        raise ArgumentError
      end
      get_public 'Depth', opts
    end

    def trades(*args)
      raise ArgumentError if !single_string_arg?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = args.shift
      else
        raise ArgumentError
      end
      get_public 'Trades', opts
    end

    def spread(*args)
      raise ArgumentError if !single_string_arg?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = args.shift
      else
        raise ArgumentError
      end
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

    def balance
      post_private 'Balance', {}
    end

    def trade_balance(*args)
      raise ArgumentError if args.count > 2 || !single_string_arg?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      opts[:asset] = args.shift
      post_private 'TradeBalance', opts
    end

    def open_orders(*args)
      opts = arg_opts(*args)
      post_private 'OpenOrders', opts
    end
    
    def closed_orders(*args)
      opts = arg_opts(*args)
      post_private 'ClosedOrders', opts
    end

    def query_orders(*args)
      raise ArgumentError if args.empty? || !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if args.count >= 1 && args.count <= 20
        opts[:txid] = comma_delimit(*args)
      else
        raise ArgumentError
      end
      post_private 'QueryOrders', opts
    end

    def trade_history(*args)
      opts = arg_opts(*args)
      post_private 'TradesHistory', opts
    end

    def query_trades(*args)
      raise ArgumentError if args.empty? || !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if args.count >= 1 && args.count <= 20
        opts[:txid] = comma_delimit(*args)
      else
        raise ArgumentError
      end
      post_private 'QueryTrades', opts
    end

    def open_positions(*args)
      raise ArgumentError if args.empty? || !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if args.count >= 1
        opts[:txid] = comma_delimit(*args)
      else
        raise ArgumentError
      end
      post_private 'OpenPositions', opts
    end

    def ledgers_info(*args)
      opts = arg_opts(*args)
      post_private 'Ledgers', opts
    end

    def query_ledgers(*args)
      raise ArgumentError if args.empty? || !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if args.count >= 1 && args.count <= 20
        opts[:id] = comma_delimit(*args)
      else
        raise ArgumentError
      end
      post_private 'QueryLedgers', opts
    end

    def trade_volume(*args)
      raise ArgumentError if !args_only_strings?(*args)
      opts = arg_opts(*args)
      args = arg_vals(*args)
      if !args.empty?
        opts[:pair] = comma_delimit(*args)
      end
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
      
      #FUNDAMENTAL TASKS:
      
      def args_only_strings?(*args)
        args = arg_vals(*args)
        args.each do |arg|
          return false if !arg.is_a?(String) && !arg.is_a?(Symbol)
        end
        true
      end
      
      def single_string_arg?(*args)
        args = arg_vals(*args)
        if args.count > 1
          return false
        elsif args.count == 1
          return false if !args.first.is_a?(String) && !args.first.is_a?(Symbol)
        end
        true
      end
      
      def arg_opts(*args)
        if args.last.is_a?(Hash)
          args.pop
        else
          {}
        end
      end
      
      def arg_vals(*args)
        if args.last.is_a?(Hash)
          args.pop
        end
        args
      end
      
      def comma_delimit(*values)
        values = arg_vals(*values)
        str = values.shift.to_s
        values.each do |value|
          raise ArgumentError if !value.is_a?(String) && !value.is_a?(Symbol)
          str += ",#{value.to_s}"
        end
        str
      end

  end
end
