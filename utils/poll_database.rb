
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'configuration.rb'
require 'b2mml'

output_dir = File.join(File.dirname(__FILE__), '..', 'output')

start = Time.parse('2016-05-09')

orders = QUPID::Order.where { start_date >= start } 
orders.to_a.each do |order|
  B2MML::write_definition(order, File.join(output_dir, "#{order.mo_id}_definition.xml"))
  B2MML::write_schedule(order, File.join(output_dir, "#{order.mo_id}_schedule.xml"))
end

