class Task < ApplicationRecord
  validates :date, presence: true, format: { with: /\A\d{4}-(0[1-9]|1[0-2])-([0][1-9]|[1-2]\d|[3][0-1])\z/ }
  validates :name, presence: true
  validates :amount, presence: true, format: { with: /\A[0-9]\z|\A1[0-9]\z|\A2[0-4]$|\A[0-9]\.[0-9]\z|\A[1-2][0-3]\.[0-9]\z/ }

  belongs_to :user
end
