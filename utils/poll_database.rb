
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'collector'

collector = Collector.new('test', 'http://10.211.55.2:5000/', nil, '000')
output_dir = File.join(File.dirname(__FILE__), '..', 'output')

today = Date.today

orders = QUPID::Order.where { start_date <= today and end_date >= today }
orders.to_a.each do |order|
  puts "Writing order: #{order.mo_id}"

  definition = ""
  uuid = B2MML::write_definition(order, definition)
  puts "Posting Definition #{uuid}"
  collector.post_asset(uuid, "b:B2mmlProductDefinition", definition)

  schedule = ""
  uuid = B2MML::write_schedule(order, schedule)
  puts "Posting Schedule #{uuid}"
  collector.post_asset(uuid, "b:B2mmlProductionSchedule", schedule)
end

