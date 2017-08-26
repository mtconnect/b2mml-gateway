require 'rexml/document'
require 'ruby-duration'
require 'uuid'

module CuttingTool
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_B2MML = UUID.create_sha1("http://www.mesa.org/xml/B2MML-V0600", UUID::NameSpace_URL)
  NameSpace_CuttingTool = UUID.create_sha1("urn:mtonnect.org:CuttingTool", UUID::NameSpace_OID)

  def self.create_cutting_tool_asset_id(tool_id)
    UUID.create_sha1(tool_id.to_s, NameSpace_CuttingTool)
  end

  def self.write_cutting_tool(details, io)
    document = REXML::Document.new

    asset = document.add_element("CuttingTool")
    uuid = create_cutting_tool_asset_id(details.instance_id || details.sid)
    asset.add_attribute("assetId", uuid)
    asset.add_attribute("timestamp", Time.now.utc.iso8601)
    asset.add_attribute("deviceUuid", 'itamco_Preseter_604778')
    asset.add_attribute("toolId", details.sid)
    asset.add_attribute("serialNumber", details.instance_id || details.sid)
    asset.add_element("Description").text = "#{details.tool_item_id} #{details.tool_description}"

    # Mark as removed if the asset has either a delete sid or date
    if details.delete_sid || details.delete_date
      asset.add_attributee("removed", "true")
    end
    
    life = asset.add_element("CuttingToolLifeCycle")

    status = life.add_element('CutterStatus')
    status.add_element('Status').text = 'NEW'
    
    # Need tool life definition...
    # asset.add_element("ToolLife")
    
    life.add_element("ProgramToolNumber").text = details.tool_no
    life.add_element("ConnectionCodeMachineSide").text = details.holder_item_id if details.holder_item_id

    measurements = life.add_element('Measurements')
    
    if details.tool_length_min
      length = measurements.add_element("OverallToolLength")
      length.add_attribute("minimum", details.tool_length_min)
      length.add_attribute("code", "OAL")
    end
    if details.max_depth_cut
      depth = measurements.add_element("DepthOfCutMax")
      depth.add_attribute("code", "APMX")
      depth.add_attribute("maximum", details.max_depth_cut)
    end
    
    if details.diameter_cutting
      diameter = measurements.add_element("CuttingDiameterMax")
      diameter.add_attribute("code", "DC")
      diameter.add_attribute("nominal", details.diameter_cutting)
    end
	
    items = life.add_element("CuttingItems")
    items.add_attribute("count", "1")
    item = items.add_element("CuttingItem")
    item.add_attribute("itemId", details.insert_item_id)
    item.add_element("Description").text = details.insert_id

    form = REXML::Formatters::Pretty.new
    form.compact = true
    form.write(document, io)

    return uuid
  end
  
end
  
