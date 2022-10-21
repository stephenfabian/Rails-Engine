require 'rails_helper'

RSpec.describe Item, type: :model do
   describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:merchant_id) }
  end

  describe 'destroy_inv_having_one_item' do
    it 'if invoice has only one ii, destroy invoice and dependents, if more than one ii, dont destroy invoice' do
      @merchant1 = create(:merchant)

      @item1 = create(:item, merchant_id: @merchant1.id)
      @item2 = create(:item, merchant_id: @merchant1.id)
      @item3 = create(:item, merchant_id: @merchant1.id)

      @customer1 = Customer.create!(first_name: "Stephen", last_name: "Fabian", created_at: "2022-08-27 10:00:00 UTC", updated_at: "2022-08-27 10:00:00 UTC")

      @invoice1 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")
      @invoice2 = Invoice.create!(customer_id: @customer1.id, merchant_id: @merchant1.id, status: "shipped")

      @transaction1 = Transaction.create!(invoice_id: @invoice1.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction2 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction3 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")

      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 8, unit_price: 40)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 6, unit_price: 40)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 40)

      expect(@item1.invoices).to eq([@invoice1])
      expect(@invoice1.invoice_items.count).to eq(1)
      expect(@invoice2.invoice_items.count).to eq(2)

      @item1.destroy_inv_having_one_item
      
      expect{Invoice.find(@invoice1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{InvoiceItem.find(@invoice_item1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{Transaction.find(@transaction1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      
      @item2.destroy_inv_having_one_item  

      expect(Invoice.find(@invoice2.id)).to eq(@invoice2)
      expect{InvoiceItem.find(@invoice_item2.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(InvoiceItem.find(@invoice_item3.id)).to eq(@invoice_item3)
      expect(Transaction.find(@transaction2.id)).to eq(@transaction2)
    end
  end

  describe 'search by min price' do
    it 'should return array of items with a price less than or equal to the min price params' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @item1 = create(:item, unit_price: 40.20, merchant_id: @merchant1.id)
      @item2 = create(:item, unit_price: 40.50, merchant_id: @merchant1.id)
      @item3 = create(:item, unit_price: 60, merchant_id: @merchant2.id)
      @item4 = create(:item, unit_price: 20, merchant_id: @merchant2.id)

      expect(Item.search_by_min_price(40.50)).to eq([@item2, @item3])
    end
  end

  describe 'search by max price' do
    it 'should return array of items with a price greater than or equal to the max price params' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @item1 = create(:item, unit_price: 40.20, merchant_id: @merchant1.id)
      @item2 = create(:item, unit_price: 40.50, merchant_id: @merchant1.id)
      @item3 = create(:item, unit_price: 60, merchant_id: @merchant2.id)
      @item4 = create(:item, unit_price: 20, merchant_id: @merchant2.id)

      expect(Item.search_by_max_price(40.50)).to eq([@item1, @item2, @item4])
    end
  end

  describe 'search by max and min price' do
    it 'should return combined array of items returned from max and min search methods' do
      @merchant1 = create(:merchant)
      @merchant2 = create(:merchant)
      @item1 = create(:item, unit_price: 40.20, merchant_id: @merchant1.id)
      @item2 = create(:item, unit_price: 40.50, merchant_id: @merchant1.id)
      @item3 = create(:item, unit_price: 60, merchant_id: @merchant2.id)
      @item4 = create(:item, unit_price: 20, merchant_id: @merchant2.id)

      expect(Item.search_by_max_and_min_price(40.20, 60)).to eq([@item1, @item2, @item3])
    end
  end

  describe 'all_items_search' do
    it 'should return all items by keyword search' do
      merchant = create(:merchant)
      item1 = create(:item, name: "Bob", merchant_id: merchant.id)
      item2 = create(:item, name: "Turing", merchant_id: merchant.id)
      item3 = create(:item, name: "Merchant Bring It", merchant_id: merchant.id)
      item4 = create(:item, name: "Billy", merchant_id: merchant.id)

      expect(Item.all_items_search("ring")).to eq([item3, item2])
    end
  end
end
