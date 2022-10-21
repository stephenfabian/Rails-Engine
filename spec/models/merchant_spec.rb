require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many :items }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
  
  describe 'single_merchant_search' do
    it 'can return a single merchant by name search' do
      create(:merchant, name: "Bob")
      create(:merchant, name: "Turing")
      merchant_to_return = create(:merchant, name: "Merchant Bring It")
      create(:merchant, name: "Billy")

      expect(Merchant.single_merchant_search("ring")).to eq(merchant_to_return)
    end
  end
end




                 
