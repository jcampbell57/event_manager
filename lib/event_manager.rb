# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_numbers(phone_number)
  phone_number = phone_number.delete("^0-9")

  if phone_number.length < 10 ||
     phone_number.length > 11 ||
     phone_number.length == 11 && phone_number[0] != '1'
    puts 'bad number'
  elsif phone_number.length == 11 && phone_number[0] == '1'
    puts phone_number.delete_prefix('1')
  else
    puts phone_number
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcodes(row[:zipcode])
  phone_number = clean_phone_numbers(row[:homephone])
  # puts phone_number

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end
