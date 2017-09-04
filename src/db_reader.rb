
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

  def tool_changed(tool, tid)
    old = @tool_cache[tid]
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
      load_orders
      load_tools

      break unless @running
      
      logger.info "Reader sleeping 20 seconds"
      sleep 20
    end

    logger.info "Exiting DB Reader thread"
    
  rescue
    logger.error "DB Reader thread died.: #{$!}"
    logger.error $!.backtrace.join("\n")
  end


  def load_orders
      logger.info "Requesting orders for PARC"

      orders = QUPID::Order.where { item_id.like  'PARC%' }
      orders.to_a.each do |order|
        logger.debug "Checking order: #{order.mo_id}"
        if order_changed(order)
          logger.info "Adding order #{order.mo_id} for job #{order.job_id}"
          
          definition = ""
          uuid = B2MML::write_definition(order, definition)
          logger.info "Posting Definition #{uuid}"
          Collector.post_asset(uuid, "b:B2mmlProductDefinition", "itamco_QUPID_6ee5c9", definition)
          
          schedule = ""
          uuid = B2MML::write_schedule(order, schedule)
          logger.info "Posting Schedule #{uuid}"
          Collector.post_asset(uuid, "b:B2mmlProductionSchedule", "itamco_QUPID_6ee5c9", schedule)
          
          @order_cache[order.mo_id] = order
        end
      end
  rescue
    logger.error "Cannot get orders from database: #{$!}"
    logger.error $!.backtrace.join("\n")    
  end

  def load_tools
    machines = { 1046 => "itamco_DMG", 1166 => "itamco_Haas" } 

    
    tools = QUPID::WCTool.all
    sets = combine_tools(tools.to_a)
    sets.each do |k, list|
      puts "****** #{k} : #{list.length}"
      
      # Create archetype and then instances by wc
      arch = nil
      tool, = list
      if tool_changed(tool, tool.group)
        tool_details = ""
        puts "Posting archetype for #{tool.group}"
        arch = CuttingTool::write_cutting_tool(tool, tool_details, tool.group)
        Collector.post_asset(arch, "CuttingToolArchetype", "itamco_Presetter", tool_details)        

        @tool_cache[tool.group] = tool            
      end
      
      list.each do |tool|
        logger.debug "Checking tool: #{tool.group} sid: #{tool.key}"
        if tool_changed(tool, tool.sid)
          logger.info "Adding tool #{tool.group} sid: #{tool.key} for #{machines[tool.work_centers_sid]}"
          
          tool_details = ""
          uuid = CuttingTool::write_cutting_tool(tool, tool_details, tool.key, arch)
          Collector.post_asset(uuid, "CuttingTool", machines[tool.work_centers_sid], tool_details)
          
          @tool_cache[tool.key] = tool
        end
      end
    end
  rescue
    logger.error "Cannot get tools from database: #{$!}"
    logger.error $!.backtrace.join("\n")    
  end

  def combine_tools(tools)
    tool_set = Hash.new { |h, k| h[k] = [] }
    tools.each do |tool|      
      tool_set[tool.group] << tool
    end

    p tool_set
    tool_set
  end
  def stop
    @running = false
  end
end
