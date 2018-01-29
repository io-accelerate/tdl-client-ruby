require 'unirest'
require 'tdl/runner/runner_action'

RECORDING_SYSTEM_ENDPOINT = 'http://localhost:41375'

class RecordingSystem
    
    def initialize(recording_required)
        @recording_required = recording_required
    end

    def is_recording_required
        @recording_required
    end

    def is_recording_system_ok
        return is_recording_required ? is_running : true
    end

    def is_running
        begin
            response = Unirest.get "#{RECORDING_SYSTEM_ENDPOINT}/status"
    
            if response.code == 200 and response.body.start_with?('OK')
                return true
            end
        rescue StandardError => e
            puts "Could not reach recording system: #{e.message}"
        end
        false
    end

    def deploy_notify_event(last_fetched_round)
        notifyEvent(last_fetched_round, RunnerActions.deploy_to_production.getShortName)
    end

    def on_new_round(round_id, short_name)
        notify_event(round_id, short_name)
    end

    def notify_event(last_fetched_round, short_name)
        if not @recording_required
          return
        end
    
        begin
          response = Unirest.post "#{RECORDING_SYSTEM_ENDPOINT}/notify",
                                  parameters:"#{last_fetched_round}/#{short_name}"
    
          unless response.code == 200
            puts "Recording system returned code: #{response.code}"
            return
          end
    
          unless response.body.start_with?('ACK')
            puts "Recording system returned body: #{response.body}"
          end
        rescue StandardError => e
          puts "Could not reach recording system: #{e.message}"
        end
    end

end
