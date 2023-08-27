
class TripsController < ApplicationController
  before_action :authenticate_user!

  # Callbacks to set the @trip instance variable before certain actions
  before_action :set_trip, only: [:update, :check_in, :check_out, :reassign]
  # Callback to set the @assigne_user instance variable before certain actions
  before_action :set_assigne_user, only: [:new, :create, :edit, :update]

  # Fetch all trips for the index page
  def index
    @trips = Trip.all
  end

  # Initialize a new trip and assigne_user for the new trip form
  def new
    @trip = Trip.new
    @assigne_user = User.where.not(id: current_user.id)
  end

  # Create a new trip with associated logic
  def create
    @trip = Trip.new(trip_params)
    @assigne_user = User.where.not(id: current_user.id)
    
    if @trip.save
      create_new_trip_version 
      redirect_to root_path, notice: 'Trip was successfully created.'
    else
      render :new
    end
  end

  # Load the trip data for editing
  def edit
    @trip = Trip.find(params[:id])
  end

  # Update a trip's attributes and create a new trip version
  def update
    if @trip.update(trip_params)
      create_new_trip_version 
      redirect_to root_path, notice: 'Trip was successfully Reassigned.'
    else
      render :edit
    end
  end

  # Check in a trip with appropriate status change
  def check_in
    if @trip.update(check_in_time: Time.now, status: 'Inprogress')
      redirect_to users_path, notice: 'Trip checked in successfully.'
    else
      render :edit # Or render any other template you want
    end
  end

  # Check out a trip with appropriate status change
  def check_out
    if @trip.update(check_out_time: Time.now, status: 'Completed')
      redirect_to users_path, notice: 'Trip checked out successfully.'
    else
      render :edit # Or render any other template you want
    end
  end

  # Prepare assigne_users for reassigning a trip
  def reassign
      trip_owner_assignee_ids = @trip.trip_versions.pluck(:owner_id, :assignee_id).flatten.uniq
      @assigne_users = User.where.not(id:trip_owner_assignee_ids)
  end

  private

  # Create a new trip version based on current attributes
  def create_new_trip_version
    latest_version = @trip.trip_versions.maximum(:version).to_i + 1
    @trip.trip_versions.create(
      version: latest_version,
      assignee_id: @trip.assignee_id,
      owner_id: @trip.owner_id,
      status: @trip.status
    )
  end  

  # Set the assigne_user instance variable
  def set_assigne_user
    @assigne_user = User.where.not(id: current_user.id)
  end

  # Set the @trip instance variable for certain actions
  def set_trip
    @trip = Trip.find(params[:id])
  end

  # Strong parameters for trip attributes
  def trip_params
    params.require(:trip).permit(:owner_id, :assignee_id, :status, :estimated_arrival_time, :estimated_completion_time)
  end
end
