# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

# civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
# civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

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

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    # legislators = civic_info.representative_info_by_address(
    #   address: zip,
    #   levels: 'country',
    #   roles: ['legislatorUpperBody', 'legislatorLowerBody']
    # )
    # legislators = legislators.officials
    # legislator_names = legislators.map(&:name)
    # legislator_names.join(', ')

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

# template_letter = File.read('form_letter.html')
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

contents.each do |row|
  id = row[0]
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

  # begin
  #   legislators = civic_info.representative_info_by_address(
  #     address: zipcode,
  #     levels: 'country',
  #     roles: ['legislatorUpperBody', 'legislatorLowerBody']
  #   )
  #   legislators = legislators.officials
  #   legislator_names = legislators.map(&:name)
  #   legislators_string = legislator_names.join(', ')
  # rescue
  #   'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  # end
  legislators = legislators_by_zipcode(zipcode)

  # puts name
  # puts "#{name} #{zipcode} #{legislators}"

  # personal_letter = template_letter.gsub('FIRST_NAME', name)
  # personal_letter.gsub!('LEGISLATORS', legislators)
  # puts personal_letter

  form_letter = erb_template.result(binding)
  # puts form_letter

  # Dir.mkdir('output') unless Dir.exist?('output')

  # filename = "output/thanks_#{id}.html"

  # File.open(filename, 'w') do |file|
  #   file.puts form_letter
  # end
  save_thank_you_letter(id, form_letter)
end
