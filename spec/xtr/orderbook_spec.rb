require 'spec_helper'

describe Xtr::Orderbook do
  subject(:orderbook) { described_class.new }

  describe '#fill_order' do
    let(:order) { double('order', direction: :buy, price: 200, remainder: 250) }
    let(:limit1) { double('limit1', size: 100, price: 165, fill: true) }
    let(:limit2) { double('limit2', size: 500, price: 185, fill: true) }
    let(:tree) { double('tree', can_fill_price?: true) }

    before do
      orderbook.stub(limits_to_fill: [[limit1, 100], [limit2, 150]])
      orderbook.stub(tree_opposite_direction: tree)
    end

    it 'fills each limit' do
      expect(limit1).to receive(:fill).with(100, order)
      expect(limit2).to receive(:fill).with(150, order)

      orderbook.fill_order(order)
    end

    it 'sets last price' do
      expect { orderbook.fill_order(order) }.to \
        change { orderbook.last_price }.to(185)
    end
  end
end
