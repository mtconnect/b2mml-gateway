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
require 'model'
require 'time'

module Parts
  Machines = { 'itamco_Haas' => 'M4144', 'itamco_DMG' => 'M4143' }
  include Logging
  
  def self.store_manufacturing_schedule(xml)
    doc = REXML::Document.new(xml)
    if doc.root.name == "MTConnectAssets"
      doc.each_element(".//Part") do |part|
        part.each_element(".//ProcessStep") do |step|
          begin
            # Check if a order alread exists
            mo_id = part.attributes['assetId']
            mo_op_id = step.attributes['stepId']
            old = QUPID::Schedule.find(mo_id: mo_id, mo_op_id: mo_op_id)
            
            schedule = Hash.new
            schedule['start_date'] = start_time = Time.parse(step.elements["StartTime"].text)
            schedule['due_date'] = start_time + step.elements["StartTime"].text.to_i
                     
            target = step.elements["ProcessTargets/ProcessTarget/TargetRefs/TargetRef"].attributes['targetIdRef']
            schedule['wc_id'] = Machines[target]

            schedule['mo_id'] = mo_id
            schedule['mo_op_id'] = mo_op_id
            schedule['employees_sid'] = 4
            schedule['create_sid'] = 4

            unless old
              schedule['create_date'] = Time.now
              Logging.logger.info "Creating manufacturing schedule for: #{schedule['mo_id']} op #{schedule['mo_op_id']}"
              sched = QUPID::Schedule.new(schedule)
              sched.save
            else
              schedule['change_sid'] = 4
              schedule['change_date'] = Time.now
              
              Logging.logger.info "Updating manufacturing schedule for: #{schedule['mo_id']} op #{schedule['mo_op_id']}"
              old.set(schedule)
              old.save(changed: true)
            end
            
          rescue
            Logging.logger.error $!
            Logging.logger.error $!.backtrace.join("\n")
          end
        end
      end
    else
      raise "Error, wrong asset type: #{doc.root.name}"
    end
  end
  
end
