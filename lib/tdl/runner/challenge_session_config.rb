module TDL
    
  class ChallengeSessionConfig
    def self.for_journey_id(journey_id)
      ChallengeSessionConfig.new(journey_id)
    end

    def initialize(journey_id)
      @port = 8222
      @use_colours = true
      @recording_system_should_be_on = true
      @journey_id = journey_id
    end 

    def with_server_hostname(hostname)
      @hostname = hostname
      self
    end

    def with_port(port)
      @port = port
      self
    end

    def with_colours(use_colours)
      @use_colours = use_colours
      self
    end

    def with_recording_system_should_be_on(recording_system_should_be_on)
      @recording_system_should_be_on = recording_system_should_be_on
      self
    end

    def with_audit_stream(audit_stream)
      @audit_stream = audit_stream
      self
    end

    def get_recording_system_should_be_on
      @recording_system_should_be_on
    end

    def get_hostname
      @hostname
    end

    def get_port
      @port
    end

    def get_journey_id
      @journey_id
    end

    def get_use_colours
      @use_colours
    end

    def get_audit_stream
      @audit_stream
    end
  end

end
