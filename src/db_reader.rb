
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
    @tool_cache = Hash.new
    @order_cache = Hash.new
  end

  @@instance = DBReader.new

  def self.instance
    @@instance
  end

  def tool_changed(tool)
    old = @tool_cache[tool.sid]
    changed = old.nil?
    if old
      tool.columns.each do |col|
        changed = old.send(col) != tool.send(col)
        break if changed
      end
      if changed
        logger.info "**** Tool has changed: #{tool.sid}"
      else
        logger.info "**** Tool has not changed: #{tool.sid}"
      end
    else
      logger.info "***** New tool: #{tool.sid}"
    end
    
    return changed
  end

  def order_changed(order)
    old = @order_cache[order.mo_id]
    changed = old.nil?
    if old
      # Do field-wise compare
      order.columns.each do |col|
        changed = old.send(col) != order.send(col)
        break if changed
      end

      if changed
        logger.info "******* Order has changed: #{order.mo_id}"
      else
        logger.info "******* Order has not changed: #{order.mo_id}"
      end
    else
      logger.info "**** New order: #{order.mo_id}"
    end

    return changed
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
          if order_changed(order)
            logger.info "Adding order #{order.mo_id} for job #{order.job_id}"
            
            definition = ""
            uuid = B2MML::write_definition(order, definition)
            logger.info "Posting Definition #{uuid}"
            Collector.post_asset(uuid, "b:B2mmlProductDefinition", "itamco_QUPID", definition)
            
            schedule = ""
            uuid = B2MML::write_schedule(order, schedule)
            logger.info "Posting Schedule #{uuid}"
            Collector.post_asset(uuid, "b:B2mmlProductionSchedule", "itamco_QUPID", schedule)
            
            @order_cache[order.mo_id] = order
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
          logger.debug "Checking tool: #{tool.tool_item_id} sid: #{tool.sid}"
          if tool_changed(tool)
            logger.info "Adding tool #{tool.tool_item_id} sid: #{tool.sid}"
            
            tool_details = ""
            uuid = CuttingTool::write_cutting_tool(tool, tool_details)
            Collector.post_asset(uuid, "CuttingToolArchetype", "itamco_Presetter", tool_details)
            
            @tool_cache[tool.sid] = tool
          end
        end
      rescue
        logger.error "Cannot get tools from database: #{$!}"
        logger.error $!.backtrace.join("\n")

        break if not @running
      end

      
      logger.info "Reader sleeping 20 seconds"
      sleep 20
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
