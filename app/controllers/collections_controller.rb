class CollectionsController < ApplicationController
  def show
    @collection = Collection.friendly.find(params[:id])
    @products = @collection.products.active
  end
end
