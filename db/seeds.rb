require "open-uri"

# Helper: attach a photo from a remote URL to a product.
# Gracefully skips if the download fails (e.g. no internet at seed time).
def attach_photo(product, url, filename)
  io = URI.open(url, "User-Agent" => "TiendaEmpanadas/1.0") # rubocop:disable Security/Open
  product.photos.attach(io: io, filename: filename, content_type: "image/jpeg")
  puts "  ✓ Foto adjuntada a #{product.name}"
rescue StandardError => e
  puts "  ⚠ No se pudo adjuntar foto a #{product.name}: #{e.message}"
end

# Unsplash CDN photos — keyed by product slug.
# These are public domain-equivalent photos. Fallback gracefully if unreachable.
PRODUCT_PHOTOS = {}.freeze

# Clear existing data
puts "Clearing existing data..."
Message.destroy_all
Campaign.destroy_all
Contact.destroy_all
Product.destroy_all
Collection.destroy_all
User.destroy_all

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@tiendaempanadas.com',
  password: 'password123',
  password_confirmation: 'password123',
  admin: true
)
puts "✓ Admin user created: #{admin.email} / password123"

# Create collections
puts "\nCreating collections..."
navidad = Collection.create!(
  name: 'Navidad',
  description: 'Deliciosas empanadas para la temporada navideña',
  active: true,
  position: 1
)

thanksgiving = Collection.create!(
  name: 'Thanksgiving',
  description: 'Empanadas especiales para el Día de Acción de Gracias',
  active: true,
  position: 2
)

tradicionales = Collection.create!(
  name: 'Tradicionales',
  description: 'Nuestras empanadas clásicas disponibles todo el año',
  active: true,
  position: 3
)

semana_santa = Collection.create!(
  name: 'Semana Santa',
  description: 'Sabores especiales para la temporada de Semana Santa',
  active: true,
  position: 4
)

puts "✓ Created #{Collection.count} collections"

# Create products
puts "\nCreating products..."

# --- Empanadas saladas (Tradicionales) ---
Product.create!([
  {
    name: 'Empanada de Espinaca',
    description: 'Empanada rellena de espinaca fresca con queso',
    price: 15.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada Argentina',
    description: 'Empanada estilo argentino con relleno clásico de carne',
    price: 15.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Chorizo',
    description: 'Empanada rellena de chorizo artesanal',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Pollo',
    description: 'Empanada rellena de pollo desmenuzado',
    price: 15.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Carne con Verdura',
    description: 'Empanada de carne molida con verduras frescas',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Vegetales',
    description: 'Empanada rellena de vegetales frescos de temporada',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  }
])

# --- Empanadas dulces (Tradicionales) ---
Product.create!([
  {
    name: 'Empanada de Guayaba con Queso',
    description: 'Empanada dulce rellena de guayaba con queso crema',
    price: 15.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Manzana Tradicional',
    description: 'Empanada dulce de manzana con canela al estilo tradicional',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Manzana con Berries',
    description: 'Empanada dulce de manzana combinada con frutos rojos',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Pera',
    description: 'Empanada dulce rellena de pera caramelizada',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Piña',
    description: 'Empanada dulce rellena de piña fresca',
    price: 15.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  }
])

# --- Platos fuertes (Tradicionales) ---
Product.create!([
  {
    name: 'Carpacho de Lomito',
    description: 'Carpacho de lomito fino. Rinde para 8 personas',
    price: 295.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Paella',
    description: 'Paella preparada al momento. Q175 por porción, tamaño variable de 5 a 22 personas',
    price: 175.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Lasaña',
    description: 'Lasaña casera por porción',
    price: 90.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  }
])

# --- Navidad ---
Product.create!([
  {
    name: 'Pavo Navideño',
    description: 'Pavo navideño de 12 libras. Incluye dos acompañantes: puré de papa y ensalada',
    price: 1190.00,
    featured: true,
    seasonal: true,
    active: true,
    collection: navidad
  },
  {
    name: 'Pastel Navideño',
    description: 'Pastel navideño tradicional',
    price: 140.00,
    featured: true,
    seasonal: true,
    active: true,
    collection: navidad
  }
])

# --- Semana Santa ---
Product.create!([
  {
    name: 'Empanada de Atún',
    description: 'Empanada rellena de atún, especial para Semana Santa',
    price: 15.00,
    featured: true,
    seasonal: true,
    active: true,
    collection: semana_santa
  }
])

puts "✓ Created #{Product.count} products"

# Attach photos from Unsplash
puts "\nAttaching product photos (requires internet)..."
Product.all.each do |product|
  url = PRODUCT_PHOTOS[product.slug]
  next unless url

  attach_photo(product, url, "#{product.slug}.jpg")
end

# Create contacts
puts "\nCreating sample contacts..."
Contact.create!([
  {
    first_name: 'Pepito (sample/ejemplo)',
    last_name: 'De Los Palotes',
    phone_number: '+50212345001',
    preferred_channel: 'whatsapp',
    opt_in_status: true,
    opt_in_source: 'website',
    opt_in_timestamp: 1.week.ago,
    tags: 'cliente-frecuente, navidad'
  },
  {
    first_name: 'Fulanita (sample/ejemplo)',
    last_name: 'De Tal',
    phone_number: '+50212345002',
    preferred_channel: 'whatsapp',
    opt_in_status: true,
    opt_in_source: 'tienda',
    opt_in_timestamp: 2.weeks.ago,
    tags: 'nuevo-cliente'
  },
  {
    first_name: 'Mengano (sample/ejemplo)',
    last_name: 'Inventado',
    phone_number: '+50212345003',
    preferred_channel: 'sms',
    opt_in_status: true,
    opt_in_source: 'referido',
    opt_in_timestamp: 3.days.ago,
    tags: 'tradicionales'
  },
  {
    first_name: 'Zutanito (sample/ejemplo)',
    phone_number: '+50212345004',
    preferred_channel: 'whatsapp',
    opt_in_status: false,
    do_not_contact: false
  }
])

puts "✓ Created #{Contact.count} contacts"

# Create sample campaigns (one of each type)
puts "\nCreating sample campaigns..."

Campaign.create!(
  name: 'Empanadas de la semana (sample/ejemplo)',
  message_template: 'Hola {{first_name}}! Esta semana tenemos empanadas frescas listas para ti. Escríbenos para hacer tu pedido!',
  user: admin,
  status: 'draft',
  campaign_type: 'recurring',
  active: true,
  recurring_interval_days: 10,
  starts_on: Date.current
)

Campaign.create!(
  name: 'Promoción Navideña 2026 (sample/ejemplo)',
  message_template: 'Hola {{first_name}}! Tenemos empanadas especiales para Navidad. Ordena ahora!',
  segment_tags: 'navidad',
  user: admin,
  status: 'draft',
  campaign_type: 'seasonal',
  active: true,
  starts_on: Date.new(2026, 12, 1),
  ends_on: Date.new(2026, 12, 25)
)

Campaign.create!(
  name: '2x1 en empanadas dulces (sample/ejemplo)',
  message_template: 'Hola {{first_name}}! Solo esta semana: 2x1 en todas las empanadas dulces. No te lo pierdas!',
  user: admin,
  status: 'draft',
  campaign_type: 'promotional',
  active: true,
  starts_on: Date.current,
  ends_on: Date.current + 7.days
)

puts "✓ Created #{Campaign.count} sample campaigns"

puts "\n" + "="*50
puts "✅ SEEDS COMPLETED!"
puts "="*50
puts "\nAdmin Login:"
puts "  Email: admin@tiendaempanadas.com"
puts "  Password: password123"
puts "\nCollections: #{Collection.count}"
puts "Products: #{Product.count}"
puts "Contacts: #{Contact.count}"
puts "Campaigns: #{Campaign.count}"
puts "\nRun 'rails server' to start the application!"
