class RunnerAction
  attr_reader :short_name, :name

  def initialize(short_name, name)
    @short_name = short_name
    @name = name
  end

end

module RunnerActions
  def get_new_round_description
    RunnerAction.new('new', 'get_new_round_description')
  end

  def deploy_to_production
      RunnerAction.new('deploy', 'deploy_to_production')
  end

  def all
    [get_new_round_description, deploy_to_production]
  end
end
