
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration'
require 'step'
require 'collector'
require 'tools'

puts "Starting tools"
collector = Collector.new('itamco_Haas', 'http://104.239.140.232:5000', nil, 'itamco_Haas')


tools = Tools.new
tools.start

sleep 60
