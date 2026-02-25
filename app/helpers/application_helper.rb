module ApplicationHelper
  WHATSAPP_NUMBER = ENV.fetch("WHATSAPP_NUMBER", "+50230016011")

  def format_price(price)
    return "Precio no disponible" if price.nil?

    "Q #{number_with_precision(price, precision: 2, delimiter: ',')}"
  end

  def whatsapp_order_url(product)
    clean_number = WHATSAPP_NUMBER.delete("+").delete(" ")
    message = URI.encode_www_form_component(product.whatsapp_message)
    "https://wa.me/#{clean_number}?text=#{message}"
  end
end
