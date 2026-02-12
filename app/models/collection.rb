class Collection < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :products, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(position: :asc, name: :asc) }

  # Callbacks
  before_validation :set_slug, if: -> { name.present? && slug.blank? }

  private

  def set_slug
    self.slug = name.parameterize
  end
end
