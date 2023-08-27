# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)


User.create([
  { name: 'User1', email: 'user1@example.com', password: 'testing', password_confirmation: 'testing' },
  { name: 'User2', email: 'user2@example.com', password: 'testing', password_confirmation: 'testing' },
  { name: 'User3', email: 'user3@example.com', password: 'testing', password_confirmation: 'testing' },
  { name: 'User4', email: 'user4@example.com', password: 'testing', password_confirmation: 'testing' },
  { name: 'User5', email: 'user5@example.com', password: 'testing', password_confirmation: 'testing' }
])


