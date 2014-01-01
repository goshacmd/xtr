require 'spec_helper'

describe Xtr::Order do
  let(:account) { double('account', uuid: '123').as_null_object }
  let(:market) { double('market').as_null_object }

  let(:price) { 100 }
  let(:quantity) { 5 }

  subject(:order) { described_class.new(account, market, :buy, price, quantity) }

  describe '#add_fill' do
    let(:fill_price) { 90 }
    let(:fill_amount) { 2 }

    it 'adds a fill entry' do
      expect { order.add_fill(fill_amount, fill_price) }.to \
        change { order.fills }.by([[fill_price, fill_amount]])
    end

    it 'decreases remainder amount' do
      expect { order.add_fill(fill_amount, fill_price) }.to \
        change { order.remainder }.by(-fill_amount)
    end

    it 'changes status' do
      expect { order.add_fill(fill_amount, fill_price) }.to \
        change { order.status }.to(:partially_filled)

      expect { order.add_fill(quantity - fill_amount, fill_price) }.to \
        change { order.status }.to(:filled)
    end

    it 'releases remainder if the order is filled' do
      expect(order).to receive(:release_delete)

      order.add_fill(fill_amount, fill_price)
    end
  end

  describe '#release_delete' do
    context 'when the order is filled or canceled' do
      let(:open_orders) { [] }
      let(:account) { double('account', open_orders: open_orders).as_null_object }

      before { order.stub(account: account, filled?: true) }

      it 'releases order amount' do
        expect(order).to receive(:release)
        order.release_delete
      end

      it 'removes order from account' do
        expect(open_orders).to receive(:delete).with(order)
        order.release_delete
      end
    end
  end
end
