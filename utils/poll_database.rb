
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'collector'

# collector = Collector.new('test', 'http://10.211.55.2:5000/', nil, '000')
output_dir = File.join(File.dirname(__FILE__), '..', 'output')

today = Date.today

# orders = QUPID::Order.where { start_date <= today and end_date >= today and item_id.like  'PARC%' }
orders = QUPID::Order.where { item_id.like  'PARC%' }
orders.to_a.each do |order|
  puts "**************"
  
  puts "Writing order: #{order.mo_id}"
  p order

  definition = ""
  definition = File.new("Definition.xml", 'w')
  uuid = B2MML::write_definition(order, definition)
  puts "Posting Definition #{uuid}"
  # collector.post_asset(uuid, "b:B2mmlProductDefinition", definition)

  schedule = ""
  schedule = File.new("Schedule.xml", 'w')
  uuid = B2MML::write_schedule(order, schedule)
  puts "Posting Schedule #{uuid}"
  # collector.post_asset(uuid, "b:B2mmlProductionSchedule", schedule)


  order.tools_bots.each do |t|
    p t

    p t.tool_details
  end
end

