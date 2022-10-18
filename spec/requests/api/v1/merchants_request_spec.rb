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
    end
    require 'pry'; binding.pry
  end
end