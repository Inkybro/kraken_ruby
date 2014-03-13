require 'kraken_ruby'
require 'kraken_key'

describe Kraken::Client do

  before :each do
    # FIXME: perhaps it would be wiser or make more sense to implement
    # this sleep within the actual library -- just not sure if that is
    # a desired default behavior or if it's something that maybe should 
    # be left up to the developer using the library
    
    sleep 0.3 # to prevent rapidly pinging the Kraken server
  end

  let(:kraken){ Kraken::Client.new(API_KEY, API_SECRET) }
  
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
        time_difference_in_seconds.should be < 3
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
        it "gets the user's balance(s)" do
          expect(kraken.balance).to be_instance_of(Hash)
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
  end

end