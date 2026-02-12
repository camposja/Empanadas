class ProductsController < ApplicationController
  def index
    @products = Product.active.includes(:collection)
    @products = @products.where(collection_id: params[:collection_id]) if params[:collection_id].present?
    @collections = Collection.active.ordered
  end

  def show
    @product = Product.friendly.find(params[:id])
    @whatsapp_number = ENV['WHATSAPP_NUMBER'] || '+50212345678'
    @whatsapp_message = URI.encode_www_form_component(@product.whatsapp_message)
  end
end
