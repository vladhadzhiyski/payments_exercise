require 'rails_helper'

describe PaymentsController, type: :controller do

  describe '#show' do
    let(:loan) { Loan.create!(funded_amount: 100.0) }

    it 'return the payment info for a given loan' do
      payment_amount = 20.0
      payment = Payment.create(amount: payment_amount, loan: loan)
      get :show, id: loan.id
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      expect(response_body).to include({
        "id" => payment.id,
        "amount" => payment_amount,
        "loan_id" => loan.id
      })
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, id: 10000
        expect(response).to have_http_status(:not_found)
      end
    end
  end

end
