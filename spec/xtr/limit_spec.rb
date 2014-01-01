require 'spec_helper'

describe Xtr::Limit do
  subject(:limit) { described_class.new(100, :buy) }

  describe '#add' do
    let(:order) { double('order', remainder: 10) }

    it 'adds order' do
      expect { limit.add(order) }.to change { limit.orders }.by([order])
    end

    it 'increases limit size' do
      expect { limit.add(order) }.to change { limit.size }.by(10)
    end
  end

  describe '#remove' do
    let(:order) { double('order', remainder: 5) }

    before { limit.add(order) }

    it 'deletes order' do
      expect { limit.remove(order) }.to change { limit.orders }.to([])
    end

    it 'decreases limit size' do
      expect { limit.remove(order) }.to change { limit.size }.by(-5)
    end
  end

  describe '#orders_to_fill' do
    let(:order1) { double('order1', remainder: 100) }
    let(:order2) { double('order2', remainder: 150) }
    let(:order3) { double('order3', remainder: 500) }

    before do
      [order1, order2, order3].each { |order| limit.add(order) }
    end

    it 'returns order-fill pairs' do
      result = limit.orders_to_fill(300)

      expect(result).to eq [
        [order1, 100], [order2, 150], [order3, 50]
      ]
    end
  end

  describe '#fill' do
    let(:f_order) { double('filling_order') }
    let(:order1) { double('order1', remainder: 100, filled?: true) }
    let(:order2) { double('order2', remainder: 250, filled?: false) }

    let(:execution1) { double('execution1', execute: true) }
    let(:execution2) { double('execution2', execute: true) }

    before do
      limit.stub(orders_to_fill: [[order1, 100], [order2, 150]])

      Xtr::Execution.stub(:new).with(order1, f_order, 100).and_return(execution1)
      Xtr::Execution.stub(:new).with(order2, f_order, 150).and_return(execution2)

      [order1, order2].each { |order| limit.add(order) }
    end

    it 'executes fills' do
      expect(execution1).to receive(:execute)
      expect(execution2).to receive(:execute)

      limit.fill(250, f_order)
    end

    it 'removes filled orders' do
      expect { limit.fill(250, f_order) }.to \
        change { limit.orders }.to([order2])
    end

    it 'decreases limit size' do
      expect { limit.fill(250, f_order) }.to \
        change { limit.size }.by(-250)
    end
  end
end
