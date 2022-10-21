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
end