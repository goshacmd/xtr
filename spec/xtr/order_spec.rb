require 'spec_helper'

describe Xtr::Order do
  let(:account) { double('account', uuid: '123') }
  let(:market) { double('market') }

  describe '#fill' do
    it 'adds a fill entry'
    it 'decreases remainder amount'
    it 'debits offered amount'
    it 'credits received amount'
    it 'releases remainder if the order is filled'
  end
end
