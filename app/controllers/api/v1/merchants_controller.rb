class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantSerializer.new(merchants)
  end

  def show
    if Merchant.exists?(params[:id]) == false
      render json: {"data": {}}, status: 404 
    else
      merchant = Merchant.find(params[:id])
      render json: MerchantSerializer.new(merchant)
    end
  end

  def find
    # require 'pry'; binding.pry
    no_merchant_data = {"data": {}}

    merchant = Merchant.single_merchant_search(params[:name])

    if !merchant == true
      render json: (no_merchant_data)
    else
      render json: MerchantSerializer.new(merchant)
    end
  end

  def find_by_revenue
    number_of_merchants = params[:quantity]
    merchants = Merchant.merchants_by_revenue(number_of_merchants)
    render json: MerchantSerializer.merchants_by_revenue_serialized(merchants)
  end

  def most_items
    number_of_merchants = params[:quantity]
     merchants = Merchant.most_items(number_of_merchants)
      render json: MerchantSerializer.merchants_by_most_items_serialized(merchants)
  end
end