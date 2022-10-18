class Api::V1::ItemsController < ApplicationController
  
  def index
    items = Item.all
    render json: ItemSerializer.new(items)
  end

  def show
    item = Item.find(params[:id])
    render json: ItemSerializer.new(item)
  end

  def create
    # require 'pry'; binding.pry
   render json: Item.create(item_params)
  end

  def update
    # item = Item.find(params[:id])
    # render json: item.update(item_params)
    render json: ItemSerializer.new(Item.update(params[:id], item_params))
  end
  private

  def item_params
    params.require(:item).permit(:id, :name, :description, :unit_price, :merchant_id)
  end
end