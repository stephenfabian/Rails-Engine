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
    # require 'pry'; binding.pry
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq("#{@merchant1.id}")
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end
end
