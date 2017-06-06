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

require 'configuration'
require 'collector'

module Main
  def Main.start
    require 'logger'
    require 'yaml'
    dir = File.expand_path(File.expand_path(File.dirname(__FILE__) + "/../"))
    log = Logger.new("#{dir}/log/config.log")
    Dir.glob("#{dir}/config/*.yaml") do |f|
      data = YAML.load_file(f)
      log.info(data)
    end

    doc = YAML.load_file("#{$config_dir}agents.yaml")

    $running = true
    threads = doc.map do |name, config|
      Thread.new do
        collector = Collector.new(name, config['url'], config['filter'], config['device'])
        collector.stream
      end
    end
    Collector.sample_queue
  end
  
  def Main.stop
    $running = false
    Collector.signal_queue
  end
end

if $0 == __FILE__
  Main.start
end
