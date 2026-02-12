class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :collection
  has_many_attached :photos

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  # Scopes
  scope :active, -> { where(active: true) }
  scope :featured, -> { where(featured: true) }
  scope :seasonal, -> { where(seasonal: true) }

  # Callbacks
  before_validation :set_slug, if: -> { name.present? && slug.blank? }

  # Methods
  def whatsapp_message
    message = "Hola! Me interesa #{name}"
    message += " (#{collection.name})" if collection
    message
  end

  private

  def set_slug
    self.slug = name.parameterize
  end
end
