
require 'net/http'
require 'json'

class JolokiaSession

  def initialize(jolokia_uri)
    @uri = jolokia_uri
  end

  def self.connect(host, admin_port)
    jolokia_url = "http://#{host}:#{admin_port}/api/jolokia"
    endpoint = '/version'
    jolokia_version = JSON.parse(Net::HTTP.get(URI(jolokia_url + endpoint)))['value']['agent']

    expected_jolokia_version = '1.2.2'
    if jolokia_version != expected_jolokia_version
      raise "Failed to retrieve the right Jolokia version. Expected: #{expected_jolokia_version} got #{jolokia_version}"
    end

    JolokiaSession.new(URI(jolokia_url))
  end


  def request(jolokia_payload)
    json_payload = jolokia_payload.to_json
    puts "Payload: #{json_payload}"

    http_request = Net::HTTP::Post.new(@uri, initheader = {'Content-Type' => 'application/json'})
    http_request.body = json_payload
    http_response = Net::HTTP.new(@uri.hostname, @uri.port).start { |http| http.request(http_request) }
    if http_response.code != '200'
      raise "Failed Jolokia call: #{http_response.code} #{http_response.message}: #{http_response.body}"
    end

    json_response = http_response.body
    jolokia_response = JSON.parse(json_response)
    jolokia_response['value']
  end

end