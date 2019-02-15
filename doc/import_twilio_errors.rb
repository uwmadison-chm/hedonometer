rows.each do |row|
  s = Survey.find(row['survey_id'])
  params = URI.decode_www_form(row['requestvariables']).to_h
  from_number = params['From']
  to_number = params['To']
  message = params['Body']
  itm = s.incoming_text_messages.create!(
    :to_number => to_number,
    :from_number => from_number,
    :message => message,
    :server_response => 'imported 6/14/2016'
  )
  delivered_at = Time.parse(row['utcdate'])
  itm.update_attribute(:delivered_at, delivered_at)
  itm.reload
  puts [itm.from_number, itm.to_number, itm.message, itm.server_response, itm.delivered_at]
end; nil