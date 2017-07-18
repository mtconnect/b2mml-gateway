require 'rexml/document'
require 'ruby-duration'
require 'uuid'

module CuttingTool
  NameSpace_MTConnect = UUID.create_sha1("urn:mtconnect.org", UUID::NameSpace_OID)
  NameSpace_B2MML = UUID.create_sha1("http://www.mesa.org/xml/B2MML-V0600", UUID::NameSpace_URL)
  NameSpace_CuttingTool = UUID.create_sha1("urn:mtonnect.org:CuttingTool", UUID::NameSpace_OID)

  def self.write_cutting_tool(details, bot, device)
    
  end
  
end
  
