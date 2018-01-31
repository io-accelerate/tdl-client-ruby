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

    if (config.accept_header)
      request_json['request']['headers']
    end

    RestClient.post('__admin/mapping/new', )
  end

  def reset

  end

  def verify_endpoint_was_hit(endpoint, method_type, body)

  end

  def count_requests_with_endpoint(endpoint, verb, body)

  end

end
