require 'spec_helper'

describe Xtr::Execution do
  let(:amount) { 10 }
  let(:buy_order) { double('buy_order', buy?: true) }
  let(:sell_order) { double('sell_order', buy?: false) }

  describe '#initialize' do
    it 'sets buy/sell orders properly' do
      exe1 = described_class.new(buy_order, sell_order, amount)
      expect(exe1.buy_order).to eq buy_order
      expect(exe1.sell_order).to eq sell_order

      exe2 = described_class.new(sell_order, buy_order, amount)
      expect(exe2.buy_order).to eq buy_order
      expect(exe2.sell_order).to eq sell_order
    end
  end

  describe '#computed_price' do
    let(:buy_price) { 100 }
    let(:sell_price) { 110 }

    let!(:buy1) { double('buy_order1', buy?: true, price: buy_price, created_at: Time.now) }
    let!(:buy2) { double('buy_order2', buy?: true, price: buy_price, created_at: Time.now - 10) }
    let!(:sell1) { double('sell_order1', buy?: false, price: sell_price, created_at: Time.now) }
    let!(:sell2) { double('sell_order2', buy?: false, price: sell_price, created_at: Time.now - 10) }

    let(:exe1) { described_class.new(buy1, sell2, amount) }
    let(:exe2) { described_class.new(buy2, sell1, amount) }

    it 'returns price of the order that was submitted earlier than the other' do
      expect(exe1.computed_price).to eq sell_price
      expect(exe2.computed_price).to eq buy_price
    end
  end

  describe '#transfer' do
    let(:buy) { buy_order.as_null_object }
    let(:sell) { sell_order.as_null_object }
    let(:left_amount) { 10 }
    let(:right_amount) { 1_000 }

    subject(:exe) { described_class.new(buy, sell, amount) }

    it 'transfers left amount from buyer to seller' do
      expect(buy).to receive(:debit).with(right_amount)
      expect(sell).to receive(:credit).with(right_amount)

      exe.transfer(left_amount, right_amount)
    end

    it 'transfers right amount from seller to buyer' do
      expect(sell).to receive(:debit).with(left_amount)
      expect(buy).to receive(:credit).with(left_amount)

      exe.transfer(left_amount, right_amount)
    end
  end

  describe '#execute' do
    let(:price) { 100 }
    let(:buy) { buy_order.as_null_object }
    let(:sell) { sell_order.as_null_object }

    subject(:exe) { described_class.new(buy, sell, amount) }

    before { exe.stub(computed_price: price) }

    it 'transfers amounts between buyer and seller' do
      expect(exe).to receive(:transfer).with(amount, price * amount)
      exe.execute
    end

    it 'adds fills to both buy and sell orders' do
      expect(buy).to receive(:add_fill).with(amount, price)
      expect(sell).to receive(:add_fill).with(amount, price)

      exe.execute
    end

    it 'sets execution price' do
      expect { exe.execute }.to change { exe.price }.from(nil).to(price)
    end

    it 'sets execution time' do
      expect { exe.execute }.to change { exe.executed_at.to_i }.to(Time.now.to_i)
    end
  end
end
