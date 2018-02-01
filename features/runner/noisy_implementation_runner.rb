class NoisyImplementationRunner

  def initialize(deploy_message, audit_stream)
    @deploy_message = deploy_message
    @audit_stream = audit_stream
  end
  
  def run
    @audit_stream.write_line(@deploy_message)
  end

end
