class MerchantSerializer
  include JSONAPI::Serializer
  attributes :name

  def self.merchants_by_revenue_serialized(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id,
          type: "merchant",
          attributes: {
            name: merchant.name,
            revenue: merchant.revenue
          }
        }
      end
    } 
  end

  def self.merchants_by_most_items_serialized(merchants)
    {
      data: merchants.map do |merchant|
        {
          id: merchant.id,
          type: "merchant",
          attributes: {
            name: merchant.name,
            count: merchant.count_of_items
          }
        }
      end
    } 
  end

  def self.total_revenue_serialized(revenue_param)
    {
    "data": {
      "id": nil,
      "attributes": {
        "revenue": revenue_param
      }
    }
    }
  end
end
