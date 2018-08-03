require 'tdl/runner/challenge_server_client'
require 'tdl/runner/round_management'
require 'tdl/runner/recording_system'

include RoundManagement

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
      
      unless @recording_system.is_recording_system_ok
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
        @audit_stream = @config.get_audit_stream

        journey_progress = @challenge_server_client.get_journey_progress
        @audit_stream.write_line(journey_progress)

        available_actions = @challenge_server_client.get_available_actions
        @audit_stream.write_line(available_actions)

        no_actions_available = available_actions.include?('No actions available.')
        if no_actions_available
          @recording_system.tell_to_stop
          return
        end

        user_input = @user_input_callback.call
        @audit_stream.write_line "Selected action is: #{user_input}"
        if user_input == 'deploy'
          @runner.run
          last_fetched_round = RoundManagement.get_last_fetched_round(@config.get_working_directory)
          @recording_system.notify_event(last_fetched_round, RecordingEvent::ROUND_SOLUTION_DEPLOY)
        end

        action_feedback = @challenge_server_client.send_action user_input
        if action_feedback.include?('Round time for')
          last_fetched_round = RoundManagement.get_last_fetched_round(@config.get_working_directory)
          @recording_system.notify_event(last_fetched_round, RecordingEvent::ROUND_COMPLETED)
        end
        if action_feedback.include?('All challenges have been completed')
          @recording_system.tell_to_stop
        end

        @audit_stream.write_line action_feedback
        round_description = @challenge_server_client.get_round_description
        RoundManagement.save_description(@recording_system, round_description, @audit_stream, @config.get_working_directory)
      rescue ChallengeServerClient::ClientErrorException => e
        @audit_stream.write_line e.message
      rescue ChallengeServerClient::ServerErrorException => e
        @audit_stream.write_line 'Server experienced an error. Try again in a few minutes.'
      rescue ChallengeServerClient::OtherCommunicationException => e
        @audit_stream.write_line 'Client threw an unexpected error. Try again.'
      end
    end


  end
    
end
