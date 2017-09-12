
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'cutting_tool'
require 'collector'
require 'tools'
require 'db_reader'

collector = Collector.new('test', 'http://10.0.4.227:5000/', nil, 'itamco_Haas')
output_dir = File.join(File.dirname(__FILE__), '..', 'output')
reader = DBReader.new

# orders = QUPID::Order.where { item_id.like  'PARC%' }
orders = QUPID::Order.where { mo_id.like 'M17-10405' }
p orders.to_a
orders.to_a.each do |order|
  punches = order.punches_dataset.where { create_date > Time.utc(2017,9,12) }
  p punches.to_a
  #reader.check_transactions(order)
  
end

#QUPID::ToolDetail.each do |t|
#	File.open("Tool_#{t.sid}.xml", "w") do |f|
#		CuttingTool::write_cutting_tool(t, f)
#	end
#end


