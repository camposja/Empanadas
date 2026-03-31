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

  def export
    respond_to do |format|
      format.csv do
        send_data Contact.all.order(:created_at).to_csv,
                  filename: "contactos-#{Date.current}.csv",
                  type: "text/csv"
      end
    end
  end

  def import
    file = params[:file]
    unless file.present?
      redirect_to admin_contacts_path, alert: "Selecciona un archivo CSV para importar."
      return
    end

    unless file.content_type == "text/csv" || file.original_filename.end_with?(".csv")
      redirect_to admin_contacts_path, alert: "El archivo debe ser CSV."
      return
    end

    if file.size > 2.megabytes
      redirect_to admin_contacts_path, alert: "El archivo es demasiado grande (máximo 2 MB)."
      return
    end

    require "csv"
    imported = 0
    skipped = 0

    CSV.foreach(file.path, headers: true, encoding: "bom|utf-8") do |row|
      phone = row["Phone Number"].to_s.strip
      next if phone.blank?

      contact = Contact.find_or_initialize_by(phone_number: phone)
      contact.assign_attributes(
        first_name: row["First Name"].to_s.strip.presence || contact.first_name || "Importado",
        last_name: row["Last Name"].to_s.strip.presence || contact.last_name,
        preferred_channel: row["Preferred Channel"].to_s.strip.presence || contact.preferred_channel || "whatsapp",
        opt_in_status: row["Opt-in Status"].to_s.strip.downcase == "true",
        tags: row["Tags"].to_s.strip.presence || contact.tags,
        notes: row["Notes"].to_s.strip.presence || contact.notes
      )

      if contact.save
        imported += 1
      else
        skipped += 1
      end
    end

    redirect_to admin_contacts_path,
                notice: "Importación completa: #{imported} importado#{"s" if imported != 1}, #{skipped} omitido#{"s" if skipped != 1}."
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
