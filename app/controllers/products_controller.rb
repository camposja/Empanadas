class ProductsController < ApplicationController
  def index
    @products = Product.active.includes(:collection)
    @products = @products.where(collection_id: params[:collection_id]) if params[:collection_id].present?
    @collections = Collection.active.ordered
  end

  def show
    @product = Product.friendly.find(params[:id])
    @related_products = @product.collection
                                .products
                                .active
                                .where.not(id: @product.id)
                                .limit(4)
    @whatsapp_number = ENV.fetch("WHATSAPP_NUMBER", "+50230016011")
    @whatsapp_message = URI.encode_www_form_component(@product.whatsapp_message)
  end
end
