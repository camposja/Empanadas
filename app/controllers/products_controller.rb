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
  end
end
