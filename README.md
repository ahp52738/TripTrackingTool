# Trip Management Tool

Welcome to the documentation for the Trip Management Tool, a backend application built with Ruby on Rails for managing trips and their associated information.


Introduction

The Trip Management Tool is a Ruby on Rails application designed to manage trips and their related information. Trips represent work requests that can be assigned to users. This documentation provides instructions on how to set up and use the application.

## Features
- Manage trips, including owners, assignees, statuses, and estimated times.
- Check in and check out trips.
- Reassign trips to different assignees.
- ...

## Getting Started

### Prerequisites

- Ruby: 3.0.0
- Rails: 7.0.4

Make sure you have Ruby and Rails installed on your system.

### Installation

Clone the repository: git clone <repository_url>
Navigate to the project directory: cd trip_management_tool
Install dependencies: bundle install
Set up the database: rails db:setup
Seed initial data: rails db:seed




  .....................APIS....................................................

  1) Fetch User List For Create a new Trip.
...........................................................................................
GET   /api/v1/users_list/:user_id
url: http://localhost:3000/api/v1/users_list/1
QueryString paramaeter:user_id
Response:

{
    "assigne_users": [
        {
            "id": 2,
            "name": "User2",
            "created_at": "2023-08-27T04:16:01.856Z",
            "updated_at": "2023-08-27T04:16:01.856Z",
            "email": "user2@example.com"
        },
        {
            "id": 3,
            "name": "User3",
            "created_at": "2023-08-27T04:16:02.292Z",
            "updated_at": "2023-08-27T04:16:02.292Z",
            "email": "user3@example.com"
        },
        {
            "id": 4,
            "name": "User4",
            "created_at": "2023-08-27T04:16:02.728Z",
            "updated_at": "2023-08-27T04:16:02.728Z",
            "email": "user4@example.com"
        },
        {
            "id": 5,
            "name": "User5",
            "created_at": "2023-08-27T04:16:03.162Z",
            "updated_at": "2023-08-27T04:16:03.162Z",
            "email": "user5@example.com"
        }
    ]
}
.......................................................................................................


2.Create the Trip
POST  /api/v1/create_trip
url: http://localhost:3000/api/v1/create_trip
Request_Type: POST

Request Parameters:

{
   "trip": {
       "owner_id": "1",
       "assignee_id": "2",
       "status": "Unstarted",
       "estimated_arrival_time": "2024-09-01T18:42",
       "estimated_completion_time": "2024-10-30T18:42"
   }
}

Response: {"message": "Trip was successfully Created.}



Request Parameters:

{
   "trip": {
       
   }
}

Response: {"error": "param is missing or the value is empty: trip"}


Request Parameters:
{
   "trip": {
      
       "assignee_id": "2",
       "status": "Unstarted",
       "estimated_arrival_time": "2024-09-01T18:42",
       "estimated_completion_time": "2024-10-30T18:42"
   }
}

Response
{
    "errors": [
        "Owner must exist"
    ]
}


Request Request Parameters:{ "trip": {"owner_id": "1"}}
Response: 
{
    "errors": [
        "Assignee must exist",
        "Estimated arrival time can't be blank",
        "Estimated completion time can't be blank"
    ]
}




................................................................................................




3. Update The Trip


1) Only the CURRENT OWNER is permitted to update the trip.
2) The owner_id and status cannot be updated using this method. 
3) The assignee_id and estimated_arrival_time can only be updated when the trip is in the "unstarted" stage.
4) The estimated_completion_time can be updated when the trip is in either the "unstarted" or "inprogress" stages.

Appropriate warning messages should be displayed if these parameters are provided.

PATCH /api/v1/update_trip/:trip_id/:user_id
url:http://localhost:3000/api/v1/update_trip/11/1
QueryString paramaeter:user_id,trip_id

Request Parameter:
    {
      "trip": {
          "owner_id": "3",
          "assignee_id": "2",
          "status": "Unstarted",
          "estimated_arrival_time": "2024-09-01T18:42",
          "estimated_completion_time": "2024-10-30T18:42"
      }
   }

Response: {
    "message": "Only the current owner can update the trip."
}


  {
      "trip": {
          "owner_id": "1",
          "assignee_id": "2",
          "status": "Unstarted",
          "estimated_arrival_time": "2024-09-01T18:42",
          "estimated_completion_time": "2024-10-30T18:42"
      }
   }

Response: {
    "message": "Only the current owner can update the trip."
}



  {
      "trip": {
          "assignee_id": "3",
          "estimated_arrival_time": "2024-09-01T18:42",
          "estimated_completion_time": "2024-10-30T18:42"
      }
   }

Response:{
    "message": "Trip was successfully updated."
}


  {
      "trip": {
          "assignee_id": "3",
          "estimated_arrival_time": "2024-09-01T18:42",
          "estimated_completion_time": "2024-10-30T18:42"
      }
   }

  Response: {
    "message": "assignee_id & estimated_arrival_time cannot be changed inprogress."
}



  {
      "trip": {

          "estimated_completion_time": "2024-10-30T18:42"
      }
   }

  Response: {
    "message": "Trip was successfully updated."
}




...................................................................................





4. Fetch the user list to reassign the trip to another user.

GET   /api/v1/users_list_for_reassign/:trip_id
      /api/v1/users_list_for_reassign/:trip_id

url: http://localhost:3000/api/v1/users_list_for_reassign/15
QueryString paramaeter:trip_id
Response: 
{
    "assigne_users": [
        {
            "id": 3,
            "name": "User3",
            "created_at": "2023-08-27T04:16:02.292Z",
            "updated_at": "2023-08-27T04:16:02.292Z",
            "email": "user3@example.com"
        },
        {
            "id": 4,
            "name": "User4",
            "created_at": "2023-08-27T04:16:02.728Z",
            "updated_at": "2023-08-27T04:16:02.728Z",
            "email": "user4@example.com"
        },
        {
            "id": 5,
            "name": "User5",
            "created_at": "2023-08-27T04:16:03.162Z",
            "updated_at": "2023-08-27T04:16:03.162Z",
            "email": "user5@example.com"
        }
    ]
}



................................................................................
5. Assign Trip to another User

PATCH /api/v1/reassign_trip/:trip_id/:user_id
Url: http://localhost:3000/api/v1/reassign_trip/11/1
QueryString paramaeter: trip_id,user_id
Request Parameter:

{
   "trip": {
       "owner_id":3 ,
       "assignee_id": 2
   }
}
Response: {
    "message": "Current Assignee can Reassign the Trip Only."
}


{
   "trip": {
       "owner_id":3 ,
       "assignee_id": 2
   }
}
Response: {
    "message": "Trip Reassign only in Ustarted stage."
}

...................................................................................
6) Check In Trip Api
PATCH /api/v1/check_in_trip/:trip_id/:user_id
url: http://localhost:3000/api/v1/check_in_trip/11/3
QueryString paramaeter: trip_id,user_id


response: {"message": "Trip checked in successfully."}
................................................................

7. Check Out Trip api

PATCH /api/v1/check_out_trip/:trip_id/:user_id
url: url: http://localhost:3000/api/v1/check_out_trip/11/3
QueryString paramaeter: trip_id,user_id
response: {"message": "Trip checked in successfully."}

..................................