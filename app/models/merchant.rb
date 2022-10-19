class Merchant < ApplicationRecord
  has_many :items

  def self.single_merchant_search(keyword)
    where("name ILIKE ?", "%#{keyword}%").order(:name).first
  end

end
