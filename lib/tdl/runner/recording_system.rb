require 'uri'
require 'net/http'
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
            response = Net::HTTP.get_response(URI("#{RECORDING_SYSTEM_ENDPOINT}/status"))
            if response.is_a?(Net::HTTPSuccess) and response.body.start_with?('OK')
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
      puts "Notify round #{round_id}, event #{event_name}"
      _send_post("/notify", "#{round_id}/#{event_name}")
    end

    def tell_to_stop
      puts "Stopping recording system"
      _send_post("/stop", "")
    end

    def _send_post(endpoint, body)
      unless @recording_required
        return
      end

      begin
        response = Net::HTTP.post(URI("#{RECORDING_SYSTEM_ENDPOINT}#{endpoint}"), body)

        unless response.is_a?(Net::HTTPSuccess)
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
