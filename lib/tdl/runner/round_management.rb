CHALLENGES_FOLDER = 'challenges'
LAST_FETCHED_ROUND_PATH = "#{CHALLENGES_FOLDER}/XR.txt"

module RoundManagement

  def save_description(raw_description, callback)
    return unless raw_description.include? "\n"

    newline_index = raw_description.index("\n")
    round_id = raw_description[0..newline_index - 1]
    callback.call(round_id) if round_id != get_last_fetched_round

    display_and_save_description(round_id, raw_description)
  end

  def display_and_save_description(label, description)
    puts "Starting round: #{label}"

    output_description = File.open("#{CHALLENGES_FOLDER}/#{label}.txt", 'w')
    output_description << description
    output_description.close
    puts "Challenge description saved to file: #{output_description.path}"

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
