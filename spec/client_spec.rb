require 'kraken_ruby'
require 'kraken_key'

describe Kraken::Client do

  let(:kraken){ Kraken::Client.new(API_KEY, API_SECRET) }
  
  it "returns the API version being used" do
    expect(kraken).to respond_to :api_version
    expect(kraken.api_version).to eq kraken.instance_eval { @api_version }
  end
  
  context "fetching public data" do
    context "using server_time()" do
      it "gets the correct time from Kraken" do
        result = Time.parse(kraken.server_time.rfc1123)
        time_difference_in_seconds = (result-Time.now.getutc).abs
        expect(time_difference_in_seconds).to be < 3
      end
      
      it "does not accept input" do
        expect { kraken.server_time(1234) }.to raise_error(ArgumentError)
      end
    end
    
    context "using assets()" do
      it "gets all assets" do
        result = kraken.assets
        expect(result).to respond_to :XLTC
        expect(result).to respond_to :XNMC
        expect(result).to respond_to :XXBT
        expect(result).to respond_to :XXDG
        expect(result).to respond_to :XXRP
        expect(result).to respond_to :XXVN
        expect(result).to respond_to :ZEUR
        expect(result).to respond_to :ZGBP
        expect(result).to respond_to :ZKRW
        expect(result).to respond_to :ZUSD
      end
      
      it "gets specified assets" do
        result = kraken.assets(:XLTC, :XXDG)
        expect(result).to respond_to :XLTC
        expect(result).to respond_to :XXDG
        expect(result).not_to respond_to :XNMC
        expect(result).not_to respond_to :XXBT
        expect(result).not_to respond_to :XXRP
        expect(result).not_to respond_to :XXVN
        expect(result).not_to respond_to :ZEUR
        expect(result).not_to respond_to :ZGBP
        expect(result).not_to respond_to :ZKRW
        expect(result).not_to respond_to :ZUSD
      end

      it "only accepts string/symbol values as assets" do
        expect { kraken.assets(:XXDG, 'XXBT')}.not_to raise_error#(ArgumentError)
        expect { kraken.assets(1234) }.to raise_error(ArgumentError)
        expect { kraken.assets([]) }.to raise_error(ArgumentError)
        expect { kraken.assets(:XXDG, 1234) }.to raise_error(ArgumentError)
        expect { kraken.assets([], :XXBT) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid assets" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using asset_pairs()" do
      it "gets all asset pairs" do
        result = kraken.asset_pairs
        expect(result).to respond_to :XLTCXXDG
        expect(result).to respond_to :XLTCXXRP
        expect(result).to respond_to :XLTCZEUR
        expect(result).to respond_to :XLTCZKRW
        expect(result).to respond_to :XLTCZUSD
        expect(result).to respond_to :XNMCXXDG
        expect(result).to respond_to :XNMCXXRP
        expect(result).to respond_to :XNMCZEUR
        expect(result).to respond_to :XNMCZKRW
        expect(result).to respond_to :XNMCZUSD
        expect(result).to respond_to :XXBTXLTC
        expect(result).to respond_to :XXBTXNMC
        expect(result).to respond_to :XXBTXXDG
        expect(result).to respond_to :XXBTXXRP
        expect(result).to respond_to :XXBTXXVN
        expect(result).to respond_to :XXBTZEUR
        expect(result).to respond_to :XXBTZKRW
        expect(result).to respond_to :XXBTZUSD
        expect(result).to respond_to :XXVNXXRP
        expect(result).to respond_to :ZEURXXDG
        expect(result).to respond_to :ZEURXXRP
        expect(result).to respond_to :ZEURXXVN
        expect(result).to respond_to :ZKRWXXRP
        expect(result).to respond_to :ZUSDXXDG
        expect(result).to respond_to :ZUSDXXRP
        expect(result).to respond_to :ZUSDXXVN
      end
    
      it "gets specified asset pairs" do
        result = kraken.asset_pairs(:XLTCXXDG, :XLTCXXRP)
        expect(result).to respond_to :XLTCXXDG
        expect(result).to respond_to :XLTCXXRP
        expect(result).not_to respond_to :XLTCZEUR
        expect(result).not_to respond_to :XLTCZKRW
        expect(result).not_to respond_to :XLTCZUSD
        expect(result).not_to respond_to :XNMCXXDG
        expect(result).not_to respond_to :XNMCXXRP
        expect(result).not_to respond_to :XNMCZEUR
        expect(result).not_to respond_to :XNMCZKRW
        expect(result).not_to respond_to :XNMCZUSD
        expect(result).not_to respond_to :XXBTXLTC
        expect(result).not_to respond_to :XXBTXNMC
        expect(result).not_to respond_to :XXBTXXDG
        expect(result).not_to respond_to :XXBTXXRP
        expect(result).not_to respond_to :XXBTXXVN
        expect(result).not_to respond_to :XXBTZEUR
        expect(result).not_to respond_to :XXBTZKRW
        expect(result).not_to respond_to :XXBTZUSD
        expect(result).not_to respond_to :XXVNXXRP
        expect(result).not_to respond_to :ZEURXXDG
        expect(result).not_to respond_to :ZEURXXRP
        expect(result).not_to respond_to :ZEURXXVN
        expect(result).not_to respond_to :ZKRWXXRP
        expect(result).not_to respond_to :ZUSDXXDG
        expect(result).not_to respond_to :ZUSDXXRP
        expect(result).not_to respond_to :ZUSDXXVN
      end
    
      it "only accepts string/symbol values as asset pairs" do
        expect { kraken.asset_pairs(:XLTCXXDG, 'XLTCXXRP')}.not_to raise_error#(ArgumentError)
        expect { kraken.asset_pairs(1234) }.to raise_error(ArgumentError)
        expect { kraken.asset_pairs([]) }.to raise_error(ArgumentError)
        expect { kraken.asset_pairs(:XLTCXXDG, 1234) }.to raise_error(ArgumentError)
        expect { kraken.asset_pairs([], :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using ticker()" do
      it "gets ticker data for specified asset pairs" do
        result = kraken.ticker(:XLTCXXDG, :ZEURXXDG)
        expect(result).to respond_to :XLTCXXDG
        expect(result).to respond_to :ZEURXXDG
      end
      
      it "must be passed a set of asset pairs" do
        expect { kraken.ticker }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as asset pairs" do
        expect { kraken.ticker(:XLTCXXDG, 'XLTCXXRP')}.not_to raise_error#(ArgumentError)
        expect { kraken.ticker(1234) }.to raise_error(ArgumentError)
        expect { kraken.ticker([]) }.to raise_error(ArgumentError)
        expect { kraken.ticker(:XLTCXXDG, 1234) }.to raise_error(ArgumentError)
        expect { kraken.ticker([], :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using ohlc()" do
      it "gets OHLC data for an asset pair" do
        result = kraken.ohlc(:XLTCXXDG)
        expect(result).to respond_to :XLTCXXDG
        expect(result.XLTCXXDG).to be_instance_of(Array)
        expect(result).to respond_to :last
      end
      
      it "must be passed exactly 1 asset pair" do
        expect { kraken.ohlc }.to raise_error(ArgumentError)
        expect { kraken.ohlc(:XLTCXXDG, :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as the asset pair" do
        expect { kraken.ohlc(:XLTCXXDG) }.not_to raise_error
        expect { kraken.ohlc('XLTCXXRP') }.not_to raise_error
        expect { kraken.ohlc(1234) }.to raise_error(ArgumentError)
        expect { kraken.ohlc([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using order_book()" do
      it "gets order book data for a given asset pair" do
        result = kraken.order_book(:XLTCXXDG)
        expect(result).to respond_to :XLTCXXDG
        expect(result.XLTCXXDG).to respond_to :asks
        expect(result.XLTCXXDG).to respond_to :bids
      end
      
      it "must be passed exactly 1 asset pair" do
        expect { kraken.order_book }.to raise_error(ArgumentError)
        expect { kraken.order_book(:XLTCXXDG, :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as the asset pair" do
        expect { kraken.order_book(:XLTCXXDG) }.not_to raise_error
        expect { kraken.order_book('XLTCXXRP') }.not_to raise_error
        expect { kraken.order_book(1234) }.to raise_error(ArgumentError)
        expect { kraken.order_book([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using trades()" do
      it "gets recent trades for a given asset pair" do
        result = kraken.trades('XLTCXXDG')
        expect(result).to respond_to :XLTCXXDG
        expect(result.XLTCXXDG).to be_instance_of(Array)
      end
      
      it "must be passed exactly 1 asset pair" do
        expect { kraken.trades }.to raise_error(ArgumentError)
        expect { kraken.trades(:XLTCXXDG, :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as the asset pair" do
        expect { kraken.trades(:XLTCXXDG) }.not_to raise_error
        expect { kraken.trades('XLTCXXRP') }.not_to raise_error
        expect { kraken.trades(1234) }.to raise_error(ArgumentError)
        expect { kraken.trades([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using spread()" do
      it "gets the spread for a given asset pair" do
        result = kraken.spread(:XLTCXXDG)
        expect(result).to respond_to :XLTCXXDG
        expect(result.XLTCXXDG).to be_instance_of(Array)
      end
      
      it "must be passed exactly 1 asset pair" do
        expect { kraken.spread }.to raise_error(ArgumentError)
        expect { kraken.spread(:XLTCXXDG, :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as the asset pair" do
        expect { kraken.spread(:XLTCXXDG) }.not_to raise_error
        expect { kraken.spread('XLTCXXRP') }.not_to raise_error
        expect { kraken.spread(1234) }.to raise_error(ArgumentError)
        expect { kraken.spread([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
  end

  context "fetching private data" do
    context "using balance()" do
      it "gets the user's balance(s) in ZUSD" do
        expect(kraken.balance).to be_instance_of(Hashie::Mash)
      end
      
      it "does not accept input" do
        expect { kraken.balance(1234) }.to raise_error(ArgumentError)
      end
    end
    
    context "using trade_balance()" do
      it "gets the user's trade balance(s)" do
        zusd = kraken.trade_balance
        expect(zusd).to be_instance_of(Hashie::Mash)
        xxdg = kraken.trade_balance('XXDG')
        expect(xxdg).to be_instance_of(Hashie::Mash)
        expect(zusd).not_to eq xxdg
      end
      
      it "accepts no more than 1 asset" do
        expect { kraken.spread(:XLTCXXDG, :XLTCXXRP) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as the asset" do
        expect { kraken.spread(:XLTCXXDG) }.not_to raise_error
        expect { kraken.spread('XLTCXXRP') }.not_to raise_error
        expect { kraken.spread(1234) }.to raise_error(ArgumentError)
        expect { kraken.spread([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
    
    context "using open_orders()" do
      it "gets a list of the user's open orders" do
        result = kraken.open_orders
        expect(result).to be_instance_of(Hashie::Mash)
        expect(result[:open]).to be_instance_of(Hashie::Mash)
      end
    end
    
    context "using closed_orders()" do
      it "gets a list of the user's closed orders" do
        result = kraken.closed_orders
        expect(result).to be_instance_of(Hashie::Mash)
        expect(result[:closed]).to be_instance_of(Hashie::Mash)
      end
    end
    
    context "using query_orders()" do
      it "gets queried orders" do
        # TODO: write me
      end
      
      it "must be passed a set of 1-20 transaction IDs" do
        expect { kraken.query_orders }.to raise_error(ArgumentError)
        expect { kraken.query_orders({:abc => 123}) }.to raise_error(ArgumentError)
        expect { kraken.query_orders(:a) }.not_to raise_error
        expect { kraken.query_orders(:a, {:abc => 123}) }.not_to raise_error
        expect { kraken.query_orders(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t) }.not_to raise_error
        expect { kraken.query_orders(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t,:u) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as transaction IDs" do
        expect { kraken.query_orders(1) }.to raise_error(ArgumentError)
        expect { kraken.query_orders(:a, 2) }.to raise_error(ArgumentError)
        expect { kraken.query_orders({}, []) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid transaction IDs" do
        # TODO: write me
      end
    end
    
    context "using trade_history()" do
      it "gets a list of the trade history" do
        # TODO: write me
        # FIXME: I can't play w/ this enough in IRB -- using it gives me 'Invalid Nonce' every time.
      end
    end
    
    context "using query_trades()" do
      it "gets queried trades" do
        # TODO: write me
      end
      
      it "must be passed a set of 1-20 transaction IDs" do
        expect { kraken.query_trades }.to raise_error(ArgumentError)
        expect { kraken.query_trades({:abc => 123}) }.to raise_error(ArgumentError)
        expect { kraken.query_trades(:a) }.not_to raise_error
        expect { kraken.query_trades(:a, {:abc => 123}) }.not_to raise_error
        expect { kraken.query_trades(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t) }.not_to raise_error
        expect { kraken.query_trades(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t,:u) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as transaction IDs" do
        expect { kraken.query_trades(1) }.to raise_error(ArgumentError)
        expect { kraken.query_trades(:a, 2) }.to raise_error(ArgumentError)
        expect { kraken.query_trades({}, []) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid transaction IDs" do
        # TODO: write me
      end
    end
    
    context "using open_positions()" do
      it "gets a list of the user's open positions" do
        # TODO: write me
      end
      
      it "must be passed a set of >=1 transaction IDs" do
        expect { kraken.open_positions }.to raise_error(ArgumentError)
        expect { kraken.open_positions({:abc => 123}) }.to raise_error(ArgumentError)
        expect { kraken.open_positions(:a) }.not_to raise_error
        expect { kraken.open_positions(:a, {:abc => 123}) }.not_to raise_error
        expect { kraken.open_positions(:a,:b,:c,) }.not_to raise_error
        expect { kraken.open_positions(:a,:b,:c, {:abc => 123}) }.not_to raise_error
      end
      
      it "only accepts string/symbol values as transaction IDs" do
        expect { kraken.open_positions(1) }.to raise_error(ArgumentError)
        expect { kraken.open_positions(:a, 2) }.to raise_error(ArgumentError)
        expect { kraken.open_positions({}, []) }.to raise_error(ArgumentError)
      end
    end
    
    context "using ledgers_info()" do
      it "gets a list of ledgers info" do
        # TODO: write me
        # FIXME: I can't play w/ this enough in IRB -- using it gives me 'Invalid Nonce' every time.
      end
    end
    
    context "using query_ledgers()" do
      it "gets a list of the queried ledgers" do
        # TODO: write me
      end
      
      it "must be passed a set of 1-20 ledger IDs" do
        expect { kraken.query_ledgers }.to raise_error(ArgumentError)
        expect { kraken.query_ledgers({:abc => 123}) }.to raise_error(ArgumentError)
        expect { kraken.query_ledgers(:a) }.not_to raise_error
        expect { kraken.query_ledgers(:a, {:abc => 123}) }.not_to raise_error
        expect { kraken.query_ledgers(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t) }.not_to raise_error
        expect { kraken.query_ledgers(:a,:b,:c,:d,:e,:f,:g,:h,:i,:j,:k,:l,:m,:n,:o,:p,:q,:r,:s,:t,:u) }.to raise_error(ArgumentError)
      end
      
      it "only accepts string/symbol values as ledger IDs" do
        expect { kraken.query_ledgers(1) }.to raise_error(ArgumentError)
        expect { kraken.query_ledgers(:a, 2) }.to raise_error(ArgumentError)
        expect { kraken.query_ledgers({}, []) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid ledger IDS" do
        # TODO: write me
      end
    end
    
    context "using trade_volume()" do
      it "gets a list of trade volumes" do
        # TODO: write me
      end
      
      it "only accepts string/symbol values as the asset pair" do
        expect { kraken.trade_volume(:XLTCXXDG) }.not_to raise_error
        expect { kraken.trade_volume('XLTCXXRP') }.not_to raise_error
        expect { kraken.trade_volume(1234) }.to raise_error(ArgumentError)
        expect { kraken.trade_volume([]) }.to raise_error(ArgumentError)
      end
      
      it "only allows valid asset pairs" do
        # TODO: implement w/ regex: /(?:X(?:LTC|X(?:DG|BT|RP|VN)|NMC)|Z(?:EUR|GBP|KRW|USD))/ix
      end
    end
  end
  
  context "conducting private user trading" do
    context "using add_order()" do
      # TODO: write me
    end
    
    context "using cancel_order()" do
      # TODO: write me
    end
  end
  
  context "handling fundamental tasks" do
    context "using args_only_strings?()" do
      it "verifies that *args are all strings or symbols" do
        expect(kraken.send(:args_only_strings?, :a, :b, 'c', :d, 'e')).to eq true
        expect(kraken.send(:args_only_strings?, :a, :b, 'c', :d, 'e', {:abc => 123})).to eq true
        expect(kraken.send(:args_only_strings?, :a, :b, 'c', 1, 2.3)).to eq false
        expect(kraken.send(:args_only_strings?, :a, :b, 'c', {}, [])).to eq false
      end
    end
    
    context "using single_string_arg?()" do
      it "verifies that only a SINGLE string or symbol was passed" do
        expect(kraken.send(:single_string_arg?, :a)).to eq true
        expect(kraken.send(:single_string_arg?, :a, {:abc => 123})).to eq true
        expect(kraken.send(:single_string_arg?, 'b')).to eq true
        expect(kraken.send(:single_string_arg?, 'b', {:abc => 123})).to eq true
        expect(kraken.send(:single_string_arg?, :a, 'b')).to eq false
        expect(kraken.send(:single_string_arg?, 'a', :b, {:abc => 123})).to eq false
        expect(kraken.send(:single_string_arg?, 1)).to eq false
        expect(kraken.send(:single_string_arg?, 1, 2.3)).to eq false
        expect(kraken.send(:single_string_arg?, 1, 2.3, {})).to eq false
        expect(kraken.send(:single_string_arg?, [], {})).to eq false
        expect(kraken.send(:single_string_arg?, {}, [])).to eq false
      end
    end
    
    context "using arg_vals()" do
      it "extracts string/symbol parameters from *args" do
        expect(kraken.send(:arg_vals, :a, :b, :c, {:abc => 123})).to be_instance_of(Array)
        expect(kraken.send(:arg_vals, :a, :b, :c, {:abc => 123})).to eq [:a, :b, :c]
      end
    end
    
    context "using arg_opts()" do
      it "extracts opts hash from *args" do
        expect(kraken.send(:arg_opts, :a, :b, :c, {:abc => 123})).to be_instance_of(Hash)
        expect(kraken.send(:arg_opts, :a, :b, :c, {:abc => 123}).count).to eq 1
        expect(kraken.send(:arg_opts, :a, :b, :c, {:abc => 123})[:abc]).to eq 123
        expect(kraken.send(:arg_opts, :a, :b, :c)).to be_instance_of(Hash)
        expect(kraken.send(:arg_opts, :a, :b, :c).count).to eq 0
      end
    end
    
    context "using comma_delimit()" do
      it "comma-delimits strings" do
        expect(kraken.send(:comma_delimit, :a, :b, :c)).to eq 'a,b,c'
      end
    end
    
    # TODO: contextualize the following methods
    it "encodes option hashes" do
      opts = {:a => 1, :b => 2, :c => 3}
      expect(kraken.send(:encode_options, opts)).to eq 'a=1&b=2&c=3'
    end
    
    it "generates url paths" do
      expect(kraken.send(:url_path, 'SomeMethod')).to eq "/#{kraken.api_version}/private/SomeMethod"
    end
    
    it "generates nonces" do
      last_nonce = 0
      (1..1000).each do |n|
        this_nonce = kraken.send(:nonce).to_i
        expect(this_nonce).to be > last_nonce 
        last_nonce = this_nonce
      end
    end
    
    it "generates signatures" do
      opts = { 'nonce' => '123456789' }
      expect(kraken.send(:generate_signature, 'SomeMethod', 'abc', opts)).to eq 'HWp0Zv0vfX6BrNbGcguIdaNjn0XPQyl/FCduD+B92/vexmVv3+YpZCEN99vIzxKCI2962z2/9pjbIuct3iyJyQ=='
    end
    
    it "generates messages" do
      opts = { 'nonce' => '123456789' }
      expect(kraken.send(:generate_message, 'SomeMethod', opts, 'abc')).to eq "/0/private/SomeMethodC\x90\x87H-!\xD5u\x84\xB6\xD1\xA2l\xC9\xE3\x84N\xD7\\6\xF3<\x0FyR\x04*\xB0A+$\x05"
    end
    
    it "generates hmacs" do
      expect(kraken.send(:generate_hmac, 'abc', '123')).to eq 'G7R6Lghr+rOobjhD/9Zl/q2Q8O9GzyiUxWoZT7GBWGhen9NkveAI1fLLBOZJxzlq3aONxWF6ndVquYGSCuExiA=='
    end
  end

end