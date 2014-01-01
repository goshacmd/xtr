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

  describe '#fill' do
    it 'fills amount from limit orders'
  end
end
