require 'spec_helper'

describe Xtr::Reservation do
  let(:balance) { double('balance', uuid: '123') }
  let(:amount) { TENK }

  subject(:reservation) { described_class.new(balance, amount) }

  describe '#remainder' do
    it 'returns reservation remainder' do
      expect(reservation.remainder).to eq TENK

      reservation.stub(released: K, debited: FIVEK)

      expect(reservation.remainder).to eq 4 * K
    end
  end

  describe '#zero?' do
    it 'checks whethere remainder is zero' do
      expect(reservation.zero?).to be_false

      reservation.stub(remainder: 0)

      expect(reservation.zero?).to be_true
    end
  end

  describe '#release' do
    context 'with no amount specified' do
      it 'releases remainder' do
        expect { reservation.release }.to \
          change { reservation.remainder }.to(0)
      end
    end

    context 'with amount specified' do
      context 'with amount less then remainder' do
        it 'releases specified amount' do
          expect { reservation.release(K) }.to \
            change {reservation.remainder }.by(-K)
        end
      end

      context 'with amount greater than remainder' do
        it 'raises a NotEnoughFundsReservedException' do
          expect { reservation.release(20 * K) }.to \
            raise_error(Xtr::NotEnoughFundsReservedException)
        end
      end
    end
  end

  describe '#debit' do
    context 'with no amount specified' do
      it 'releases remainder' do
        expect { reservation.debit }.to \
          change { reservation.remainder }.to(0)
      end
    end

    context 'with amount specified' do
      context 'with amount less then remainder' do
        it 'releases specified amount' do
          expect { reservation.debit(K) }.to \
            change {reservation.remainder }.by(-K)
        end
      end

      context 'with amount greater than remainder' do
        it 'raises a NotEnoughFundsReservedException' do
          expect { reservation.debit(20 * K) }.to \
            raise_error(Xtr::NotEnoughFundsReservedException)
        end
      end
    end
  end
end
