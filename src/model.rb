
require 'sequel'

module QUPID
  class Order < Sequel::Model(:VwGPManufacturingOrders)
    set_primary_key :mo_id
    
    one_to_many :processes, key: :mo_id, primary_key: :mo_id
    one_to_many :transactions, key: :mo_id, primary_key: :mo_id
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
end
