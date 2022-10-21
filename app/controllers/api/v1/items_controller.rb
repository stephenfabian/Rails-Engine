class Api::V1::ItemsController < ApplicationController
  
  def index
    items = Item.all
    render json: ItemSerializer.new(items)
  end

  def show
    if Item.exists?(params[:id]) == false
      render json: {"data": {}}, status: 404 
    else
      item = Item.find(params[:id])
      render json: ItemSerializer.new(item)
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render json: {"data": {}}, status: 400
    end
  end

  def update
    item = Item.update(params[:id], item_params)  
    if item.save
      render json: ItemSerializer.new(item)
    else
      render json: {"data": {}}, status: 404
    end
  end

  def destroy
    if Item.exists?(params[:id]) 
      item = Item.find(params[:id])
      item.destroy_inv_having_one_item
      render json: Item.destroy(params[:id])
    else
      render json: {"data": {}}, status: 404
    end
  end

  def find_all
    if params[:name] && (params[:min_price] || params[:max_price])
      render status: 400 
    elsif params[:name] && (params[:min_price] == nil && params[:max_price] == nil) 
      item = Item.all_items_search(params[:name])
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
      item = Item.all_items_search(params[:name])
      render json: ItemSerializer.new(item)
      render json: {error: {}}, status: 400 if !item
    end
  end

  private
  
  def item_params
    params.require(:item).permit(:id, :name, :description, :unit_price, :merchant_id)
  end
end