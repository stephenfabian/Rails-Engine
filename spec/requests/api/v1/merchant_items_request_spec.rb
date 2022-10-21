require 'rails_helper'

RSpec.describe 'Merchant Items Request' do
  it 'gets all items for a given merchant ID' do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)

    get api_v1_merchant_items_path(@merchant1)

    items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(items).to have_key(:data)
    expect(items[:data].count).to eq(3)

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
      expect(attributes[:merchant_id]).to eq(@merchant1.id)
    end
  end
end