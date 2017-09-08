
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'cutting_tool'
require 'collector'
require 'tools'
require 'parts'

collector = Collector.new('test', 'http://104.239.140.232:5000/', nil, '000')
output_dir = File.join(File.dirname(__FILE__), '..', 'output')

xml = collector.get_assets('Part')
Parts.store_manufacturing_schedule(xml)


