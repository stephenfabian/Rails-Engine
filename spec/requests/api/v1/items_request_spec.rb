require 'rails_helper'

RSpec.describe 'Items Request' do
  it 'can get all items' do
    merchant1 = create(:merchant)
    merchant2 = create(:merchant)
    items1 = create_list(:item, 3, merchant_id: merchant1.id)
    items2 = create_list(:item, 3, merchant_id: merchant2.id)

    get '/api/v1/items'
    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items).to have_key(:data)
    expect(items[:data].count).to eq(6)

    items[:data].each do |item|
      expect(item).to be_a(Hash)
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)
      expect(item).to have_key(:type)
      expect(item[:type]).to be_a(String)
      expect(item).to have_key(:attributes)
      attributes = item[:attributes]
      expect(attributes).to be_a(Hash)
      expect(attributes).to have_key(:name)
      expect(attributes[:name]).to be_a(String)
      expect(attributes).to have_key(:unit_price)
      expect(attributes[:unit_price]).to be_a(Float)
      expect(attributes).to have_key(:merchant_id)
      expect(attributes[:merchant_id]).to be_a(Integer)
    end
  end

  it 'get all items sad path - returns empty array if there are no items' do
    get '/api/v1/items'

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items[:data]).to eq([])
  end

  it 'get a single item' do
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
    expect(item[:data][:id]).to eq("#{id}")
    expect(item[:data]).to be_a(Hash)
    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to be_a(String)
    attributes = item[:data][:attributes]
    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)
    expect(attributes).to have_key(:description)
    expect(attributes[:description]).to be_a(String)
    expect(attributes).to have_key(:unit_price)
    expect(attributes[:unit_price]).to be_a(Float)
    expect(attributes).to have_key(:merchant_id)
    expect(attributes[:merchant_id]).to be_a(Integer)
  end

  it 'get a single item sad path - return 404 if item doesnt exist' do
    get "/api/v1/items/#{55}" 

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to have_http_status(404)
    expect(item[:data]).to eq({})
  end

  it 'can create an item' do 
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

  it 'create an item sad path - missing params (no unit_price)' do
    @merchant1 = create(:merchant)

    item_params = ({
                    name: "Super Big Hat",
                    description: "The coolest hat",                  
                    merchant_id: @merchant1.id
                  })

    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    item_response = JSON.parse(response.body, symbolize_names: true)
    expect(response).to have_http_status(400)
    expect(item_response[:data]).to eq({})
  end

  it 'update an item' do
    @merchant1 = create(:merchant)
    id = create(:item, merchant_id: @merchant1.id).id
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


  it 'update an item sad path - if merchant id doesnt exist when trying to update item, return status 401' do
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

  it 'destroy an item' do
    @merchant1 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)

    item = Item.last
    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(2)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'destroy an item sad path - if item doesnt exit, return 401' do
    delete "/api/v1/items/1"

    expect(response).to have_http_status(404)
  end

  it 'destroy an item edge case - if invoice has only one item, destroy invoice and dependents' do
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
      @item1 = create(:item, name: "Titanium Ring", unit_price: 40.2, merchant_id: @merchant1.id)
      @item2 = create(:item, name: "Turing Item", unit_price: 40.5, merchant_id: @merchant1.id)
      @item3 = create(:item, name: "Joy Bringer", unit_price: 60, merchant_id: @merchant2.id)
      @item4 = create(:item, name: "Bike", unit_price: 20, merchant_id: @merchant2.id)
    end

    it 'can find all items above a minimum price' do
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

    it 'find all items below a maximum price' do
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

    it 'find all items within a range of min price and max price' do
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

    it 'find all items edge case - if both name and price params are sent (find all endpoint), error message is rendered' do
      get "/api/v1/items/find_all?name=ring&min_price=50"

      expect(response).to have_http_status(400)
    end

    it 'find all items edge case - if both name and price params are sent (find endpoint), error message is rendered' do
      get "/api/v1/items/find?name=ring&min_price=50"

      expect(response).to have_http_status(400)
    end


    it 'find all items by name' do
      get "/api/v1/items/find?name=ring"

      items = JSON.parse(response.body, symbolize_names: true)

      items[:data].each do |item|
        expect(item).to be_a(Hash)
        expect(item[:id]).to be_a(String)
        expect(item[:attributes]).to be_a(Hash)
      end

      expect(items[:data].count).to eq(3)
      expect(items[:data].first[:id]).to eq(@item3.id.to_s)
      expect(items[:data].first[:attributes][:unit_price]).to eq(@item3.unit_price)
      expect(items[:data].second[:id]).to eq(@item1.id.to_s)
      expect(items[:data].second[:attributes][:unit_price]).to eq(@item1.unit_price)
      expect(items[:data].third[:id]).to eq(@item2.id.to_s)
      expect(items[:data].third[:attributes][:unit_price]).to eq(@item2.unit_price)
    end
  end

    it 'find all items edge case (find endpoint) - if min or max price is less than 0, return status 400' do
      get "/api/v1/items/find?min_price=-10"

      expect(response).to have_http_status(400)
    end

    it 'find all items edge case (find all endpoint) - if min or max price is less than 0, return status 400' do
      get "/api/v1/items/find_all?min_price=-10"

      expect(response).to have_http_status(400)
    end
end