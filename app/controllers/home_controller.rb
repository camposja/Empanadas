class HomeController < ApplicationController
  def index
    @featured_products = Product.active.featured.includes(:collection).limit(6)
    @seasonal_products = Product.active.seasonal.includes(:collection).limit(4)
    @collections = Collection.active.ordered
  end
end
