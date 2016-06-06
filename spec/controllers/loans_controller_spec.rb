require 'rails_helper'

RSpec.describe LoansController, type: :controller do

  before(:each) do
    @loan = Loan.create!(funded_amount: 100.0)
  end

  describe '#create_payment' do

    describe "success" do
      it 'creates a payment for an existing loan with amount less than the funded amount' do
        payment_amount = 20.0
        params = {
          id: @loan.id,
          payment_amount: payment_amount
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "payment" => {
            "amount" => payment_amount,
            "loan_id" => @loan.id
          }
        })
      end

      it 'creates a payment for an existing loan with amount equal to the funded amount' do
        payment_amount = @loan.funded_amount
        params = {
          id: @loan.id,
          payment_amount: payment_amount
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "payment" => {
            "amount" => payment_amount,
            "loan_id" => @loan.id
          }
        })
      end
    end

    describe "failures" do
      it 'returns an error if payment amount is not present' do
        params = {
          id: @loan.id
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "error" => "Amount can't be blank. Amount is not a number"
        })
      end

      it 'returns an error if payment amount is negative' do
        params = {
          id: @loan.id,
          payment_amount: -20.0
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "error" => "Amount must be greater than 0"
        })
      end

      it 'returns an error if payment amount is a string' do
        params = {
          id: @loan.id,
          payment_amount: "Twenty"
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "error" => "Amount is not a number"
        })
      end

      it 'returns an error if payment amount exceeds funded amount' do
        params = {
          id: @loan.id,
          payment_amount: (@loan.funded_amount + 1)
        }
        post :create_payment, params
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to eq({
          "error" => "Amount cannot exceed the funded amount"
        })
      end
    end

  end

  describe '#index' do
    it 'returns all loans with their outstanding balances' do
      Payment.create(amount: 20, loan: @loan)
      loan2 = Loan.create!(funded_amount: 200.0)
      Payment.create(amount: 20, loan: loan2)
      get :index
      expect(response.status).to eq(200)
      response_body = JSON.parse(response.body)
      loans_response = response_body["loans"]
      loan1_response = loans_response.find{|l| l["id"] == @loan.id}
      loan2_response = loans_response.find{|l| l["id"] == loan2.id}
      expect(loan1_response).to include({
        "id" => 1,
        "funded_amount" => 100.0,
        "outstanding_balance" => 80.0,
      })
      expect(loan2_response).to include({
        "id" => 2,
        "funded_amount" => 200.0,
        "outstanding_balance" => 180.0,
      })
    end
  end

  describe '#show' do
    context 'default json response' do
      it 'returns a loan info with its outstanding balance' do
        Payment.create(amount: 20, loan: @loan)
        get :show, id: @loan.id
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to include({
          "id" => 1,
          "funded_amount" => 100.0,
          "outstanding_balance" => 80.0,
        })
      end
    end

    context 'with all payments info - json response' do
      it 'returns a loan with all payments' do
        payment = Payment.create(amount: 20.0, loan: @loan)
        get :show, id: @loan.id, with: 'payments'
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to include({
          "id" => 1,
          "funded_amount" => 100.0,
          "outstanding_balance" => 80.0,
        })
        payments = response_body["payments"]
        expect(payments[0]).to include({
          "id" => 1,
          "amount" => 20.0
        })
      end

      it "does not return a loan with its payments if 'with' options is missing" do
        payment = Payment.create(amount: 20.0, loan: @loan)
        get :show, id: @loan.id
        expect(response.status).to eq(200)
        response_body = JSON.parse(response.body)
        expect(response_body).to_not have_key("payments")
        expect(response_body).to include({
          "id" => 1,
          "funded_amount" => 100.0,
          "outstanding_balance" => 80.0,
        })
      end
    end

    context 'if the loan is not found' do
      it 'responds with a 404' do
        get :show, id: 10000
        expect(response.status).to eq(404)
      end
    end
  end

end
