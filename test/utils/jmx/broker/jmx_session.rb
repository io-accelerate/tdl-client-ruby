
class JmxMBeans

  def initialize(jolokia_url)
    @jolokia_url = jolokia_url
  end

  def self.connect(host, admin_port)
    begin
      jolokia_url = "http://#{host}:#{admin_port}/api/jolokia"
      endpoint = '/version'
      jolokia_version = JSON.parse(Net::HTTP.get(URI(jolokia_url + endpoint)))['value']['agent']

      expected_jolokia_version = '1.2.2'
      if jolokia_version != expected_jolokia_version
        raise "Failed to retrieve obtain the right Jolokia version. Expected: #{expected_jolokia_version} got #{jolokia_version}"
      end
    rescue Exception => e
      puts "Broker is busted: #{e}"
    end

    JmxMBeans.new(jolokia_url)
  end



  def read(asd)
    nil
  end

end