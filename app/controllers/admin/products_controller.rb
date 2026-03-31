class Admin::ProductsController < Admin::BaseController
  before_action :set_product, only: %i[show edit update destroy]
  before_action :set_collections, only: %i[new edit create update]

  def index
    @products = Product.includes(:collection).order(created_at: :desc)
  end

  def show; end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to [ :admin, @product ], notice: "Producto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to [ :admin, @product ], notice: "Producto actualizado exitosamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy!
    redirect_to admin_products_path, notice: "Producto eliminado exitosamente.", status: :see_other
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  end

  def set_collections
    @collections = Collection.order(position: :asc, name: :asc)
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :collection_id,
      :active, :featured, :seasonal,
      photos: []
    )
  end
end
