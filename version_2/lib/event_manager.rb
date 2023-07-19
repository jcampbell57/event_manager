require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_phone_number(phone_number)
  if phone_number.length == 10
    phone_number
  elsif phone_number.length == 11 && phone_number[0] == '1'
    phone_number.slice(1..10)
  else
    'bad number'
  end
end

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
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

puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
reg_times = Hash.new(0)
reg_days = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  phone_number = clean_phone_number(row[:homephone].scan(/[0-9]/).join)
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)

  # record registration hour
  time = Time.strptime(row[:regdate], '%m/%d/%y %k:%M')
  reg_times[time.hour] += 1
  # record registratgion day
  day = Time.strptime(row[:regdate], '%m/%d/%y %k:%M').strftime('%A')
  reg_days[day] += 1

  form_letter = erb_template.result(binding)

  # save_thank_you_letter(id, form_letter)
end

puts "The most popular registration hour was: #{(reg_times.max_by { |_k, v| v })[0]}:00"
puts "The most popular registration day was: #{(reg_days.max_by { |_k, v| v })[0]}"
