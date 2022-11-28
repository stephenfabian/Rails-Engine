require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many :items }
    it { should have_many :invoices }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
  
  describe 'single_merchant_search' do
    it 'can return a single merchant by name search' do
      create(:merchant, name: "Bob")
      create(:merchant, name: "Turing")
      merchant_to_return = create(:merchant, name: "Merchant Bring It")
      create(:merchant, name: "Billy")

      expect(Merchant.single_merchant_search("ring")).to eq(merchant_to_return)
    end
  end

  describe 'merchants_by_total_revenue' do
    it 'returns x number of merchants sorted by total revenue desc' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @merchant3 = create(:merchant)

      @item1 = create(:item, merchant_id: @merchant1.id)
      @item2 = create(:item, merchant_id: @merchant2.id)
      @item3 = create(:item, merchant_id: @merchant3.id)

      @customer1 = Customer.create!(first_name: "Stephen", last_name: "Fabian", created_at: "2022-08-27 10:00:00 UTC", updated_at: "2022-08-27 10:00:00 UTC")

      @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped")
      @invoice3 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant3.id, status: "shipped")

      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 10)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 2, unit_price: 20)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 4590)

      expect(Merchant.merchants_by_revenue(2)).to eq([@merchant3, @merchant2])
    end
  end

   describe "Total revenue generated in the whole system over start/end date range" do
    it 'returns merchants with most revenue sorted desc revenue' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @merchant3 = create(:merchant)

      @item1 = create(:item, merchant_id: @merchant1.id)
      @item2 = create(:item, merchant_id: @merchant2.id)
      @item3 = create(:item, merchant_id: @merchant3.id)

      @customer1 = Customer.create!(first_name: "Stephen", last_name: "Fabian", created_at: "2022-08-27 10:00:00 UTC", updated_at: "2022-08-27 10:00:00 UTC")

      @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant2.id, status: "shipped")
      @invoice3 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant3.id, status: "shipped")

      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 10)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 2, unit_price: 20)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 4590)

      expect(Merchant.total_revenue(2022-01-01, 2022-12-31)).to eq([@merchant3, @merchant2])
    end
  end
end




                 
