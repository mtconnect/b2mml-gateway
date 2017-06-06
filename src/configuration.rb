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

require 'yaml'
require 'sequel'
require 'core_ext'

$config_dir = "#{File.dirname(__FILE__)}/../config/"

if RUBY_PLATFORM =~ /mingw32/
  fn, = Gem.find_files('libxml.rb')
end

GATEWAY_ENV ||= ENV['GATEWAY_ENV'] && ENV['GATEWAY_ENV'].to_sym || :production
$gateway_env = GATEWAY_ENV

require 'logging'

$database_configuration = YAML.load_file("#{$config_dir}database.yaml").deep_symbolize_keys
config = $database_configuration[GATEWAY_ENV]

adapter = config.delete(:adapter)
config[:loggers] = [Logging.logger]
DB = Sequel.send(adapter, config)
DB.sql_log_level = :debug if $gateway_env == :debug

Sequel::Model.db = DB

require 'model'

