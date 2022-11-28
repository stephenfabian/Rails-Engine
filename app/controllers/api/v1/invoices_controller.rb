class Api::V1::InvoicesController < ApplicationController

  def revenue_by_date_range
    start_date = params[:start]
    end_date = params[:end] 
    total_revenue = Invoice.total_revenue(start_date, end_date)
    render json: MerchantSerializer.total_revenue_serialized(total_revenue)
  end
end