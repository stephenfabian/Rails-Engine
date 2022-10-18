require 'rails_helper'

RSpec.describe 'Merchant Items Request' do
  it 'gets all items for a given merchant ID' do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    create_list(:item, 3, merchant_id: @merchant1.id)

    get api_v1_merchant_items_path(@merchant1)

    merchant_items = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(@merchant1.items.count).to eq(3)

    merchant_items.each do |item|
      expect(item[1][0][:id]).to be_a(String)
      expect(item[1][0][:attributes].count).to eq(4)
      expect(item[1][0][:attributes]).to have_key(:name)
      expect(item[1][0][:attributes]).to have_key(:description)
      expect(item[1][0][:attributes]).to have_key(:unit_price)
      expect(item[1][0][:attributes]).to have_key(:merchant_id)
      expect(item[1][0][:attributes][:name]).to be_a(String)
    end
  end
end