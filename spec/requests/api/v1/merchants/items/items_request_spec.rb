require 'rails_helper'

RSpec.describe 'Items Request' do
  it 'can get all items' do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)
    create_list(:item, 3, merchant_id: @merchant2.id)

    get '/api/v1/items'
    items = JSON.parse(response.body, symbolize_names: true)

    expect(items[:data].count).to eq(6)
    expect(response).to be_successful

    items[:data].each do |item|
      expect(item).to be_a(Hash)
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item).to have_key(:attributes)
      expect(item[:attributes]).to be_a(Hash)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes].count).to eq(4)

      expect(item[:attributes][:name]).to be_a(String)
    end

  end

  it 'can get a single item' do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)
    create_list(:item, 3, merchant_id: @merchant2.id)

    id = Item.first.id
    get "/api/v1/items/#{id}"    

    item = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(item).to be_a(Hash)
    expect(item[:data]).to have_key(:id)
    expect(item[:data]).to be_a(Hash)
    expect(item[:data][:id]).to eq("#{id}")
    expect(item[:data][:attributes][:name]).to be_a(String)
    expect(item[:data][:attributes].count).to eq(4)
  end

  it 'can create an item' do #may need additional tests on response structure
    @merchant1 = create(:merchant)

    item_params = ({
                    name: "Super Big Hat",
                    description: "The coolest hat",
                    unit_price: 10.99,
                    merchant_id: @merchant1.id
                  })

    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq("The coolest hat")
    expect(created_item.unit_price).to eq(10.99)
    expect(created_item.merchant_id).to eq(created_item[:merchant_id]) 
  end

  it 'can edit an item' do
    @merchant1 = create(:merchant)
    id = create(:item, merchant_id: @merchant1.id).id
    # require 'pry'; binding.pry
    previous_name = Item.last.name
    params = ({
                    name: "Tiny Hat"
                  })
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: params})
    updated_item = Item.find(id)

    expect(response).to be_successful
    expect(updated_item[:name]).to eq(params[:name])
    expect(updated_item[:name]).to_not eq(previous_name)
  end


  it 'if merchant id doesnt exist when trying to update item, return status 401' do
    @merchant1 = create(:merchant, id: 5)
    @item1 = create(:item, merchant_id: @merchant1.id)

    params = ({
                name: "Tiny Hat",
                merchant_id: 99
              })
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{@item1.id}", headers: headers, params: JSON.generate({item: params})

    expect(response).to have_http_status(404)
  end

  it 'can destroy an item' do
    @merchant1 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)

    item = Item.last
    delete "/api/v1/items/#{item.id}"
   
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

    it 'if invoice has only one ii, destroy invoice and dependents' do
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
      @invoice_item2 = InvoiceItem.create!(item_id: @item1.id, invoice_id: @invoice2.id, quantity: 6, unit_price: 40)
      @invoice_item3 = InvoiceItem.create!(item_id: @item3.id, invoice_id: @invoice2.id, quantity: 5, unit_price: 40)
      
      expect(@item1.invoices).to eq([@invoice1, @invoice2])
      expect(@invoice1.invoice_items.count).to eq(1)
      expect(@invoice2.invoice_items.count).to eq(2)
      
      delete "/api/v1/items/#{@item1.id}"
    
      expect{Item.find(@item1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{Invoice.find(@invoice1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(Invoice.find(@invoice2.id)).to eq(@invoice2)
      expect{InvoiceItem.find(@invoice_item1.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect{Transaction.find(@transaction1.id)}.to raise_error(ActiveRecord::RecordNotFound)

      delete "/api/v1/items/#{@item2.id}"

      expect(Invoice.find(@invoice2.id)).to eq(@invoice2)
      expect{InvoiceItem.find(@invoice_item2.id)}.to raise_error(ActiveRecord::RecordNotFound)
      expect(InvoiceItem.find(@invoice_item3.id)).to eq(@invoice_item3)
      expect(Transaction.find(@transaction2.id)).to eq(@transaction2)
    end
    
    describe 'Part 2 - All Items Search' do
      before :each do
        @merchant1 = create(:merchant)
        @merchant2 = create(:merchant)
        @item1 = create(:item, unit_price: 40.2, merchant_id: @merchant1.id)
        @item2 = create(:item, unit_price: 40.5, merchant_id: @merchant1.id)
        @item3 = create(:item, unit_price: 60, merchant_id: @merchant2.id)
        @item4 = create(:item, unit_price: 20, merchant_id: @merchant2.id)
      end

    it 'can find all items above a minimum price sent in params' do

      get "/api/v1/items/find_all?min_price=40.5"

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a(Hash)
      expect(items[:data]).to be_a(Array)
      expect(items[:data].count).to eq(2)

      items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item[:id]).to be_a(String)
        expect(item[:attributes]).to be_a(Hash)
      end

      expect(items[:data].first[:id]).to eq(@item2.id.to_s)
      expect(items[:data].first[:attributes][:unit_price]).to eq(@item2.unit_price)
      expect(items[:data].second[:id]).to eq(@item3.id.to_s)
      expect(items[:data].second[:attributes][:unit_price]).to eq(@item3.unit_price)
    end

    it 'can find all items below a maximum price sent in params' do

      get "/api/v1/items/find_all?max_price=40.2"

      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a(Hash)
      expect(items[:data]).to be_a(Array)
      expect(items[:data].count).to eq(2)

      items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item[:id]).to be_a(String)
        expect(item[:attributes]).to be_a(Hash)
      end

      expect(items[:data].first[:id]).to eq(@item1.id.to_s)
      expect(items[:data].first[:attributes][:unit_price]).to eq(@item1.unit_price)
      expect(items[:data].second[:id]).to eq(@item4.id.to_s)
      expect(items[:data].second[:attributes][:unit_price]).to eq(@item4.unit_price)
    end

    it 'can find items within a range of min price and max price' do
      get "/api/v1/items/find_all?max_price=60&min_price=40.5"
      
      items = JSON.parse(response.body, symbolize_names: true)

      expect(items).to be_a(Hash)
      expect(items[:data]).to be_a(Array)
      expect(items[:data].count).to eq(2)

      items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item[:id]).to be_a(String)
        expect(item[:attributes]).to be_a(Hash)
      end

      expect(items[:data].first[:id]).to eq(@item2.id.to_s)
      expect(items[:data].first[:attributes][:unit_price]).to eq(@item2.unit_price)
      expect(items[:data].second[:id]).to eq(@item3.id.to_s)
      expect(items[:data].second[:attributes][:unit_price]).to eq(@item3.unit_price)
    end

    it 'if both name param and price param are sent, error message is rendered' do

    end

    it 'can find all items whos name matches keyword search' do
            # get "/api/v1/items/find_all?max_price=999"
      # get "/api/v1/items/find_all?name=ring&min_price=50"
      # get "/api/v1/items/find_all?name=ring"
    end
  end
end