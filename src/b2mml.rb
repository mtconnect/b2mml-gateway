
require 'rexml/document'
require 'ruby-duration'
require 'uuid'

module B2MML
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_B2MML = UUID.create_sha1("http://www.mesa.org/xml/B2MML-V0600", UUID::NameSpace_URL)
  NameSpace_ItamcoProductDefinition = UUID.create_sha1("urn:itamco.com:b2mml:ProductDefinition", UUID::NameSpace_OID)
  NameSpace_ItamcoProductionSchedule = UUID.create_sha1("urn:itamco.com:b2mml:ProductionSchedule", UUID::NameSpace_OID)
  
  def self.format_duration(hours)
    Duration.new(:seconds => hours.to_f * 3600).iso8601
  end

  def self.create_definition_asset_id(job_id)
    UUID.create_sha1(job_id, NameSpace_ItamcoProductDefinition)
  end

  def self.create_schedule_asset_id(mo_id)
    UUID.create_sha1(mo_id, NameSpace_ItamcoProductionSchedule)
  end

  def self.write_definition(order, io)
    def_document = REXML::Document.new

    # Create asset wrapper
    asset = def_document.add_element("b:B2mmlProductDefinition")
    uuid = create_definition_asset_id(order.job_id)
    asset.add_attribute("assetId", uuid)
    asset.add_attribute("timestamp", Time.now.utc.iso8601)
    asset.add_attribute("deviceUuid", "itamco_QUPID_6ee5c9")
    
    definition = asset.add_element('ProductDefinition')
    definition.add_namespace("http://www.mesa.org/xml/B2MML-V0600")

    definition.add_element('ID').text = order.item_id
    definition.add_element('Description').text = "#{order.item_description} #{order.drawing_description}"
    definition.add_element('ProductSegment').add_element('ID').text = order.item_id
    
    form = REXML::Formatters::Pretty.new
    form.compact = true
    form.write(def_document, io)

    return uuid
  end

  def self.write_schedule(order, io)
    processes = order.processes.to_a

    sched_document = REXML::Document.new

    # Create asset wrapper
    asset = sched_document.add_element("b:B2mmlProductionSchedule")
    uuid = create_schedule_asset_id(order.mo_id)
    asset.add_attribute("assetId", uuid)
    asset.add_attribute("timestamp", Time.now.utc.iso8601)
    asset.add_attribute("deviceUuid", "device")

    product_uuid = create_definition_asset_id(order.job_id)
    ref = asset.add_element("AssetArchetypeRef")
    ref.add_attribute("assetType", "b:B2mmlProductDefinition")
    ref.add_attribute("assetId", product_uuid)

    targets = asset.add_element("Targets")
    processes.map { |p| p.wc_id.strip }.uniq.each do |wc|
      target = targets.add_element("Target")
      target.add_attribute("targetId", wc)
      target.add_attribute("type", 'DEVICE')

      # Need to replace with device uuid
      target.add_element('TargetDevice').text = wc
    end
    
    schedule = asset.add_element('ProductionSchedule')
    schedule.add_namespace("http://www.mesa.org/xml/B2MML-V0600")

    schedule.add_element('ID').text = order.mo_id

    request = schedule.add_element('ProductionRequest')
    request.add_element('ID').text = order.mo_id
    request.add_element('Description').text = "#{order.item_description} #{order.drawing_description}"
    request.add_element('StartTime').text = order.start_date.iso8601
    request.add_element('EndTime').text = order.end_date.iso8601

    segment = request.add_element('SegmentRequirement')
    segment.add_element('ProductSegmentID').text = order.item_id
    segment.add_element('LatestEndTime').text = order.end_date.iso8601

    hours = processes.inject(0) { |t, proc| t + proc.run_hrs + proc.setup_hrs }
    
    segment.add_element('Duration').text = format_duration(hours)

    requirement = segment.add_element('MaterialProducedRequirement')
    qty = requirement.add_element('Quantity')
    qty.add_element('QuantityString').text = order.end_qty
    qty.add_element('DataType').text = 'Amount'

    consumed = segment.add_element('MaterialConsumedRequirement').
               add_element('MaterialConsumedRequirementProperty')
    consumed.add_element('ID').text = 'Availability'
    value = consumed.add_element('Value')
    value.add_element('ValueString').text = 'Available'
    value.add_element('DataType').text = 'string'

    processes.each do |process|
      seg_requirement = segment.add_element('SegmentRequirement')
      seg_requirement.add_element('ID').text = process.sequence_id
      seg_requirement.add_element('Duration').text = format_duration(process.run_hrs + process.setup_hrs)
      

      setup = seg_requirement.add_element('ProductionParameter').add_element('Parameter')
      setup.add_element('ID').text = 'SetupTime'
      value = setup.add_element('Value')
      value.add_element('ValueString').text = format_duration(process.setup_hrs)
      value.add_element('DataType').text = 'duration'

      equipment = seg_requirement.add_element('EquipmentRequirement')
      equipment.add_element('EquipmentID').text = process.wc_id
      equipment.add_element('Description').text = process.wc_description

      property = equipment.add_element('EquipmentRequirementProperty')
      property.add_element('ID').text = 'Cost'
      value = property.add_element('Value')
      value.add_element('ValueString').text = process.labor_hrs.to_f * 15 + process.run_hrs.to_f * 40
      value.add_element('DataType').text = 'Amount'
      value.add_element('UnitOfMeasure').text = 'US Dollar'

    end

    request.add_element('RequestState').text = 'Released'
    schedule.add_element('ScheduleState').text = 'Released'

    form = REXML::Formatters::Pretty.new
    form.compact = true
    form.write(sched_document, io)

    return uuid
  end  
end
