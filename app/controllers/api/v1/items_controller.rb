class Api::V1::ItemsController < ApplicationController
  
  def index
    items = Item.all
    render json: ItemsSerializer.new(items)
  end
end