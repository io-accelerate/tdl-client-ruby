require 'unirest'
require 'tdl/runner/runner_action'

RECORDING_SYSTEM_ENDPOINT = 'http://localhost:41375'

module RecordingEvent
  ROUND_START = 'new'
  ROUND_SOLUTION_DEPLOY = 'deploy'
  ROUND_COMPLETED = 'done'
end


class RecordingSystem

    def initialize(recording_required)
        @recording_required = recording_required
    end

    def is_recording_required
        @recording_required
    end

    def is_recording_system_ok
      is_recording_required ? is_running : true
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


    def on_new_round(round_id)
        notify_event(round_id, RecordingEvent::ROUND_START)
    end

    def notify_event(round_id, event_name)
        if not @recording_required
          return
        end

        begin
          response = Unirest.post "#{RECORDING_SYSTEM_ENDPOINT}/notify",
                                  parameters:"#{round_id}/#{event_name}"

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
