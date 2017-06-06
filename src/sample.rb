# Copyright 2014, System Insights, Inc.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'rexml/document'

module Sample
  class StreamError < StandardError; end

  def Sample.parse(xml, instance, program)
    doc = REXML::Document.new(xml)

    if doc.root.name == 'MTConnectError'
      doc.each("//Error") do |err|
        if err
          raise StreamError.new("#{err.attributes['errorCode']}: #{err.content}")
        else
          raise StreamError.new("Unknown error")
        end
      end
    end

    nxt = nil
    count = 0
    header = doc.elements['//Header']
    nxt = header.attributes['nextSequence']

    doc.each_element('//DeviceStream/ComponentStream') do |stream|
      begin
        count, program = parse_component_stream(stream, instance, program)
      rescue
        Logging.logger.error "Error parsing device stream: #{$!}#{$!.class.name}"
        Logging.logger.debug $!.backtrace.join("\n")
      end
    end

    Logging.logger.error "Could not find next sequence id" unless nxt
    return nxt.to_i, count, program
  end

  def Sample.parse_component_stream(component, instance, program)
    Logging.logger.debug "Got component stream for #{component.attributes['component']}[#{component.attributes['name']}]"

    count = 0
    component.each_element('Events/*') do |ele|
      program = parse_event(ele, instance, program)
      count += 1
    end
    component.each_element('Samples/*') do |ele|
      parse_sample(ele, instance, program)
      count += 1
    end
    component.each_element('Condition/*') do |ele|
      parse_condition(ele, instance, program)
      count += 1
    end

    return count, program
  end

  def Sample.parse_event(event, instance, program)
    case event.name
    when 'AssetChanged'
      asset_id = event.text
      asset_type = event.attributes['assetType']
      Logging.logger.info "Got an asset changed type: #{asset_type} for #{asset_id}"
      case asset_type
      when 'AP242', 'AP238'
        xml = Collector.get_asset(asset_id)
        if xml
          Logging.logger.debug "Received body for #{asset_type} #{asset_id}"
          doc = REXML::Document.new(xml)
          doc.each_element('//Assets/*') do |asset|
            file = asset_id
            Logging.logger.info "Found asset data for #{asset_id}, writing to file: #{file}"
            File.open(file, 'w') do |f|
              f.write asset.text
            end
          end            
        end
      else
        Logging.logger.info "Got unknown asset type: #{asset_type}"
      end
    else
      Logging.logger.debug "Got event for #{event.name} #{event.text}"
    end
    program
  end

  def Sample.parse_sample(sample, instance, program)
    Logging.logger.debug "Got sample for #{sample.name} #{sample.text}"
  end

  def Sample.parse_conditions(conditions, instance, program)
    Logging.logger.debug "Got condiion for #{condition.name} #{condition.text}"
  end
  
end
