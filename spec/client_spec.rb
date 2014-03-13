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

  context "public data" do
    it "gets the proper server time" do
      kraken_time = DateTime.parse(kraken.server_time.rfc1123)
      utc_time = Time.now.getutc
      expect(kraken_time.day).to eq utc_time.day
      expect(kraken_time.hour).to eq utc_time.hour
    end

    it "gets list of tradeable assets" do
      expect(kraken.assets).to respond_to :XLTC
    end

    it "gets list of asset pairs" do
      expect(kraken.asset_pairs).to respond_to :XLTCXXDG
    end

    it "gets public ticker data for given asset pairs" do
      result = kraken.ticker('XLTCXXDG, ZEURXXDG')
      expect(result).to respond_to :XLTCXXDG
      expect(result).to respond_to :ZEURXXDG
    end

    it "gets order book data for a given asset pair" do
      order_book = kraken.order_book('XLTCXXDG')
      expect(order_book.XLTCXXDG).to respond_to :asks
    end

    it "gets an array of trades data for a given asset pair" do
      trades = kraken.trades('XLTCXXDG')
      expect(trades.XLTCXXDG).to be_instance_of(Array)
    end

    it "gets an array of spread data for a given asset pair" do
      spread = kraken.spread('XLTCXXDG')
      expect(spread.XLTCXXDG).to be_instance_of(Array)
    end
  end

  context "private data" do # More tests to come    
    it "gets the user's balance" do
      expect(kraken.balance).to be_instance_of(Hash)
    end
  end

end