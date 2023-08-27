module TripsHelper

  # Determine the color based on the trip's status.
  # Returns 'blue' for Unstarted, 'green' for Inprogress, and 'red' for other statuses.
  def trip_status_color(trip)
    if trip.status_Unstarted?
      'blue'
    elsif trip.status_Inprogress?
      'green'
    else
      'red'
    end
  end

end