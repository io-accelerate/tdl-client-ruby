module TDL
  module PresentationUtil
    
    def self.to_displayable_request(params)
      return params.map{ |param|
        TDL::PresentationUtil.serialize_and_compress(param)
      }.join(', ')
    end

    def self.to_displayable_response(value)
      return TDL::PresentationUtil.serialize_and_compress(value)
    end


    def self.serialize_and_compress(value)
      representation = JSON.generate(value, quirks_mode: true)

      if list_like?(value)
        representation = representation.gsub(',', ', ')
      elsif multiline_string?(representation)
        representation = suppress_extra_lines(representation)
      end

      representation
    end

    def self.list_like?(value)
      value.is_a?(Array)
    end

    def self.multiline_string?(value)
      value.include?("\\n")
    end

    def self.suppress_extra_lines(value)
      return value.to_s unless value.is_a?(String)

      parts = value.split("\\n")
      top_line = parts[0]
      remaining_lines = parts.size - 1

      representation = "#{top_line} .. ( #{remaining_lines} more line"
      representation += "s" if remaining_lines > 1
      representation += " )\""
      representation
    end
  end
end
