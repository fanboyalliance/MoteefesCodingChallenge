module Api
  class ShippingController < ApplicationController
    def search
      render json: ShippingService.new(params).search_shippings
    end
  end
end