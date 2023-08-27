class UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    # Fetching all trips owned by the current user, including old ones through trip_versions
    old_owned_trips = Trip.joins(:trip_versions).where(trip_versions: { owner_id: current_user.id }).distinct
    owned_trips = current_user.owned_trips

    # Combine old_owned_trips and _present_owned_trips while removing duplicates
    @all_owned_trips = (old_owned_trips + owned_trips).uniq

    # Fetching all trips assigned to the current user, including old ones through trip_versions
    old_assigned_trips = Trip.joins(:trip_versions).where(trip_versions: { assignee_id: current_user.id }).distinct
    assigned_trips = current_user.assigned_trips

    # Combine old_assigned_trips and presnet_assigned_trips while removing duplicates
    @all_assigned_trips = (old_assigned_trips + assigned_trips).uniq
  end
end


def welcome


end

def api

end

