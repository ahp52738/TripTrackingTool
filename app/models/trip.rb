# app/models/trip.rb
class Trip < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  belongs_to :assignee, class_name: 'User'
  has_many :trip_versions, dependent: :destroy
  enum :status, [ :Unstarted, :Inprogress, :Completed ],prefix: :status

  validate :estimated_arrival_time_in_future
  validate :estimated_completion_time_in_future
  validate :estimated_completion_time_must_be_future_to_estimated_arrival_time

  validates :estimated_arrival_time, presence: true
  validates :estimated_completion_time, presence: true

  # Custom validation method to check if estimated arrival time is in the future
  def estimated_arrival_time_in_future
    if estimated_arrival_time.present? && estimated_arrival_time <= Time.now
      errors.add(:estimated_arrival_time, "must be in the future")
    end
  end

  # Custom validation method to check if estimated completion time is in the future
  def estimated_completion_time_in_future
    if estimated_completion_time.present? && estimated_completion_time <= Time.now
      errors.add(:estimated_completion_time, "must be in the future")
    end
  end

  # Custom validation method to check if estimated completion time is in the future and later than estimated arrival time
  def estimated_completion_time_must_be_future_to_estimated_arrival_time
    return if estimated_completion_time.blank? || estimated_arrival_time.blank?

    if estimated_completion_time <= estimated_arrival_time
      errors.add(:estimated_completion_time, "must be in the future and later than estimated arrival time")
    end
  end

  # Check if the assignee of the trip is the current user
  def trip_assignee_is_current_user?(current_user)
    assignee == current_user
  end

  # Check if the owner of the trip is the current user
  def trip_owner_is_current_user?(current_user)
    owner == current_user
  end


end