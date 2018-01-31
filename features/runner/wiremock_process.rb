require 'rest-client'

class WiremockProcess
  
  def initialize(hostname, port)
    @base_url = "http://#{hostname}:#{port}"
  end

  def create_new_mapping(config)
    request_json = {
      request: {
        urlPattern: config.endpoint_matches,
        url: config.endpoint_equals,
        method: config.verb
      }
    }

    if config.accept_header
      request_json['request']['headers'] = {
        accept: {
          contains: config.accept_header
        }
      }
    end

    RestClient.post("#{@base_url}/__admin/mapping/new", )
  end

  def reset
    RestClient.post("#{@base_url}/__admin/reset")
  end

  def verify_endpoint_was_hit(endpoint, method_type, body)
    count_requests_with_endpoint(endpoint, method_type, body) === 1
  end

  def count_requests_with_endpoint(endpoint, verb, body)
    request_json = {
      url: endpoint,
      method: verb
    }

    if body
      request_json['bodyPatterns'] = [{equalTo: body}]
    end

    RestClient.post("#{@base_url}/__admin/requests/count", request_json)
  end

end
