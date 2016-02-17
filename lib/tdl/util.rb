module TDL
  module Util
    def self.compress_text(text)
      # DEBT compress text should not add quotes
      top_line, *remaing_content = text.split("\n")
      if remaing_content
        lines_remaining = remaing_content.size
        "\"#{top_line} .. ( #{lines_remaining} more line#{ 's' if lines_remaining != 1 } )\""
      else
        "\"#{top_line}\""
      end
    end

    def self.compress_data(data)
      if data.respond_to?(:split)
        "#{TDL::Util.compress_text(data)}"
      else
        "#{data}"
      end
    end
  end
end
