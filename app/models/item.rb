class Item < ApplicationRecord
  validates_presence_of :name, :description, :unit_price, :merchant_id

  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  def destroy_inv_having_one_item
    invoices.each do |invoice|                
      if invoice.invoice_items.count == 1
        Invoice.destroy(invoice.id)
      elsif invoice.invoice_items.count > 1
        invoice_items.each do |invoice_item|
          InvoiceItem.destroy(invoice_item.id) if invoice_item.item_id == self.id
        end
      end
    end
  end

  def self.search_by_min_price(price)
    where("unit_price >= #{price}")
  end

  def self.search_by_max_price(price)
    where("unit_price <= #{price}")
  end

  def self.search_by_max_and_min_price(min_price, max_price)
    Item.where(unit_price: min_price..max_price)
  end

  def self.all_items_search(keyword)
    where("name ILIKE ?", "%#{keyword}%").order(:name)
  end
end
