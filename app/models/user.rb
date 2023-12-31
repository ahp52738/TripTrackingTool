class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :owned_trips, class_name: 'Trip', foreign_key: 'owner_id'
  has_many :assigned_trips, class_name: 'Trip', foreign_key: 'assignee_id'
  validates :email, presence: true, uniqueness: true
end