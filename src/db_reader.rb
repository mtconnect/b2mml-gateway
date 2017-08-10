
require 'time'
require 'as-duration'
require 'configuration.rb'
require 'b2mml'
require 'cutting_tool'

class DBReader
  include Logging

  def initialize
    @output_dir = File.join(File.dirname(__FILE__), '..', 'output')
    @running = false
    @cache = Hash.new
  end

  @@instance = DBReader.new

  def self.instance
    @@instance
  end

  def new_or_changed(key)
    return !@cache.has_key?(key)
  end

  def start
    logger.info "Starting Polling Database"
    
    @running = true
    while @running
      logger.info "Requesting orders for PARC"

      begin
        orders = QUPID::Order.where { item_id.like  'PARC%' }
        orders.to_a.each do |order|
          logger.debug "Checking order: #{order.mo_id}"
          if new_or_changed("Order:#{order.mo_id}")
            logger.info "Adding order #{order.mo_id} for job #{order.job_id}"
            
            definition = ""
            uuid = B2MML::write_definition(order, definition)
            logger.info "Posting Definition #{uuid}"
            Collector.post_asset(uuid, "b:B2mmlProductDefinition", definition)
            
            schedule = ""
            uuid = B2MML::write_schedule(order, schedule)
            logger.info "Posting Schedule #{uuid}"
            Collector.post_asset(uuid, "b:B2mmlProductionSchedule", schedule)
            
            @cache[order.mo_id] = order
          end
        end
      rescue
        logger.error "Cannot get orders from database: #{$!}"
        logger.error $!.backtrace.join("\n")

        break if not @running
      end

      # Getting tooling data
      begin
        tools = QUPID::ToolDetail.all
        tools.to_a.each do |tool|
          logger.debug "Checking order: #{tool.tool_item_id} sid: #{tool.sid}"
          if new_or_changed("CuttingTool:#{tool.sid}")
            logger.info "Adding tool #{tool.tool_item_id} sid: #{tool.sid}"
            
            tool_details = ""
            uuid = CuttingTool::write_cutting_tool(tool, tool_details)
            Collector.post_asset(uuid, "CuttingToolArchetype", tool_details)
            
            @cache[tool.sid] = tool
          end
        end
      rescue
        logger.error "Cannot get tools from database: #{$!}"
        logger.error $!.backtrace.join("\n")

        break if not @running
      end

      
      logger.info "Reader sleeping 60 seconds"
      sleep 60
    end

    logger.info "Exiting DB Reader thread"
    
  rescue
    logger.error "DB Reader thread died.: #{$!}"
    logger.error $!.backtrace.join("\n")
  end

  def stop
    @running = false
  end
end
