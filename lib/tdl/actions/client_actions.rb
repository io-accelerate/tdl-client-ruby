require 'tdl/actions/publish_action'
require 'tdl/actions/stop_action'
require 'tdl/actions/publish_and_stop_action'

module TDL
  module ClientActions

    def publish
      PublishAction.new
    end

    def stop
      StopAction.new
    end

    def publish_and_stop
      PublishAndStopAction.new
    end
  end
end
