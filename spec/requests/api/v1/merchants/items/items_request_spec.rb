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
end