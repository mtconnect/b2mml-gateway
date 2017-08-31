
require 'rexml/document'
require 'ruby-duration'
require 'uuid'

class DirectoryScanner
  include Logging
  
  def initialize(directory, pattern)
    @files = {}
    @running = false

    @pattern = pattern
    @directory = File.expand_path(directory)
    logger.info "Scanning directory: #{@directory} for files #{pattern}"    
  end

  def start
    logger.info "Starting #{@directory} scanner"
    @thread = Thread.new do
      scan_directory
    end
  end

  def stop
    @running = false
  end

  def process_file(f)
    raise "Process File not implemented"
  end

  def scan_directory
    @running = true
    logger.info "Starting scanner for #{@directory}"
    while @running
      Dir["#{@directory}/#{@pattern}"].each do |f|
        if !@files.include?(f) or @files[f] != File.stat(f).mtime

          process_file(f)
          
          @files[f] = File.stat(f).mtime
        end
      end
        
      sleep 10
    end

  rescue
    logger.error "Scanner failed: #{$!}"
    logger.error $!.backtrace.join("\n")
  end
end
  
