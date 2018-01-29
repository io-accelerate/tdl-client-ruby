require 'tdl/runner/challenge_server_client'
require 'tdl/runner/round_management'
require 'tdl/runner/recording_system'

module TDL

  class ChallengeSession
    def self.for_runner(runner)
      ChallengeSession.new(runner)
    end

    def initialize(runner)
      @runner = runner
    end

    def with_config(config)
      @config = config
      @audit_stream = config.get_audit_stream
      self
    end

    def with_action_provider(callback)
      @user_input_callback = callback
      self
    end

    def start
      @recording_system = RecordingSystem.new(@config.get_recording_system_should_be_on)
      
      unless recording_system.is_recording_system_ok
        @audit_stream.write_line 'Please run `record_screen_and_upload` before continuing.'
        return
      end

      @audit_stream.write_line "Connecting to #{@config.get_hostname}"
      run_app
    end

    def run_app
      @challenge_server_client = ChallengeServerClient.new(
        @config.get_hostname,
        @config.get_port,
        @config.get_journey_id,
        @config.get_use_colours)
      
      begin
        should_continue = check_status_of_challenge
        if should_continue
          user_input = @user_input_callback.get
          @audit_stream.write_line "Selected action is: #{user_input}"
          round_description = execute_user_action user_input
          RoundManagement.save_description(@recording_system, round_description, audit_stream)
        end
      rescue ChallengeServerClient::ClientErrorException => e
        @audit_stream.write_line e.message
      rescue ChallengeServerClient::ServerErrorException => e
        @audit_stream.write_line 'Server experienced an error. Try again in a few minutes.'
      rescue ChallengeServerClient::OtherCommunicationException => e
        @audit_stream.write_line 'Client threw an unexpected error. Try again.'
      end
    end

    def check_status_of_challenge
      @audit_stream = @config.get_audit_stream

      journey_progress = @challenge_server_client.get_journey_progress
      @audit_stream.write_line journey_progress

      available_actions = @challenge_server_client.get_available_actions
      @audit_stream.write_line available_actions

      available_actions.indclude? 'No actions available.'
    end

    def execute_user_action(user_input)
      if user_input.equals('deploy')
          @runner.run
          last_fetched_round = RoundManagement.get_last_fetched_round
          @recording_system.deploy_notify_event last_fetched_round
      end

      execute_action user_input
    end

    def execute_action(user_input)
      action_feedback = @challenge_server_client.send_action user_input
      @audit_stream.write_line action_feedback
      @challenge_server_client.get_round_description
    end

  end
    
end
