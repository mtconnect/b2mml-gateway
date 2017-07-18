# Copyright 2017, System Insights, Inc.
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

$: << File.join(File.dirname(__FILE__), '..', 'src')

require 'configuration'
require 'strscan'

$data_dir = File.join(File.dirname(__FILE__), '..', 'data')

files = Dir["#{$data_dir}/*.rpt"]


files.each do |name|
  file = File.open(name, mode: 'r:UTF-8')
  text = file.read(2048)
  parser = StringScanner.new(text)

  parser.skip(/[^\/]*\/\*-+\s+/mi)
  p parser
  table_name = parser.scan(/\w+/)
  parser.skip(/.+?----------+\*\/[^\n]\n/m)
  start = parser.pos

  p table_name

  file.seek(start)
  columns = file.readline.strip.split('|').map(&:to_sym)

  DB.sql_log_level = :debug
  
  table = DB[table_name.to_sym]
  table.truncate
  
  lines = file.readlines
  prev  = ""
  lines.each do |line|
    next if line !~ /\|/ || line == prev
    prev = line
    
    fields = line.split('|').map(&:strip)
    fields.map! { |v|  v == 'NULL' ? nil : v }
    row = Hash[*columns.zip(fields).flatten]
    table.insert(row)
  end
end

