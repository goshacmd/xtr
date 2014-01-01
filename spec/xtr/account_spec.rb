require 'spec_helper'

describe Xtr::Account do
  let(:engine) { double('engine') }
  subject(:account) { described_class.new(engine) }

  describe '#balance' do
    before do
      engine.stub(:supported_instrument?) { |i| i == "BTC" }
    end

    context 'when passing an invalid instrument name' do
      it 'raises an UnsupportedInstrumentError' do
        expect { account.balance("WTF") }.to raise_error(Xtr::UnsupportedInstrumentError)
      end
    end
  end
end
