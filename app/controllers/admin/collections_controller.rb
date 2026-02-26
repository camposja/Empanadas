class Admin::CollectionsController < Admin::BaseController
  before_action :set_collection, only: %i[show edit update destroy]

  def index
    @collections = Collection.order(position: :asc, name: :asc)
  end

  def show
    @products = @collection.products.order(name: :asc)
  end

  def new
    @collection = Collection.new(active: true)
  end

  def edit; end

  def create
    @collection = Collection.new(collection_params)
    if @collection.save
      redirect_to [ :admin, @collection ], notice: "Colección creada exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @collection.update(collection_params)
      redirect_to [ :admin, @collection ], notice: "Colección actualizada exitosamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @collection.destroy!
    redirect_to admin_collections_path, notice: "Colección eliminada exitosamente.", status: :see_other
  end

  private

  def set_collection
    @collection = Collection.find(params[:id])
  end

  def collection_params
    params.require(:collection).permit(
      :name, :description, :slug, :active, :position
    )
  end
end
