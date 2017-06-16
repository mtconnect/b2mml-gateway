
require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'

class DBReader
  include Logging

  def initialize
    @output_dir = File.join(File.dirname(__FILE__), '..', 'output')
    @recover_file = File.join(File.dirname(__FILE__), '..', 'config', recovery.txt)
    @running = false

    read_recovery_file
  end

  @@instance = DBReader.new

  def self.instance
    @@instance
  end

  def write_recovery_file
    File.open(@recovery_file, 'w') do |f|
      file.puts @recovery_time.iso8601
    end

  rescue
    logger.info "Cannot write recovery file #{@recovery_file}: #{$!}"
  end

  def read_recovery_file
    File.open(@recovery_file, 'r') do |f|
      @recovery_time = Time.parse(f.read)
    end

    logger.info "Recovering from #{@recovery_time.iso8601}"
  rescue
    logger.info "Cannot read recovery file #{@recovery_file}: #{$!}"
    logger.info "Reverting to one month ago"
    @recovery_time = Time.now - 1.month    
  end

  def start
    @running = true
    while @running
      logging.info "Requesting orders beginning at: #{@recovery_time.iso8601}"

      end_date = Date.now - 1.day
    
      orders = QUPID::Order.where { end_date >= end_date }
      orders.to_a.each do |order|
        B2MML::write_definition(order, File.join(output_dir, "#{order.mo_id}_definition.xml"))
        B2MML::write_schedule(order, File.join(output_dir, "#{order.mo_id}_schedule.xml"))
      end

      write_recovery_file
      
      sleep 10
    end
  end

  def stop
    @running = false
  end
end
