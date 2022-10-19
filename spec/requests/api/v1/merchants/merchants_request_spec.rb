require 'rails_helper' 

RSpec.describe 'Merchants' do
  it 'can get all merchants' do
    create_list(:merchant, 3)
    get '/api/v1/merchants'

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchants[:data].count).to eq(3)

    merchants.each do |merchant|
      expect(merchant[1].count).to eq(3)
      expect(merchant[1].first[:id]).to be_a(String)
      expect(merchant[1].first[:attributes]).to be_a(Hash)
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

  it 'can find one merchant by search criteria' do
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
end