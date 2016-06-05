class Payment < ActiveRecord::Base
  validates_presence_of :amount
  validates_numericality_of :amount, :greater_than => 0

  belongs_to :loan
  validates :loan, presence: true

  # User friendly json presenter - converting string amount into floats
  def to_json
    {
      id: self.id,
      loan_id: self.loan.id,
      amount: self.amount.to_f,
      created_at: self.created_at,
      updated_at: self.updated_at
    }
  end
end
