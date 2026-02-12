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

puts "✓ Created #{Collection.count} collections"

# Create products
puts "\nCreating products..."

# Navidad products
Product.create!([
  {
    name: 'Empanada de Pavo Navideño',
    description: 'Empanada rellena de pavo tierno con especias navideñas tradicionales',
    price: 15.00,
    featured: true,
    seasonal: true,
    active: true,
    collection: navidad
  },
  {
    name: 'Empanada de Manzana con Canela',
    description: 'Delicioso postre navideño con manzanas frescas y canela',
    price: 12.00,
    featured: false,
    seasonal: true,
    active: true,
    collection: navidad
  }
])

# Thanksgiving products
Product.create!([
  {
    name: 'Empanada de Pavo con Arándanos',
    description: 'Pavo jugoso con salsa de arándanos casera',
    price: 14.00,
    featured: true,
    seasonal: true,
    active: true,
    collection: thanksgiving
  },
  {
    name: 'Empanada de Camote Dulce',
    description: 'Camote dulce guatemalteco con especias',
    price: 11.00,
    featured: false,
    seasonal: true,
    active: true,
    collection: thanksgiving
  }
])

# Traditional products
Product.create!([
  {
    name: 'Empanada de Carne',
    description: 'Clásica empanada guatemalteca de carne molida con papas y especias',
    price: 10.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Pollo',
    description: 'Pollo desmenuzado con vegetales frescos',
    price: 10.00,
    featured: true,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Frijol con Queso',
    description: 'Frijoles negros guatemaltecos con queso fresco',
    price: 9.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  },
  {
    name: 'Empanada de Loroco',
    description: 'Flor de loroco con queso, un sabor único de Guatemala',
    price: 11.00,
    featured: false,
    seasonal: false,
    active: true,
    collection: tradicionales
  }
])

puts "✓ Created #{Product.count} products"

# Create contacts
puts "\nCreating sample contacts..."
Contact.create!([
  {
    first_name: 'María',
    last_name: 'González',
    phone_number: '+50212345001',
    preferred_channel: 'whatsapp',
    opt_in_status: true,
    opt_in_source: 'website',
    opt_in_timestamp: 1.week.ago,
    tags: 'cliente-frecuente, navidad'
  },
  {
    first_name: 'Juan',
    last_name: 'Pérez',
    phone_number: '+50212345002',
    preferred_channel: 'whatsapp',
    opt_in_status: true,
    opt_in_source: 'tienda',
    opt_in_timestamp: 2.weeks.ago,
    tags: 'nuevo-cliente'
  },
  {
    first_name: 'Ana',
    last_name: 'Martínez',
    phone_number: '+50212345003',
    preferred_channel: 'sms',
    opt_in_status: true,
    opt_in_source: 'referido',
    opt_in_timestamp: 3.days.ago,
    tags: 'tradicionales, loroco'
  },
  {
    first_name: 'Carlos',
    phone_number: '+50212345004',
    preferred_channel: 'whatsapp',
    opt_in_status: false,
    do_not_contact: false
  }
])

puts "✓ Created #{Contact.count} contacts"

# Create a sample campaign
puts "\nCreating sample campaign..."
campaign = Campaign.create!(
  name: 'Promoción Navideña 2026',
  message_template: 'Hola {{first_name}}! 🎄 Tenemos empanadas especiales para Navidad. Ordena ahora!',
  segment_tags: 'navidad',
  user: admin,
  status: 'draft'
)

puts "✓ Created sample campaign: #{campaign.name}"

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
