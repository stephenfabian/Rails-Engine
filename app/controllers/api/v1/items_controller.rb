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
    render json: ItemSerializer.new(Item.create(item_params)), status: 201
  end

  def update
    item = Item.update(params[:id], item_params)  
    if item.save
      render json: ItemSerializer.new(item)
    else
      render status: 404
    end
  end

  def destroy
    item = Item.find(params[:id])
    item.destroy_inv_having_one_item
    render json: Item.destroy(params[:id])
  end

  def find_all
    if params[:name] && (params[:min_price] || params[:max_price])
      render status: 400 
    elsif params[:name] && (params[:min_price] == nil && params[:max_price] == nil) # +
      item = Item.single_item_search(params[:name])
      render json: ItemSerializer.new(item)
    elsif (params[:min_price] || params[:max_price]) && (params[:min_price].to_i < 0 || params[:max_price].to_i < 0)
      render json: {error: {}}, status: 400
    elsif params[:min_price] && params[:max_price]
      items = Item.search_by_max_and_min_price(params[:min_price], params[:max_price])
      render json: ItemSerializer.new(items)
    elsif params[:min_price] && params[:max_price] == nil 
      items = Item.search_by_min_price(params[:min_price])
      render json: ItemSerializer.new(items)
    elsif params[:min_price] == nil && params[:max_price]
      items = Item.search_by_max_price(params[:max_price])
      render json: ItemSerializer.new(items)
    end
  end

  def find
    if params[:name] && (params[:min_price] || params[:max_price])
      render status: 400 
    elsif (params[:min_price] || params[:max_price]) && (params[:min_price].to_i < 0 || params[:max_price].to_i < 0)
      render json: {error: {}}, status: 400
    elsif params[:name] && (params[:min_price] == nil && params[:max_price] == nil)
      item = Item.single_item_search(params[:name])
      render json: ItemSerializer.new(item)
      render json: {error: {}}, status: 400 if !item
    end
  end

  private
  
  def item_params
    params.require(:item).permit(:id, :name, :description, :unit_price, :merchant_id)
  end
end