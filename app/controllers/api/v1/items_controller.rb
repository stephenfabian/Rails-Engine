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
   render json: ItemSerializer.new(Item.create(item_params)), status: 201
  end

  # def update
  #   item = Item.find(params[:id])
  #   merchant_id = params[:item][:merchant_id]

  #   if merchant_id 
  #     merchant = Merchant.find(merchant_id)
  #   else
  #     merchant = item.merchant
  #   end

  #   # if params[:item][:merchant_id] && Merchant.exists?(params[:item][:merchant_id]) 
  #   #   merchant = Merchant.find(params[:item][:merchant_id])
  #   # elsif Merchant.exists?(params[:item][:merchant_id]) == false

  #   # else
  #   #   merchant = item.merchant

  #   # end

  #   if !item || !merchant
  #     render status: 404
  #     # render json: {data: nil}, status: 404
  #   end
    
  #   item.update(item_params)
  #   if item.save
  #     render json: ItemSerializer.new(Item.update(params[:id], item_params))
  #   end
  #   # render json: ItemSerializer.new(item.update(item_params))
  # end

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
    render json: ItemSerializer.new(item.destroy)
    # not utilize a serializer?????
  end
  
  #min price < 0, render 400
  #max price < 0, render 400

  def find_all
    if params[:name] && (params[:min_price] || params[:max_price])
      render status: 400 
    elsif (params[:min_price] || params[:max_price]) && (params[:min_price].to_i < 0 || params[:max_price].to_i < 0)
      render status: 400 #need error format (expect(payload).to.have.property('error')?
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

  private
  def item_params
    params.require(:item).permit(:id, :name, :description, :unit_price, :merchant_id)
  end
end