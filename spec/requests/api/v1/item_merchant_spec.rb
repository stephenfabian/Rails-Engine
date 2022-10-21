require 'rails_helper'

RSpec.describe "ItemMerchants", type: :request do
  it 'can get an items merchant' do
    @merchant1 = create(:merchant)
    @merchant2 = create(:merchant)
    item = create(:item, merchant_id: @merchant1.id)
    create_list(:item, 3, merchant_id: @merchant2.id)

    get "/api/v1/items/#{item.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)
    
    expect(response).to be_successful

    expect(merchant).to be_a(Hash)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq("#{@merchant1.id}")
    expect(merchant[:data]).to be_a(Hash)
    expect(merchant[:data]).to have_key(:type)
    expect(merchant[:data][:type]).to be_a(String)
    attributes = merchant[:data][:attributes]
    expect(attributes).to have_key(:name)
    expect(attributes[:name]).to be_a(String)
  end
end
