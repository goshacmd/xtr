require 'spec_helper'

describe Xtr::CurrencyBalance do
  let(:account) { double('account', uuid: '123') }
  let(:currency) { :USD }

  subject(:balance) { described_class.new(account, currency) }

  describe '#credit' do
    context 'with a positive amount' do
      let(:amount) { TENK }

      it 'adds amount to available balance' do
        expect { balance.credit(amount) }.to \
          change { balance.available }.by(TENK)
      end

      it 'does not touch reserved balance' do
        expect { balance.credit(amount) }.not_to \
          change { balance.reserved }
      end
    end

    context 'with a negative amount' do
      let(:amount) { -TENK }

      it 'raises a NegativeAmountException' do
        expect { balance.credit(amount) }.to \
          raise_error(Xtr::NegativeAmountException)
      end
    end
  end

  describe '#debit' do
    context 'when there are enough funds' do
      before { balance.credit(TENK) }

      context 'with a positive amount' do
        let(:amount) { FIVEK }

        it 'removes amount from available balance' do
          expect { balance.debit(amount) }.to \
            change { balance.available }.by(-FIVEK)
        end

        it 'does not touch reserved balance' do
          expect { balance.debit(amount) }.not_to \
            change { balance.reserved }
        end
      end

      context 'with a negative amount' do
        let(:amount) { -FIVEK }

        it 'raises a NegativeAmountException' do
          expect { balance.debit(amount) }.to \
            raise_error(Xtr::NegativeAmountException)
          end
      end
    end

    context 'when there are not enough funds' do
      let(:amount) { FIVEK }

      it 'raises a NotEnoughFundsException' do
        expect { balance.debit(amount) }.to \
          raise_error(Xtr::NotEnoughFundsException)
      end
    end
  end

  describe '#reserve' do
    context 'when there are enough funds' do
      before { balance.credit(TENK) }

      context 'with a positive amount' do
        let(:amount) { FIVEK }

        it 'removes amount from available balance' do
          expect { balance.reserve(amount) }.to \
            change { balance.available }.by(-FIVEK)
        end

        it 'adds amount to reserved balance' do
          expect { balance.reserve(amount) }.to \
            change { balance.reserved }.by(FIVEK)
        end

        it 'returns reservation id' do
          expect(balance.reserve(amount)).to be_an_instance_of(String)
        end
      end

      context 'with a negative amount' do
        let(:amount) { -FIVEK }

        it 'raises a NegativeAmountException' do
          expect { balance.reserve(amount) }.to \
            raise_error(Xtr::NegativeAmountException)
        end
      end
    end

    context 'when there are not enough funds' do
      let(:amount) { FIVEK }

      it 'raises a NotEnoughFundsException' do
        expect { balance.reserve(amount) }.to \
          raise_error(Xtr::NotEnoughFundsException)
      end
    end
  end

  describe '#release' do
    context 'with a vaild reservation' do
      before { balance.credit(TENK) }
      let!(:reservation) { balance.reserve(FIVEK) }

      context 'with no amount specified' do
        it 'releases all reservation funds' do
          expect { balance.release(reservation) }.to \
            change { balance.available }.by(FIVEK)
        end
      end

      context 'with amount specified' do
        context 'with amount smaller than reservation' do
          it 'releases specified amount' do
            expect { balance.release(reservation, 2 * K) }.to \
              change { balance.available }.by(2 * K)
          end
        end

        context 'with amount larger than reservation' do
          it 'raises a NotEnoughFundsReservedException' do
            expect { balance.release(reservation, TENK) }.to \
              raise_error(Xtr::NotEnoughFundsReservedException)
          end
        end
      end
    end

    context 'without a valid reservation' do
      let(:reservation) { Xtr::Util.uuid }
    end
  end

  describe '#debit_reserved' do
    context 'with a vaild reservation' do
      before { balance.credit(TENK) }
      let!(:reservation) { balance.reserve(FIVEK) }

      context 'with no amount specified' do
        it 'releases all reservation funds' do
          expect { balance.debit_reserved(reservation) }.to \
            change { balance.reserved }.by(-FIVEK)
        end
      end

      context 'with amount specified' do
        context 'with amount smaller than reservation' do
          it 'releases specified amount' do
            expect { balance.debit_reserved(reservation, 2 * K) }.to \
              change { balance.reserved }.by(-2 * K)
          end
        end

        context 'with amount larger than reservation' do
          it 'raises a NotEnoughFundsReservedException' do
            expect { balance.debit_reserved(reservation, TENK) }.to \
              raise_error(Xtr::NotEnoughFundsReservedException)
          end
        end
      end
    end

    context 'without a valid reservation' do
      let(:reservation) { Xtr::Util.uuid }
    end
  end
end
