class ItemSerializer
  include JSONAPI::Serializer
  # from andrew - add belongs to relationship if we want relationships to show in our json
  attributes :name, :description, :unit_price, :merchant_id
end
