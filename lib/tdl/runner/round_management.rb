CHALLENGES_FOLDER = 'challenges'
LAST_FETCHED_ROUND_PATH = "#{CHALLENGES_FOLDER}/XR.txt"

require 'tdl/runner/runner_action'

include RunnerActions

module RoundManagement

  def save_description(listener, raw_description, audit_stream, working_directory)
    return unless raw_description.include? "\n"

    newline_index = raw_description.index("\n")
    round_id = raw_description[0..newline_index - 1]
    listener.on_new_round(round_id, RunnerActions.deploy_to_production.short_name) if round_id != get_last_fetched_round(working_directory)

    display_and_save_description(round_id, raw_description, audit_stream, working_directory)
  end

  def display_and_save_description(label, description, audit_stream, working_directory)
    Dir.mkdir(File.join(working_directory, CHALLENGES_FOLDER)) unless File.exists?(File.join(working_directory, CHALLENGES_FOLDER))

    output_description = File.open("#{working_directory}/#{CHALLENGES_FOLDER}/#{label}.txt", 'w')
    output_description << description
    output_description.close
    audit_stream.write_line("Challenge description saved to file: #{output_description.path}.")

    output_last_round = File.open(File.join(working_directory, LAST_FETCHED_ROUND_PATH), 'w')
    output_last_round << label
    output_last_round.close

    'OK'
  end

  def get_last_fetched_round(working_directory)
    begin
      File.read(File.join(working_directory, LAST_FETCHED_ROUND_PATH))
    rescue StandardError => _
      'noRound'
    end
  end

end
