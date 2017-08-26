
$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'time'
require 'as-duration'
require 'configuration'
require 'step'
require 'collector'

puts "Starting step"

step = STEP.new
step.start

sleep 60
