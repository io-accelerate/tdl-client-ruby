CHALLENGES_FOLDER = 'challenges'
LAST_FETCHED_ROUND_PATH = "#{CHALLENGES_FOLDER}/XR.txt"

require 'tdl/runner/runner_action'

include RunnerActions

module RoundManagement

  def save_description(listener, raw_description, audit_stream)
    return unless raw_description.include? "\n"

    newline_index = raw_description.index("\n")
    round_id = raw_description[0..newline_index - 1]
    listener.on_new_round(round_id, RunnerActions.deploy_to_production.short_name) if round_id != get_last_fetched_round

    display_and_save_description(round_id, raw_description, audit_stream)
  end

  def display_and_save_description(label, description, audit_stream)
    Dir.mkdir(CHALLENGES_FOLDER) unless File.exists?(CHALLENGES_FOLDER)

    output_description = File.open("#{CHALLENGES_FOLDER}/#{label}.txt", 'w')
    output_description << description
    output_description.close
    audit_stream.write_line("Challenge description saved to file: #{output_description.path}.")

    output_last_round = File.open(LAST_FETCHED_ROUND_PATH, 'w')
    output_last_round << label
    output_last_round.close

    'OK'
  end

  def get_last_fetched_round
    begin
      File.read(LAST_FETCHED_ROUND_PATH)
    rescue StandardError => _
      'noRound'
    end
  end

end
