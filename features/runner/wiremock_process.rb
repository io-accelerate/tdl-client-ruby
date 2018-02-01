require 'rest-client'

class WiremockProcess
  
  def initialize(hostname, port)
    @base_url = "http://#{hostname}:#{port}"
  end

  def create_new_mapping(config)
    request_json = {
      request: {
        urlPattern: config[:endpointMatches],
        url: config[:endpointEquals],
        method: config[:verb]
      },
      response: {
        body: config[:responseBody],
        statusMessage: config[:statusMessage],
        status: config[:status]
      }
    }

    if config[:acceptHeader]
      request_json[:request][:headers] = {
        accept: {
          contains: config[:acceptHeader]
        }
      }
    end
    
    RestClient.post("#{@base_url}/__admin/mappings/new", request_json.to_json, {content_type: :json, accept: :json})
  end

  def reset
    RestClient.post("#{@base_url}/__admin/reset", {})
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
      request_json[:bodyPatterns] = [{equalTo: body}]
    end

    response = RestClient.post("#{@base_url}/__admin/requests/count", request_json.to_json, {content_type: :json, accept: :json})
    JSON.parse(response.body)["count"]
  end

end
