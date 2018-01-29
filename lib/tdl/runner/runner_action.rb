require 'tdl/queue/actions/client_actions'

class RunnerAction
  attr_reader :short_name, :name, :client_action

  def initialize(short_name, name, client_action)
    @short_name = short_name
    @name = name
    @client_action = client_action
  end

end

module RunnerActions
  def get_new_round_description
    RunnerAction.new('new', 'get_new_round_description', ClientActions.stop)
  end

  def deploy_to_production
      RunnerAction.new('deploy', 'deploy_to_production', ClientActions.publish)
  end

  def all
    [get_new_round_description, deploy_to_production]
  end
end
