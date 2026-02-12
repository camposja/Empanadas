# Tienda Empanadas

A complete Ruby on Rails 8 web application for a Guatemala-based empanada business, featuring a public storefront, admin panel, CRM, and messaging campaign system.

## Tech Stack

- **Rails**: 8.1.2
- **Ruby**: 3.3.10
- **Database**: SQLite (development), PostgreSQL-ready for production
- **CSS**: TailwindCSS
- **Authentication**: Devise
- **Authorization**: Pundit
- **Background Jobs**: Solid Queue (no Redis required)
- **Testing**: RSpec
- **File Storage**: ActiveStorage (S3-compatible)

## Features

### Public Website (Spanish-first)
- Home page with featured and seasonal products
- Products catalog with filtering
- Product detail pages with WhatsApp ordering CTA
- SEO-optimized (meta tags, sitemaps, friendly URLs)
- Mobile-first, responsive design

### Admin Panel
- Dashboard with key metrics
- Full CRUD for Products and Collections
- Image management via ActiveStorage
- CRM for contacts with CSV import/export
- Campaign builder with message templating
- Quiet hours enforcement (7 AM - 4 PM Guatemala time)
- Compliance checks (opt-in, do-not-contact)

### Messaging (Twilio-ready, scaffolded)
- WhatsApp and SMS support structure
- Message templating with variables
- Contact segmentation by tags
- Scheduled sending with quiet hours
- Full message logging and tracking
- Rate limiting support

## Local Setup

### Prerequisites

- Ruby 3.3.10 (via rbenv or similar)
- SQLite3
- Node.js (for asset compilation)
- Foreman (installed automatically)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/camposja/Empanadas.git
   cd Empanadas
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   ```
   Edit `.env` and add your Twilio credentials (when ready)

4. **Set up the database**
   ```bash
   rails db:create db:migrate db:seed
   ```

5. **Start the development server**
   ```bash
   bin/dev
   ```
   This starts both Rails server and Tailwind CSS compilation.

6. **Visit the application**
   - Public site: http://localhost:3000
   - Admin panel: http://localhost:3000/admin

## Admin Access

After running `db:seed`, use these credentials:

- **Email**: `admin@tiendaempanadas.com`
- **Password**: `password123`

⚠️ **Change these in production!**

## Environment Variables

Required environment variables (see `.env.example`):

```env
# Twilio (for messaging - not yet implemented)
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_WHATSAPP_NUMBER=whatsapp:+14155238886
TWILIO_SMS_NUMBER=+1234567890

# WhatsApp number for product orders
WHATSAPP_NUMBER=+50212345678

# Rails master key (auto-generated)
RAILS_MASTER_KEY=<your_key_from_config/master.key>
```

## Background Jobs

This app uses **Solid Queue** (no Redis required).

### Development
Jobs run inline by default in development. To test background processing:

```bash
rails solid_queue:start
```

### Production
Solid Queue is configured in `config/queue.yml` and will run automatically via Procfile.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

Run system tests (requires Chrome/Chromium):

```bash
bundle exec rspec spec/system
```

## Database

### Development
Uses SQLite by default for easy setup.

### Production
Ready for PostgreSQL. Update `config/database.yml` and set `DATABASE_URL`:

```env
DATABASE_URL=postgresql://user:password@localhost/empanadas_production
```

## Deployment

### Heroku (example)

1. **Create app**
   ```bash
   heroku create your-app-name
   ```

2. **Add PostgreSQL**
   ```bash
   heroku addons:create heroku-postgresql:mini
   ```

3. **Set environment variables**
   ```bash
   heroku config:set TWILIO_ACCOUNT_SID=...
   heroku config:set TWILIO_AUTH_TOKEN=...
   heroku config:set WHATSAPP_NUMBER=+50212345678
   ```

4. **Deploy**
   ```bash
   git push heroku main
   heroku run rails db:migrate db:seed
   ```

### Hostinger / Generic VPS

1. Install Ruby 3.3+, PostgreSQL, Node.js
2. Clone repository
3. Set up environment variables
4. Run `bundle install`
5. Set up database: `RAILS_ENV=production rails db:create db:migrate`
6. Precompile assets: `RAILS_ENV=production rails assets:precompile`
7. Start with `bin/thrust bin/rails server -e production`

## Messaging Implementation

The messaging system is **scaffolded but not fully implemented** (Twilio account required).

### What's ready:
- ✅ Message model and database structure
- ✅ Campaign builder with templating
- ✅ Contact segmentation
- ✅ Quiet hours enforcement (Guatemala timezone)
- ✅ Compliance checks (opt-in, do-not-contact)
- ✅ Background jobs for async sending
- ✅ Full message logging

### What needs implementation:
- ❌ Actual Twilio API integration (see `app/services/messaging_service.rb`)
- ❌ Incoming webhook handler for delivery receipts
- ❌ SMS STOP keyword handling

### To complete Twilio integration:

1. Sign up for Twilio account
2. Get credentials and phone numbers
3. Update `.env` with credentials
4. Uncomment Twilio API calls in `MessagingService`
5. Set up webhook URLs in Twilio console

## Project Structure

```
app/
├── controllers/
│   ├── admin/              # Admin panel controllers
│   ├── home_controller.rb  # Public homepage
│   ├── products_controller.rb
│   └── collections_controller.rb
├── models/
│   ├── user.rb             # Devise authentication
│   ├── product.rb          # Products with ActiveStorage
│   ├── collection.rb       # Categories/seasonal collections
│   ├── contact.rb          # CRM contacts
│   ├── campaign.rb         # Messaging campaigns
│   └── message.rb          # Individual messages
├── policies/               # Pundit authorization
├── services/
│   └── messaging_service.rb  # Messaging logic
├── jobs/
│   ├── send_campaign_job.rb
│   └── send_message_job.rb
└── views/
    ├── admin/              # Admin panel views
    ├── home/
    ├── products/
    └── collections/

db/
├── migrate/                # Database migrations
└── seeds.rb                # Sample data

spec/                       # RSpec tests
```

## Key Models

### Product
- Name, description, optional price
- Belongs to Collection
- ActiveStorage for photos
- Friendly URLs (slugs)
- Scopes: active, featured, seasonal

### Collection
- Categories (Tradicionales, Navidad, etc.)
- Ordered by position
- Friendly URLs

### Contact
- E.164 phone format required
- Opt-in tracking
- Do-not-contact compliance
- Tags for segmentation
- CSV import/export

### Campaign
- Message templates with variables (`{{first_name}}`, etc.)
- Segment by tags
- Scheduled sending
- Status tracking

### Message
- Logs every sent message
- Delivery tracking
- Error logging

## Security

- ✅ Devise authentication with strong passwords
- ✅ Pundit authorization (admin-only routes)
- ✅ Environment-based secrets
- ✅ Secure session cookies
- ✅ CSRF protection (Rails default)
- ⚠️ Remember to change default admin password!

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and proprietary.

## Support

For questions or issues:
- Open an issue on GitHub
- Email: support@tiendaempanadas.com

---

Built with ❤️ in Guatemala 🇬🇹
