
require 'rexml/document'
require 'ruby-duration'
require 'uuid'

class STEP
  include Logging
  
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_ISO10303 = UUID.create_sha1("http://www.iso.org/ISO-10303", UUID::NameSpace_URL)

  @@dir = File.join(File.dirname(__FILE__), "../step")

  def initialize
    @files = {}
    @running = false
    
    doc = YAML.load_file("#{$config_dir}design.yaml")
    if doc.include?('directory')
      @@dir = doc['directory']
    end

    @directory = File.expand_path(@@dir)
    logger.info "Scanning directory for STEP files: #{@directory}"    
  end

  def start
    logger.info "Starting STEP scanner"
    @thread = Thread.new do
      scan_directory
    end
  end

  def stop
    @running = false
  end

  def scan_directory
    @running = true
    logger.info "Starting scanner"
    while @running
      Dir["#{@directory}/*.stp"].each do |f|
        if !@files.include?(f) or @files[f] != File.stat(f).mtime
          step = ""
          uuid = write_step_asset(f, step)
          
          logger.info "Posting STEP file #{uuid}"
          Collector.post_asset(uuid, "AP242", "itamco_QUPID", step)
          
          #File.open("#{File.basename(f, '.stp')}.xml", 'w') do |o|
          #  o.write(step)
          #end

          @files[f] = File.stat(f).mtime
        end
      end
        
      sleep 10
    end

  rescue
    logger.error "Scanner failed: #{$!}"
    logger.error $!.backtrace.join("\n")
  end

  def create_AP242_asset_id(step_file)
    UUID.create_sha1(step_file.to_s, NameSpace_ISO10303)
  end

  def write_step_asset(file_name, io)
    base = File.basename(file_name, '.stp')
    document = REXML::Document.new

    asset = document.add_element("AP242")
    uuid = base # create_AP242_asset_id(base)
    asset.add_attribute("assetId", uuid)
    asset.add_attribute("timestamp", Time.now.utc.iso8601)
    asset.add_attribute("deviceUuid", 'itamco_QUPID_6ee5c9')
    asset.add_element("Description").text = base

    content = asset.add_element("Content")
    content.text = REXML::CData.new(File.read(file_name))
    
    form = REXML::Formatters::Pretty.new
    form.compact = true
    form.write(document, io)

    return uuid
  end
  
end
  
