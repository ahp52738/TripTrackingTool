class Api::V1::TripController < ApplicationController
  # Callbacks to set the @trip instance variable before certain actions
    before_action :set_trip, only: [:update_trip,:reassign_trip, :check_in_trip, :check_out_trip,:users_list_for_reassign]
    before_action :set_current_user, only: [:users_list,:update_trip,:users_trips,:check_in_trip,:check_out_trip,:reassign_trip]
    skip_before_action :verify_authenticity_token

  def users_list
    begin
      @assigne_users = User.where.not(id:@current_user.id)
      if @assigne_users.any?
        render json: { assigne_users: set_user_format_data(@assigne_users) }, status: :ok
      else
        render json: { message: 'No users available for assign trip.' }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end


  def create_trip
    begin
      @trip = Trip.new(trip_params)
      if @trip.save
        create_new_trip_version 
        render json: { message: 'Trip was successfully Created.' }, status: :ok
      else
        render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end 
  end




 def update_trip
  begin
    if @current_user.id == @trip.owner_id
      if (@trip.status_Unstarted? || @trip.status_Inprogress?)
        # Check if owner_id or status are included in params and show a warning message
        if trip_params[:owner_id].present? || trip_params[:status].present? 
          render json: { message: 'Owner ID and Status cannot be changed.' }, status: :unprocessable_entity
        else
          if (@trip.status_Inprogress? && (trip_params[:assignee_id].present? || trip_params[:estimated_arrival_time].present?))
              render json: { message: 'assignee_id & estimated_arrival_time cannot be changed inprogress.' }, status: :unprocessable_entity
          else
            if (@trip.status_Unstarted? && (trip_params[:assignee_id].present? || trip_params[:estimated_arrival_time].present? || trip_params[:estimated_completion_time].present?)) || (@trip.status_Inprogress? && trip_params[:estimated_completion_time].present?) 
              if @trip.update(trip_params)
                 create_new_trip_version  if (@trip.status_Unstarted? && (trip_params[:assignee_id].present?))
                render json: { message: 'Trip was successfully updated.' }, status: :ok
              else
                render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
              end
            else
              render json: { message: 'You can only update assignee_id, estimated_arrival_time, and estimated_completion_time when the trip is in Unstarted stage.' }, status: :unprocessable_entity
            end 
          end
        end
      
      else
        render json: { message: 'Trip can only be updated when it is in Unstarted or Inprogress stage.' }, status: :unprocessable_entity
      end
    else
      render json: { message: 'Only the current owner can update the trip.' }, status: :unprocessable_entity
    end
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
end





  def users_list_for_reassign
    begin
      trip_owner_assignee_ids = @trip.trip_versions.pluck(:owner_id, :assignee_id).flatten.uniq
      @assigne_users = User.where.not(id:trip_owner_assignee_ids)

      
      if @assigne_users.any?
        render json: { assigne_users: set_user_format_data(@assigne_users) }, status: :ok
      else
        render json: { message: 'No users available for reassignment.' }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end  




  def reassign_trip
    begin
       trip_owner_assignee_ids = @trip.trip_versions.pluck(:owner_id, :assignee_id).flatten.uniq
      if @current_user.id == @trip.assignee_id
        if @trip.status_Unstarted?
          unless trip_owner_assignee_ids.include?(params[:trip][:assignee_id])
            if @trip.update(owner_id: params[:trip][:owner_id], assignee_id: params[:trip][:assignee_id])
              create_new_trip_version
              render json: { message: 'Trip Reassigned successfully.' }, status: :ok
            else
              render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { message: 'Trip can not be Reassign for selected user.' }, status: :ok
          end  
        else
          render json: { message: 'Trip Reassign only in Ustarted stage.' }, status: :ok
        end  
      else
       render json: { message: 'Current Assignee can Reassign the Trip Only.' }, status: :ok
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end  
  end



  def check_in_trip 
      begin
        if @current_user.id == @trip.assignee_id
          if @trip.status_Unstarted?
            if @trip.update(check_in_time: Time.now, status: 'Inprogress')
              render json: { message: 'Trip checked in successfully.' }, status: :ok
            else
              render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
            end
          else
            render json: { message: 'Trip check in only when it Status is Unstarted.' }, status: :ok
          end  
        else
         render json: { message: 'Current Assignee can Check in the  Trip Only.' }, status: :ok
        end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end  
   end









  def check_out_trip
    begin
      if @current_user.id == @trip.assignee_id
        if @trip.status_Inprogress?
          if @trip.update(check_out_time: Time.now, status: 'Completed')
            render json: { message: 'Trip checked out successfully.' }, status: :ok
          else
            render json: { errors: @trip.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { message: 'Trip check out only when it Status is InProgress.' }, status: :ok
        end  
      else
       render json: { message: 'Current Assignee can Check out the Trip Only.' }, status: :ok
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end  
  end











  def users_trips
    begin
      # Fetching all trips owned by the current user, including old ones through trip_versions
      old_owned_trips = Trip.joins(:trip_versions).where(trip_versions: { owner_id: @current_user.id }).distinct
      owned_trips = @current_user.owned_trips

      # Combine old_owned_trips and _present_owned_trips while removing duplicates
      @all_owned_trips = (old_owned_trips + owned_trips).uniq

      # Fetching all trips assigned to the current user, including old ones through trip_versions
      old_assigned_trips = Trip.joins(:trip_versions).where(trip_versions: { assignee_id: @current_user.id }).distinct
      assigned_trips = @current_user.assigned_trips

      # Combine old_assigned_trips and presnet_assigned_trips while removing duplicates
      @all_assigned_trips = (old_assigned_trips + assigned_trips).uniq

      if (@all_owned_trips.any? || @all_assigned_trips.any?)
        render json: { owned_trips: @all_owned_trips, assigned_trips: @all_assigned_trips }, status: :ok
      else
        render json: { message: 'No Trip available.' }, status: :not_found
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :unprocessable_entity
    end  
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


    def set_user_format_data(assigne_users)
      assigne_users.map do |user|
        {id: user.id,name: user.name,email: user.email}
      end
    end

  # Set the @trip instance variable for certain actions
    def set_trip
      begin
        @trip = Trip.find(params[:trip_id])
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    def set_current_user
      begin
        @current_user = User.find(params[:user_id])
      rescue StandardError => e
        render json: { error: e.message }, status: :unprocessable_entity
      end
    end

    # Strong parameters for trip attributes
  def trip_params
      params.require(:trip).permit(:owner_id, :assignee_id, :status, :estimated_arrival_time, :estimated_completion_time)
  end

end
