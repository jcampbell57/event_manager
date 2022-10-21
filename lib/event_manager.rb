# frozen_string_literal: true

require 'csv'

def clean_zipcodes(zipcode)
  # if zipcode.nil?
  #   '00000'
  # elsif zipcode.length < 5
  #   zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode[0..4]
  # else
  #   zipcode
  # end

  zipcode.to_s.rjust(5, '0')[0..4]
end

puts 'Event Manager Initialized!'

# contents = File.read('event_attendees.csv') if File.exist? "event_attendees.csv"
# puts contents

# lines = File.readlines('event_attendees.csv') if File.exist? "event_attendees.csv"
# lines.each do |line|
#   puts line
# end

# lines = File.readlines('event_attendees.csv') if File.exist? 'event_attendees.csv'
# lines.each_with_index do |line,index|
#   # skip header row
#   # next if line == " ,RegDate,first_Name,last_Name,Email_Address,HomePhone,Street,City,State,Zipcode\n"
#   next if index == 0

#   columns = line.split(',')
#   # p columns
#   name = columns[2]
#   puts name
# end

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  # name = row[2]
  name = row[:first_name]

  # zipcode = row[:zipcode]
  # if zipcode.nil?
  #   zipcode = '00000'
  # elsif zipcode.length < 5
  #   zipcode = zipcode.rjust(5, '0')
  # elsif zipcode.length > 5
  #   zipcode = zipcode[0..4]
  # end

  zipcode = clean_zipcodes(row[:zipcode])

  # puts name
  puts "#{name} #{zipcode}"
end
