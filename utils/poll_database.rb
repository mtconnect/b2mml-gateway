
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'

output_dir = File.join(File.dirname(__FILE__), '..', 'output')

date = Date.today - 1.day

orders = QUPID::Order.where { end_date >= date }
orders.to_a.each do |order|
  puts "Writing order: #{order.inspect}"
  B2MML::write_definition(order, File.join(output_dir, "#{order.mo_id}_definition.xml"))
  B2MML::write_schedule(order, File.join(output_dir, "#{order.mo_id}_schedule.xml"))
end

