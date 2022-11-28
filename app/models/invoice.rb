class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :transactions, :dependent => :destroy
  has_many :invoice_items, :dependent => :destroy
  has_many :items, through: :invoice_items

scope :created_between, lambda {|start_date, end_date| where("invoices.created_at >= ? AND invoices.created_at <= ?", start_date, end_date )}

  def self.total_revenue(start_date, end_date)
    joins([:invoice_items, :transactions])
    .select("invoice_items.*")
    .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    .merge(Invoice.created_between(start_date, end_date))
    .sum("invoice_items.quantity * invoice_items.unit_price")
    .round(2)
  end
end
