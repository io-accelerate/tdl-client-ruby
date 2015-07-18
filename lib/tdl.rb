

module TDL

  class Client
    def self.hi(language = "english")
      translator = Translator.new(language)
      translator.hi
    end
  end

end
require 'tdl/translator'
