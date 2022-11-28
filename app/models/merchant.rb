class Merchant < ApplicationRecord
  validates_presence_of :name
  
  has_many :items
  has_many :invoices

  def self.single_merchant_search(keyword)
    where("name ILIKE ?", "%#{keyword}%").order(:name).first
  end

  def self.merchants_by_revenue(number_of_results)
    joins(invoices: [:invoice_items, :transactions])
    .select("merchants.*, sum(invoice_items.unit_price * invoice_items.quantity) as revenue")
    # .where("transactions.result = #{success}")
    .where("invoices.status == shipped")
    .group(:id)
    .order(revenue: :desc)
    .limit(number_of_results)
  end

  def self.most_items(number_of_results)
     joins(invoices: [:invoice_items, :transactions])
    .select("merchants.*, sum(invoice_items.quantity) as count_of_items")
    .where(transactions: {result: 'success'}, invoices: {status: 'shipped'})
    .group(:id)
    .order(count: :desc)
    .limit(number_of_results)
  end


end 
