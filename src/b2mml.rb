
require 'rexml/document'
require 'ruby-duration'

module B2MML
  def self.format_duration(hours)
    Duration.new(:seconds => hours.to_f * 3600).iso8601
  end

  def self.write_definition(order, filename)
    def_document = REXML::Document.new
    def_document << REXML::XMLDecl.new("1.0", "UTF-8")

    definition = def_document.add_element('ProductDefinition')
    definition.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    definition.add_namespace("b2mml", "http://www.mesa.org/xml/B2MML-V0600")
    definition.add_namespace("http://www.mesa.org/xml/B2MML-V0600")
    definition.add_attribute('xsi:schemaLocation',
                             "http://www.mesa.org/xml/B2MML-V0600 ../B2MML/B2MML-V0600-ProductDefinition.xsd")

    definition.add_element('ID').text = order.item_id
    definition.add_element('Description').text = "#{order.item_description} #{order.drawing_description}"
    definition.add_element('ProductSegment').add_element('ID').text = order.job_id
    
    File.open(filename, 'w') do |f|
      form = REXML::Formatters::Pretty.new
      form.compact = true
      form.write(def_document, f)
    end
  end

  def self.write_schedule(order, filename)
    sched_document = REXML::Document.new
    sched_document << REXML::XMLDecl.new("1.0", "UTF-8")

    schedule = sched_document.add_element('ProductionSchedule')
    schedule.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    schedule.add_namespace("b2mml", "http://www.mesa.org/xml/B2MML-V0600")
    schedule.add_namespace("http://www.mesa.org/xml/B2MML-V0600")
    schedule.add_attribute('xsi:schemaLocation',
                           "http://www.mesa.org/xml/B2MML-V0600 ../B2MML/B2MML-V0600-ProductionSchedule.xsd")

    schedule.add_element('ID').text = order.mo_id

    request = schedule.add_element('ProductionRequest')
    request.add_element('ID').text = order.mo_id
    request.add_element('Description').text = "#{order.item_description} #{order.drawing_description}"
    request.add_element('StartTime').text = order.start_date.iso8601
    request.add_element('EndTime').text = order.end_date.iso8601

    segment = request.add_element('SegmentRequirement')
    segment.add_element('ProductSegmentID').text = order.job_id
    segment.add_element('LatestEndTime').text = order.end_date.iso8601

    processes = order.processes.to_a
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

    File.open(filename, 'w') do |f|
      form = REXML::Formatters::Pretty.new
      form.compact = true
      form.write(sched_document, f)
    end
  end  
end
