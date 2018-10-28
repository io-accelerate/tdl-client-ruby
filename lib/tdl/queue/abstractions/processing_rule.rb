module TDL
  class ProcessingRule
    attr_reader :user_implementation

    def initialize(user_implementation)
      @user_implementation = user_implementation
    end
  end
end
