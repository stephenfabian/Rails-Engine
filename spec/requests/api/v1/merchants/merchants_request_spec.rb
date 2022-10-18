require 'rails_helper' 

RSpec.describe 'Merchants' do
  it 'can get all merchants' do
    create_list(:merchant, 3)
    get '/api/v1/merchants'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchants.count).to eq(3)

    merchants.each do |merchant|
      expect(merchant[:name]).to be_a(String)
      expect(merchant[:id]).to be_a(Integer)
    end
  end

  it 'can get a single merchant' do
    create_list(:merchant, 3)
    # merchant_to_find = Merchant.first
    # get "/api/v1/merchants/#{merchant_to_find.id}"

    id = create(:merchant).id
    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq("#{id}")
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end
end