
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'cutting_tool'
require 'collector'

# collector = Collector.new('test', 'http://10.211.55.2:5000/', nil, '000')
output_dir = File.join(File.dirname(__FILE__), '..', 'output')

today = Date.today

# orders = QUPID::Order.where { item_id.like  'PARC%' }
orders = QUPID::Order.where { item_id.like  'PARC%' }
orders.to_a.each do |order|
  puts "**************"
  
  puts "Writing order: #{order.mo_id}"
  #p order

  definition = ""
  definition = File.new("#{order.mo_id}_Definition.xml", 'w')
  uuid = B2MML::write_definition(order, definition)
  puts "Posting Definition #{uuid}"
  # collector.post_asset(uuid, "b:B2mmlProductDefinition", definition)

  schedule = ""
  schedule = File.new("#{order.mo_id}_Schedule.xml", 'w')
  uuid = B2MML::write_schedule(order, schedule)
  puts "Posting Schedule #{uuid}"
  # collector.post_asset(uuid, "b:B2mmlProductionSchedule", schedule)

  QUPID::ToolDetail.all.each do |t|
    p t
  end
end

QUPID::ToolDetail.each do |t|
	File.open("Tool_#{t.sid}.xml", "w") do |f|
		CuttingTool::write_cutting_tool(t, "Presetter", f)
	end
end
