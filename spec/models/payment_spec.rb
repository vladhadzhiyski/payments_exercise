require 'rails_helper'

describe Payment do
  let(:loan) { Loan.create!(funded_amount: 100.0) }

  describe "success" do
    it "saves a payment" do
      expect do
        Payment.create!(amount: 34.5, loan: loan)
      end.not_to raise_error
    end
  end

  describe "failures" do
    it 'does not save a payment if loan is present but amount is not' do
      expect do
        Payment.create!(loan: loan)
      end.to raise_error("Validation failed: Amount can't be blank, Amount is not a number")
    end

    describe "with an existing / associated loan" do
      it 'does not save a payment if amount is negative' do
        expect do
          Payment.create!(amount: -34.5, loan_id: loan.id)
        end.to raise_error('Validation failed: Amount must be greater than 0')
      end

      it 'does not save a payment if amount is zero' do
        expect do
          Payment.create!(amount: 0, loan_id: loan.id)
        end.to raise_error('Validation failed: Amount must be greater than 0')
      end

      it 'does not save a payment if amount is a string' do
        expect do
          Payment.create!(amount: 'string value', loan_id: loan.id)
        end.to raise_error('Validation failed: Amount is not a number')
      end
    end
  end
end
