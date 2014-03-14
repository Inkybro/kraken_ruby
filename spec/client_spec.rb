require 'kraken_ruby'
require 'kraken_key'

describe Kraken::Client do

  before :each do
    # I moved this sleep into the post_private() method of the Client
    # class, because in an actual production scenario, using the library
    # would, in some cases, suffer the same problem that I guess you
    # were suffering here (EAPI:InvalidNonce). So, the fix should be
    # applied over the entire library, not only during spec runs.
    # Additionally, it makes the spec suite run MUCH faster, since
    # a nonce is not necessary for public requests.
    
    # ^ SECOND FOLLOWUP TO THAT:
    # i wrote a better nonce generator, that takes into account
    # time on much smaller scales (perhaps like 1/1000th of a second).
    # it seems to work fine.
    
    #sleep 0.3 # to prevent rapidly pinging the Kraken server
  end

  let(:kraken){ Kraken::Client.new(API_KEY, API_SECRET) }
  
  it "returns the API version being used" do
    expect(kraken).to respond_to :api_version
    expect(kraken.api_version).to eq kraken.instance_eval { @api_version }
  end
  
  context "fetching public data" do
    context "using server_time()" do
      it "gets the correct time from Kraken" do
        # testing day vs day probably wouldn't ever really be an 
        # issue, nor hour vs hour, but it is POSSIBLE.
        # im assuming that this is why we weren't testing vs minute/second.
        # perhaps calculating a time difference in seconds is
        # a more reliable approach. 
        result = Time.parse(kraken.server_time.rfc1123)
        time_difference_in_seconds = (result-Time.now.getutc).abs
        expect(time_difference_in_seconds).to be < 3
      end
    end
    
    context "using assets()" do
      context "given no input" do
        it "gets a list of all tradeable assets" do
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
      end
      
      context "given valid input" do
        it "gets a list of the specified assets" do
          result = kraken.assets('XLTC, XXDG')
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
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.assets(1234) }.to raise_error(ArgumentError)
          expect { kraken.assets(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.assets({}) }.to raise_error(ArgumentError)
          expect { kraken.assets([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using asset_pairs()" do
      context "given no input" do
        it "gets a list of all asset pairs" do
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
      end
      
      context "given valid input" do
        it "gets a list of the specified asset pairs" do
          result = kraken.asset_pairs('XLTCXXDG, XLTCXXRP')
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
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.asset_pairs(1234) }.to raise_error(ArgumentError)
          expect { kraken.asset_pairs(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.asset_pairs({}) }.to raise_error(ArgumentError)
          expect { kraken.asset_pairs([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using ticker()" do
      context "given no input" do
        it "throws an ArgumentError exception" do
          expect { kraken.ticker }.to raise_error(ArgumentError)
        end
      end
      
      context "given valid input" do
        it "gets public ticker data for given asset pairs" do
          result = kraken.ticker('XLTCXXDG, ZEURXXDG')
          expect(result).to respond_to :XLTCXXDG
          expect(result).to respond_to :ZEURXXDG
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.ticker(1234) }.to raise_error(ArgumentError)
          expect { kraken.ticker(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.ticker({}) }.to raise_error(ArgumentError)
          expect { kraken.ticker([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using ohlc()" do
      context "given no input" do
        it "throws an ArgumentError exception" do
          expect { kraken.ohlc }.to raise_error(ArgumentError)
        end
      end
      
      context "given valid input" do
        it "gets order book data for a given asset pair" do
          result = kraken.ohlc('XLTCXXDG')
          expect(result).to respond_to :XLTCXXDG
          expect(result.XLTCXXDG).to be_instance_of(Array)
          expect(result).to respond_to :last
          #expect(result.last).to be_instance_of(Fixnum)
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.ohlc(1234) }.to raise_error(ArgumentError)
          expect { kraken.ohlc(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.ohlc({}) }.to raise_error(ArgumentError)
          expect { kraken.ohlc([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using order_book()" do
      context "given no input" do
        it "throws an ArgumentError exception" do
          expect { kraken.order_book }.to raise_error(ArgumentError)
        end
      end
      
      context "given valid input" do
        it "gets order book data for a given asset pair" do
          result = kraken.order_book('XLTCXXDG')
          expect(result).to respond_to :XLTCXXDG
          expect(result.XLTCXXDG).to respond_to :asks
          expect(result.XLTCXXDG).to respond_to :bids
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.order_book(1234) }.to raise_error(ArgumentError)
          expect { kraken.order_book(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.order_book({}) }.to raise_error(ArgumentError)
          expect { kraken.order_book([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using trades()" do
      context "given no input" do
        it "throws an ArgumentError exception" do
          expect { kraken.trades }.to raise_error(ArgumentError)
        end
      end
      
      context "given valid input" do
        it "gets an array of trades data for a given asset pair" do
          result = kraken.trades('XLTCXXDG')
          expect(result).to respond_to :XLTCXXDG
          expect(result.XLTCXXDG).to be_instance_of(Array)
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.trades(1234) }.to raise_error(ArgumentError)
          expect { kraken.trades(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.trades({}) }.to raise_error(ArgumentError)
          expect { kraken.trades([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using spread()" do
      context "given no input" do
        it "throws an ArgumentError exception" do
          expect { kraken.spread }.to raise_error(ArgumentError)
        end
      end
      
      context "given valid input" do
        it "gets an array of spread data for a given asset pair" do
          result = kraken.spread('XLTCXXDG')
          expect(result).to respond_to :XLTCXXDG
          expect(result.XLTCXXDG).to be_instance_of(Array)
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.spread(1234) }.to raise_error(ArgumentError)
          expect { kraken.spread(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.spread({}) }.to raise_error(ArgumentError)
          expect { kraken.spread([]) }.to raise_error(ArgumentError)
        end
      end
    end
  end

  context "fetching private data" do # More tests to come
    context "using balance()" do
      context "given no input" do
        it "gets the user's balance(s) in ZUSD" do
          expect(kraken.balance).to be_instance_of(Hashie::Mash)
        end
      end
      
      context "given any input" do
        # although the API doc says that you are able to specify
        # 'asset' (base asset used to determine balance, default ZUSD),
        # it seems not to make any difference, so for now, I'm just going
        # entirely disable passing arguments.
        it "throws an ArgumentError exception" do
          expect { kraken.balance({:asset => 'XLTCXXDG'}) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using trade_balance()" do
      context "given no input" do
        it "gets the user's trade balance(s) in ZUSD" do
          expect(kraken.trade_balance).to be_instance_of(Hashie::Mash)
        end
      end
      
      context "given valid input" do
        it "gets the user's trade balance(s) in the specified asset" do
          zusd = kraken.trade_balance
          expect(zusd).to be_instance_of(Hashie::Mash)
          xxdg = kraken.trade_balance('XXDG')
          expect(xxdg).to be_instance_of(Hashie::Mash)
          expect(zusd).not_to eq xxdg
        end
      end
      
      context "given invalid input" do
        it "throws an ArgumentError exception" do
          expect { kraken.trade_balance(1234) }.to raise_error(ArgumentError)
          expect { kraken.trade_balance(1234.56) }.to raise_error(ArgumentError)
          expect { kraken.trade_balance({}) }.to raise_error(ArgumentError)
          expect { kraken.trade_balance([]) }.to raise_error(ArgumentError)
        end
      end
    end
    
    context "using open_orders()" do
      context "given valid input" do
        it "gets a list of the user's open orders" do
          result = kraken.open_orders
          expect(result).to be_instance_of(Hashie::Mash)
          expect(result[:open]).to be_instance_of(Hashie::Mash)
          
          #result = kraken.open_orders(true)
          #expect(result).to be_instance_of(Hashie::Mash)
          #expect(result[:open]).to be_instance_of(Hashie::Mash)
        end
      end
      
      #context "given invalid input for 'trades'" do
      #  it "throws an ArgumentError exception" do
      #    expect { kraken.open_orders(1234) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders(1234.56) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders({}) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders([]) }.to raise_error(ArgumentError)
      #  end
      #end
    end
    
    context "using closed_orders()" do
      context "given valid input" do
        it "gets a list of the user's closed orders" do
          result = kraken.closed_orders
          expect(result).to be_instance_of(Hashie::Mash)
          expect(result[:closed]).to be_instance_of(Hashie::Mash)
          
          #result = kraken.closed_orders(true)
          #expect(result).to be_instance_of(Hashie::Mash)
          #expect(result[:closed]).to be_instance_of(Hashie::Mash)
        end
      end
      
      #context "given invalid input for 'trades'" do
      #  it "throws an ArgumentError exception" do
      #    expect { kraken.open_orders(1234) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders(1234.56) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders({}) }.to raise_error(ArgumentError)
      #    expect { kraken.open_orders([]) }.to raise_error(ArgumentError)
      #  end
      #end
    end
  end
  
  context "signing/making private post requests" do
    it "makes post requests" do
      # no idea how to test this, besides,
      # it's just not worth it, I think.
    end
    
    # This test is better than the rest in this context.
    # It should remain.
    it "generates nonces" do
      last_nonce = 0
      (1..1000).each do |n|
        this_nonce = kraken.send(:nonce).to_i
        expect(this_nonce).to be > last_nonce 
        last_nonce = this_nonce
      end
    end
    
    # This test isnt really necessary. I'm sure Addressable has a suite,
    # so really it was just kind of redundant. 
    it "encodes option hashes" do
      opts = {:a => 1, :b => 2, :c => 3}
      expect(kraken.send(:encode_options, opts)).to eq 'a=1&b=2&c=3'
    end
    
    # The below tests are something like above:
    # Maybe a little redundant and/or unnecessary.
    # Especially with the following three, dealing w/
    # SSL encryption, etc. I wouldn't even know where
    # to begin REALLY testing it. All of the following
    # 3 tests are based on the output I got, running
    # the exact same commands in IRB. So, they can't 
    # really be called tests :P
    # Anyway, who knows, maybe one day it'll be nice
    # to have them here, there could come a time when
    # somebody may want to expand on these aspects.
    it "generates signatures" do
      opts = { 'nonce' => '123456789' }
      expect(kraken.send(:generate_signature, 'SomeMethod', 'abc', {'nonce'=>'123456789'})).to eq 'YYpKKS5wFGPUW36Hb7SuMOxHwtq7lp8Do6DMyiHgy5FWBKRlOvxlYs43lJjYYK9S8gwYpoh/ZuHs59ArJMLCPg=='
    end
    
    it "generates messages" do
      opts = { 'nonce' => '123456789' }
      expect(kraken.send(:generate_message, 'SomeMethod', opts, 'abc')).to eq "/0/private/SomeMethodC\x90\x87H-!\xD5u\x84\xB6\xD1\xA2l\xC9\xE3\x84N\xD7\\6\xF3<\x0FyR\x04*\xB0A+$\x05"
    end
    
    it "generates hmacs" do
      expect(kraken.send(:generate_hmac, 'abc', '123')).to eq 'G7R6Lghr+rOobjhD/9Zl/q2Q8O9GzyiUxWoZT7GBWGhen9NkveAI1fLLBOZJxzlq3aONxWF6ndVquYGSCuExiA=='
    end
    
    # Pretty much, again, the same. A little unnecessary.
    it "generates url paths" do
      expect(kraken.send(:url_path, 'SomeMethod')).to eq "/#{kraken.api_version}/private/SomeMethod"
    end
  end

end