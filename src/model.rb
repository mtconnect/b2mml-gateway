
require 'sequel'

module QUPID
  class Order < Sequel::Model(:VwGPManufacturingOrders)
    set_primary_key :mo_id
    
    one_to_many :processes, key: :mo_id, primary_key: :mo_id
    one_to_many :transactions, key: :mo_id, primary_key: :mo_id
    one_to_many :tools_bots, key: :mo_id , primary_key: :mo_id
    one_to_many :schedules, key: :mo_id , primary_key: :mo_id
  end
  
  class Process < Sequel::Model(:VwGPManufacturingOrderProcesses)
    set_primary_key [:mo_id, :sequence_id]
    
    one_to_one :order, :key => :mo_id, :primary_key => :mo_id
    one_to_many :transactions, key: [:mo_id, :sequence_id], primary_key: [:mo_id, :sequence_id]
  end
  
  class Transaction < Sequel::Model(:VwGPManufacturingOrderTransactions)
    set_primary_key :DEX_ROW_ID
    
    one_to_one :order, :key => :mo_id, :primary_key => :mo_id
    one_to_one :process, key: [:mo_id, :sequence_id], primary_key: [:mo_id, :sequence_id]  
  end

  class ToolsBot < Sequel::Model(:manufacturing_tools_bot)
    set_primary_key :sid

    one_to_one :order, :key => :mo_id, :primary_key => :mo_id
    one_to_many :tool_details, :key => :manufacturing_tools_bot_sid, :primary_key => :sid
    one_to_one :process, key: [:mo_id, :sequence_id], primary_key: [:mo_id, :mo_op_id]
  end

  class ToolDetail < Sequel::Model(:manufacturing_tool_details)
    set_primary_key :sid

    one_to_one :tools_bot, :key => :manufacturing_tools_bot_sid, :primary_key => :sid
  end

  class Schedule < Sequel::Model(::manufacturing_schedule)
    set_primary_key :sid
    one_to_one :order, :key => :mo_id, :primary_key => :mo_id
  end
end
