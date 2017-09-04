
require 'rexml/document'
require 'ruby-duration'
require 'directory_scanner'
require 'cutting_tool'
require 'uuid'
require 'json'
require 'uri'
 
class Tools < DirectoryScanner
  include Logging
  
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_CuttingTool = UUID.create_sha1("CuttingTool", NameSpace_MTConnect)

  Details = Struct.new(:sid, :instance_id, :tool_length_min, :max_depth_cut,
                       :diameter_cutting, :shank_diameter, :flutes, 
                       :tool_item_id, :tool_description, :insert_item_id, :insert_id,
                       :delete_sid, :delete_date, :tool_no, :holder_item_id)

  def initialize
    doc = YAML.load_file("#{$config_dir}tools.yaml")
    if doc.include?('directory')
      dir = doc['directory']
    else
      dir = File.join(File.dirname(__FILE__), "../tools")      
    end

    super(dir, "*.json")
  end

  def process_file(f)
    json = JSON.load(File.read(f))
    json.each do |tool|
      arch = post_details(tool, "CuttingToolArchetype")                                  
      post_details(tool, "CuttingTool", arch, "1")
      post_details(tool, "CuttingTool", arch, "2")
    end
    
  rescue
    logger.error "Process File failed: #{$!}"
    logger.error $!.backtrace.join("\n")
  end

  def post_details(tool, type, arch = nil, suffix = nil)
    sid = File.basename(URI.parse(tool["url"]).path)
    sid = "#{sid}-#{suffix}" if suffix
    inst_id = tool["partId"]
    inst_id = "#{inst_id}-#{suffix}" if suffix
    
    details = Details.new(sid, inst_id, tool["cuttingLength"], tool["depthMax"],
                          tool["diameter"], tool["shankWidth"], tool["numberOfFlutes"],
                          tool["url"], tool["toolType"])
    
    
    data = ""
    uuid = CuttingTool.write_cutting_tool(details, data, arch)
    
    logger.info "Posting Tool file #{uuid}"
    Collector.post_asset(uuid, type, "itamco_Presetter_604778", data)
    
    #File.open("#{sid}.xml", 'w') do |o|
    #  o.write(data)
    #end
    
    return uuid
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
  
