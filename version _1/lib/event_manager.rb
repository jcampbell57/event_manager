# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcodes(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def clean_phone_numbers(phone_number)
  phone_number = phone_number.delete('^0-9')

  if phone_number.length < 10 ||
     phone_number.length > 11 ||
     phone_number.length == 11 && phone_number[0] != '1'
    'bad number'
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number.delete_prefix('1')
  else
    phone_number
  end
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue StandardError
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

def count_most_occuring(array)
  array.max_by { |item| array.count(item) }
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

reg_hour = []
reg_day = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcodes(row[:zipcode])
  phone_number = clean_phone_numbers(row[:homephone])
  # puts phone_number

  # record registration hour
  reg_time = Time.strptime(row[:regdate], '%m/%d/%Y %k:%M')
  reg_hour << reg_time.hour

  # record registration day
  reg_date = Date.strptime(row[:regdate], '%m/%d/%y %k:%M')
  reg_day << reg_date.strftime('%A')

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letter(id, form_letter)
end

p "The hour with the most registrations is #{count_most_occuring(reg_hour)}:00."
p "The day with the most registrations is #{count_most_occuring(reg_day)}."
