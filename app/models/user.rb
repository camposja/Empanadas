class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :campaigns, dependent: :destroy

  # Validations
  validates :admin, inclusion: { in: [true, false] }

  # Scopes
  scope :admins, -> { where(admin: true) }

  def admin?
    admin
  end
end
