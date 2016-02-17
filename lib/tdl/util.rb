module TDL
  module Util
    def self.compress_text(text)
      top_line, *remaing_content = text.split("\n")
      if remaing_content
        lines_remaining = remaing_content.size
        "\"#{top_line} .. ( #{lines_remaining} more line#{ 's' if lines_remaining != 1 } )\""
      else
        "\"#{top_line}\""
      end
    end

    def self.compress_params(params)

    end
  end
end
