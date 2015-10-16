module TDL
  PREVIOUS_VERSION = '0.1.2'
  # the current MAJOR.MINOR version is dynamically computed from the version of the Spec
  CURRENT_PATCH_VERSION = '3'

  def TDL.version
    spec_folder = File.expand_path('../../../features/spec',__FILE__).to_s
    # puts "Spec folder is: #{spec_folder}"
    major_minor_version = `git --git-dir #{spec_folder}/.git describe --all | cut -d '/' -f 2 | tr -d 'v'`.strip
    "#{major_minor_version}.#{TDL::CURRENT_PATCH_VERSION}"
  end
end
