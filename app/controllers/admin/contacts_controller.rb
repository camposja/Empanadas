class Admin::ContactsController < Admin::BaseController
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = Contact.all.order(created_at: :desc)
  end

  def show; end

  def new
    @contact = Contact.new
  end

  def edit; end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      redirect_to [ :admin, @contact ], notice: "Contacto creado exitosamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @contact.update(contact_params)
      redirect_to [ :admin, @contact ], notice: "Contacto actualizado exitosamente.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy!
    redirect_to admin_contacts_path, notice: "Contacto eliminado exitosamente.", status: :see_other
  end

  private

  def set_contact
    @contact = Contact.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :phone_number, :preferred_channel,
      :opt_in_status, :do_not_contact, :tags, :notes, :opt_in_source
    )
  end
end
