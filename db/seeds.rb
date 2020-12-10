# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

10.times do
  e = Event.create!(name: Faker::FunnyName.four_word_name, time: Faker::Time.forward)
  Ticket.create!(event: e, available: 5, price: Faker::Number.decimal(l_digits: 2, r_digits: 2))
end
