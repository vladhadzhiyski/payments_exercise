class Loan < ActiveRecord::Base
  has_many :payments

  def outstanding_balance
    (self.funded_amount - self.payments.map(&:amount).sum).to_f
  end

  # User friendly json presenter - converting string amount into floats
  def to_json(options = {})
    payments = self.payments.map(&:to_json) if options[:with] == "payments"
    loan_json = {
      id: self.id,
      funded_amount: self.funded_amount.to_f,
      outstanding_balance: outstanding_balance,
      created_at: self.created_at,
      updated_at: self.updated_at
    }

    payments.present? ? loan_json.merge(payments: payments) : loan_json
  end

end
