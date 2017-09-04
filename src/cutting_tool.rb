require 'rexml/document'
require 'ruby-duration'
require 'uuid'

module CuttingTool
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_CuttingTool = UUID.create_sha1("urn:mtonnect.org:CuttingTool", UUID::NameSpace_OID)

  def self.create_cutting_tool_asset_id(tool_id)
    UUID.create_sha1(tool_id.to_s, NameSpace_CuttingTool)
  end

  def self.write_cutting_tool(details, io, id, archetype = nil)
    document = REXML::Document.new

    unless archetype
      asset = document.add_element("CuttingToolArchetype")
    else
      asset = document.add_element("CuttingTool")
    end

    uuid = create_cutting_tool_asset_id(id)
    asset.add_attribute("assetId", uuid)
    asset.add_attribute("timestamp", Time.now.utc.iso8601)
    asset.add_attribute("deviceUuid", 'itamco_Presetter_514301')
    asset.add_attribute("toolId", id)
    asset.add_attribute("serialNumber", details.sid)

    if archetype
      ref = asset.add_element("AssetArchetypeRef")
      ref.add_attribute("assetType", "CuttingToolArchetype")
      ref.add_attribute("assetId", archetype)
    end
    asset.add_element("Description").text = "#{details.tool_id}"


    # Mark as removed if the asset has either a delete sid or date
    if details.delete_sid || details.delete_date
      asset.add_attributee("removed", "true")
    end
    
    life = asset.add_element("CuttingToolLifeCycle")

    if archetype
      status = life.add_element('CutterStatus')
      status.add_element('Status').text = 'NEW'
    end
    
    # Need tool life definition...
    # asset.add_element("ToolLife")
    
    life.add_element("ProgramToolNumber").text = details.tool_no
    life.add_element("ConnectionCodeMachineSide").text = details.holder_item_id if details.holder_item_id

    measurements = life.add_element('Measurements')
    
    if details.tool_length_min
      length = measurements.add_element("OverallToolLength")
      length.add_attribute("minimum", details.tool_length_min)
      length.add_attribute("code", "OAL")
      length.text = details.tool_length_min if archetype
    end
    
    if details.max_depth_cut
      depth = measurements.add_element("DepthOfCutMax")
      depth.add_attribute("code", "APMX")
      depth.add_attribute("maximum", details.max_depth_cut)
      depth.text = details.max_depth_cut if archetype
    end
    
    if details.diameter_cutting
      diameter = measurements.add_element("CuttingDiameterMax")
      diameter.add_attribute("code", "DC")
      diameter.add_attribute("nominal", details.diameter_cutting)
      diameter.text = details.diameter_cutting if archetype
    end

    if details.respond_to? :shank_diameter and details.shank_diameter
      diameter = measurements.add_element("ShankDiameter")
      diameter.add_attribute("code", "DMM")
      diameter.add_attribute("nominal", details.shank_diameter)
      diameter.text = details.shank_diameter if archetype
    end
	
    items = life.add_element("CuttingItems")
    if details.respond_to? :flutes and details.flutes
      items.add_attribute("count", details.flutes)
    else
      items.add_attribute("count", "1")
    end      
    item = items.add_element("CuttingItem")
    item.add_attribute("itemId", details.insert_item_id) if details.insert_item_id
    item.add_element("Description").text = details.insert_id if details.insert_id

    form = REXML::Formatters::Pretty.new
    form.compact = true
    form.write(document, io)

    return uuid
  end
  
end
  
