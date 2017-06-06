
$: << File.join(File.dirname(__FILE__), "/../src")

$collector_env = :test
$config_dir = File.join(File.dirname(__FILE__), "/../config/")

require 'logging'
require 'rexml/document'
require 'time'

MeasurementFile.create_directory('./test_measurements')

module XmlHelper
  def create_mtc_root(node, doc_type, seq = '100')
    document = REXML::Document.new
    document << REXML::XMLDecl.new("1.0", "UTF-8")

    root = REXML::Element.new(node)
    root.add_namespace('xsi', 'http://www.w3.org/2001/XMLSchema-instance')
    root.add_namespace("urn:mtconnect.org:#{doc_type}:1.3")
    root.add_namespace('m', "urn:mtconnect.org:#{doc_type}:1.3")
    root.add_attribute('xsi:schemaLocation', "urn:mtconnect.org:#{doc_type}:1.3 #{doc_type}_1.3.xsd")

    header = REXML::Element.new('Header', root)
    header.add_attributes('creationTime' => Time.now.utc.xmlschema, 'assetBufferSize' => '1024',
                          'sender' => 'localhost', 'assetCount' => '0', 'version' => '1.3',
                          'instanceId' => '10', 'bufferSize' => 2 ** 17, 'nextSequence' => seq)
    root
  end

  def create_device_root(node, doc_type, seq = '100')
    REXML::Element.new('Devices', create_mtc_root(node, doc_type, seq))
  end

  def create_streams_root(node, doc_type, seq = '100')
    REXML::Element.new('Streams', create_mtc_root(node, doc_type, seq))
  end

  def create_error_root(node, doc_type, seq = '100')
    REXML::Element.new('Errors', create_mtc_root(node, doc_type, seq))
  end
end

module SampleHelper
  def self.included(klass)
    klass.let(:plant_device) {
      PlantDevice.create(uuid: '123', name: 'Name', is_enabled: true,
                        description: 'Hello')
    }

    klass.let(:device) {
      MtcComponent.create(device: plant_device, xml_id: 'dev', name: 'device',
                           type: 'Device')
    }

    klass.let(:controller) {
      MtcComponent.create(device: plant_device, xml_id: 'cnt', name: 'cont',
                          type: 'Controller', parent: device)
    }

    klass.let(:mode) {
      MtcDataItem.create(component: controller, xml_id: 'm', name: 'mode',
                          category: 'EVENT', type: 'CONTROLLER_MODE')
    }

    klass.let(:position) {
      MtcDataItem.create(component: controller, xml_id: 'p', name: 'pos',
                          category: 'SAMPLE', type: 'POSITION', units: 'MILLIMETER')
    }

    klass.let(:path_position) {
      MtcDataItem.create(component: controller, xml_id: 'pp', name: 'path_pos',
                          category: 'SAMPLE', type: 'PATH_POSITION', units: 'MILLIMETER_3D')
    }

    klass.let(:system) {
      MtcDataItem.create(component: controller, xml_id: 's', name: 'system',
                          category: 'CONDITION', type: 'SYSTEM', )
    }
  end
  
  def create_device
    mode
    position
    path_position
    system
  end
  
  def create_device_stream(seq = '100')
    streams = create_streams_root('MTConnectStreams', 'MTConnectStreams', seq)
    device_stream = REXML::Element.new('DeviceStream', streams)
    device_stream.add_attributes('name' => 'Name', 'uuid' => '123')
    device_stream
  end

  def create_component_stream(seq = '100')
    device_stream = create_device_stream(seq)
    component_stream = REXML::Element.new('ComponentStream', device_stream)
    component_stream.add_attributes('component' => 'Controller', 'name' => 'cont',
                                    'componentId' => 'cnt')
    component_stream
  end

  def create_measurement(events, text, seq, ts = '2014-06-20T18:50:54.575917')
    m = REXML::Element.new('Measurement', events)
    m.add_attributes('dataItemId' => 'm', 'timestamp' => ts,
                        'name' => 'measure', 'sequence' => seq)
    m.text = text
    m
  end
  
  def create_execution(events, text, seq, ts = '2014-06-20T18:50:54.575917')
    m = REXML::Element.new('Execution', events)
    m.add_attributes('dataItemId' => 'exec', 'timestamp' => ts,
                        'name' => 'exec', 'sequence' => seq)
    m.text = text
    m
  end

end
