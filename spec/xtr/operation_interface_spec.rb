require 'spec_helper'

describe Xtr::OperationInterface do
  let(:engine) { double('engine') }
  let(:journal) { double('journal', record: nil) }
  subject(:iface) { described_class.new(engine, journal) }

  describe '#execute' do
    let(:name) { 'SomeOperation' }
    let(:serial) { 1 }
    let(:time) { Time.now }
    let(:args) { [1, 2, 3] }
    let(:op) { double('operation', perform: nil) }

    before do
      iface.stub(inc_serial: serial)
      Time.stub(now: time)
      Xtr::Operation.stub(:build).with(name, serial, time, *args).and_return(op)
    end

    it 'logs the operation to journal' do
      expect(journal).to receive(:record).with(op)
      iface.execute(name, *args)
    end

    it 'performs operation on engine' do
      expect(op).to receive(:perform).with(engine)
      iface.execute(name, *args)
    end
  end

  describe '#execute_op' do
    it 'performs operation on engine' do
      op = double('operation')
      expect(op).to receive(:perform).with(engine)
      iface.execute_op(op)
    end
  end
end
