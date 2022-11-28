require 'rails_helper' 

RSpec.describe 'Merchants' do
  it 'can get all merchants' do
    create_list(:merchant, 3)

    get '/api/v1/merchants'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants).to have_key(:data)
    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to be_a(Hash)
      expect(merchant).to have_key(:id)
      expect(merchant[:id]).to be_a(String)
      expect(merchant).to have_key(:type)
      expect(merchant[:type]).to be_a(String)
      expect(merchant).to have_key(:attributes)
      attributes = merchant[:attributes]
      expect(attributes).to be_a(Hash)
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
    end
  end

  it 'get all merchants sad path - returns empty array if there are no merchants' do
    get '/api/v1/merchants'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data]).to eq([])
  end

  it 'get a single merchant' do
    create_list(:merchant, 3)
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to be_successful
    
    expect(merchant).to be_a(Hash)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq("#{id}")
    expect(merchant[:data]).to be_a(Hash)
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to be_a(String)
    attributes = merchant[:data][:attributes]
    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)
  end

  it 'get a single merchant sad path - return 404 if merchant doesnt exist' do
    get "/api/v1/merchants/1"

    merchant = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to have_http_status(404)
    expect(merchant[:data]).to eq({})
  end

  it 'find one merchant by name keyword search' do
    create(:merchant, name: "Bob")
    create(:merchant, name: "Turing")
    merchant_to_return = create(:merchant, name: "Merchant Bring It")
    create(:merchant, name: "Billy")


    search_params = ({
                      name: "ring"
                    })
    get "/api/v1/merchants/find?name=#{search_params[:name]}"
                 
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful
    expect(merchant[:data][:attributes][:name]).to eq("#{merchant_to_return.name}")
    expect(merchant[:data][:attributes][:name]).to be_a(String)
    expect(merchant[:data][:id]).to eq("#{merchant_to_return.id}")
    expect(merchant[:data]).to be_a(Hash)
  end

  it 'find one merchant by name keyword search - sad path - no matching merchant returns empty data hash' do
    create(:merchant, name: "Bob")
    create(:merchant, name: "Turing")
    merchant_to_return = create(:merchant, name: "Merchant Bring It")
    create(:merchant, name: "Billy")

    get "/api/v1/merchants/find?name=Nz"
                 
    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(merchant[:data]).to eq({})
  end

   describe "merchants by most revenue" do
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

      @transaction1 = Transaction.create!(invoice_id: @invoice1.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction2 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction3 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")


      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 10)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 2, unit_price: 20)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 4590)

      get '/api/v1/revenue/merchants?quantity=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)
      # require 'pry'; binding.pry
        expect(merchants).to have_key(:data)
        expect(merchants[:data].count).to eq(2)

        merchants[:data].each do |merchant|
          expect(merchant).to be_a(Hash)
          expect(merchant).to have_key(:id)
          expect(merchant[:id]).to be_a(String)
          expect(merchant).to have_key(:type)
          expect(merchant[:type]).to be_a(String)
          expect(merchant).to have_key(:attributes)
          attributes = merchant[:attributes]
          expect(attributes).to be_a(Hash)
          expect(attributes).to have_key(:name)
          expect(attributes[:name]).to be_a(String)
        end

      # expect(Merchant.merchants_by_revenue(2)).to eq([@merchant3, @merchant2])
    end

   describe "merchants by most items sold" do
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

      @transaction1 = Transaction.create!(invoice_id: @invoice1.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction2 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction3 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")


      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 10)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 2, unit_price: 20)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 4590)

      get '/api/v1/merchants/most_items?quantity=2'

      expect(response).to be_successful
      merchants = JSON.parse(response.body, symbolize_names: true)
      # require 'pry'; binding.pry
        expect(merchants).to have_key(:data)
        expect(merchants[:data].count).to eq(2)

        merchants[:data].each do |merchant|
          expect(merchant).to be_a(Hash)
          expect(merchant).to have_key(:id)
          expect(merchant[:id]).to be_a(String)
          expect(merchant).to have_key(:type)
          expect(merchant[:type]).to be_a(String)
          expect(merchant).to have_key(:attributes)
          attributes = merchant[:attributes]
          expect(attributes).to be_a(Hash)
          expect(attributes).to have_key(:name)
          expect(attributes[:name]).to be_a(String)
        end

      expect(Merchant.most_items(2)).to eq([@merchant3, @merchant2])
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

      @transaction1 = Transaction.create!(invoice_id: @invoice1.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction2 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")
      @transaction3 = Transaction.create!(invoice_id: @invoice2.id, credit_card_number: 4654405418249632, credit_card_expiration_date: "04/23", result: "success")


      @invoice_item1 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice1.id, quantity: 1, unit_price: 10)
      @invoice_item2 = InvoiceItem.create!(item_id: @item2.id, invoice_id: @invoice2.id, quantity: 2, unit_price: 20)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice3.id, quantity: 5, unit_price: 4590)

      get '/api/v1/revenue?start_date=<start_date>&end_date=<end_date>'

      expect(response).to be_successful
      total_revenue = JSON.parse(response.body, symbolize_names: true)
      # require 'pry'; binding.pry
        expect(total_revenue).to have_key(:data)
        expect(total_revenue[:data].count).to eq(2)

          expect(total_revenue).to be_a(Hash)
          expect(total_revenue).to have_key(:id)
          expect(total_revenue[:id]).to be_a(String)
          expect(total_revenue[:data]).to have_key(:attributes)
          expect(attributes).to be_a(Hash)
          expect(attributes).to have_key(:revenue)
          expect(attributes[:revenue]).to be_a(Float)
        end

      end
  end
end