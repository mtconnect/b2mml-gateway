
require 'rexml/document'
require 'ruby-duration'
require 'directory_scanner'
require 'uuid'
 
class STEP < DirectoryScanner
  include Logging
  
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_ISO10303 = UUID.create_sha1("http://www.iso.org/ISO-10303", UUID::NameSpace_URL)


  def initialize
    doc = YAML.load_file("#{$config_dir}design.yaml")
    if doc.include?('directory')
      dir = doc['directory']
    else
      dir = File.join(File.dirname(__FILE__), "../step")      
    end

    super(dir, "*.stp")
  end

  def process_file(f)
    step = ""
    uuid = write_step_asset(f, step)
    
    logger.info "Posting STEP file #{uuid}"
    Collector.post_asset(uuid, "AP242", "itamco_QUPID_6ee5c9", step)
    
    #File.open("#{File.basename(f, '.stp')}.xml", 'w') do |o|
    #  o.write(step)
    #end
    
  rescue
    logger.error "Process File failed: #{$!}"
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
  
