require 'rails_helper'

RSpec.describe Item, type: :model do
   describe 'relationships' do
    it { should belong_to :merchant }
    it { should have_many :invoice_items }
    it { should have_many(:invoices).through(:invoice_items) }
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
end
