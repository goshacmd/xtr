require 'spec_helper'

describe Xtr::BalanceCollection do
  let(:registry) { double('registry', :[] => nil) }
  let(:engine) { double('engine', instrument_registry: registry) }
  let(:account) { double('account', engine: engine) }
  subject(:col) { described_class.new(account) }

  describe '#[]' do
    before do
      engine.stub(:supported_instrument?) { |i| i.to_s == 'BTC' }
    end

    context 'when passing a valid instrument name' do
      let(:balance) { double('cash_balance') }
      let(:instrument) { double('instrument') }

      before do
        registry.stub(:[] => instrument)
        Xtr::CashBalance.stub(:new).with(account, instrument).and_return(balance)
      end

      it 'gets cash balance for that instrument' do
        expect(col['BTC']).to eq balance
      end
    end

    context 'when passing an invalid instrument name' do
      it 'raises an UnsupportedInstrumentError' do
        expect { col['WTF'] }.to raise_error(Xtr::UnsupportedInstrumentError)
      end
    end
  end
end
