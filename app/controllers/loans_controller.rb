class LoansController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: 'not_found', status: :not_found
  end

  def index
    loans = Loan.all.map(&:to_json)
    render json: {loans: loans}
  end

  def show
    loan = Loan.find(params[:id])
    if loan.present?
      result = loan.to_json(with: params[:with])
    else
      result = {error: 'Loan not found'}
    end
    render json: result
  end

  def create_payment
    loan = Loan.find(params[:id])
    if loan.present?
      payment = Payment.new(amount: params[:payment_amount], loan: loan)
      if payment.save
        result = {payment: {amount: payment.amount.to_f, loan_id: loan.id}}
      else
        result = {error: payment.errors.full_messages.join('. ')}
      end
      render json: result
    else
      render json: {error: 'Loan not found'}
    end
  end
end
