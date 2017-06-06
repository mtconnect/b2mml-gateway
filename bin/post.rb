require 'net/http'
require 'rexml/document'

if (ARGV.length < 1)
  puts "Usage: ruby post.rb <filename>"
  exit(1)
end

filename = ARGV[0]

def post_file(data, uuid, type)
  path = "/asset/#{uuid}?device=OKUMA.MachiningCenter.123456&type=#{type}"
  
  Net::HTTP.start('swim.steptools.com', 5000) do |http|
    res = http.post(path, data, { 'Content-Type' => 'text/xml', 'Content-Length' =>  data.length.to_s })
    puts res.body
  end
end

data = File.read(filename)
case filename
when /qif$/
  #doc = REXML::Document.new(data)
  #ele, = REXML::XPath.match(doc, '/QIFDocument/QPId')  
  #uuid = ele ? ele.text : filename
  cleaned = data.sub(/^[^<]+\<\?[^>]+\>[\r]?\n/, '')
  wrapped = "<QIFResult>#{cleaned}</QIFResult>"
  post_file(wrapped, uuid, "QIFResult")

when /stp$/
  wrapped = "<AP242><![CDATA[#{data}]]></AP242>"
  post_file(wrapped, filename, "AP242")
  
when /stpnc$/
  wrapped = "<AP238><![CDATA[#{data}]]></AP238>"
  post_file(wrapped, filename, "AP238")
end
