#!/bin/bash

SCRIPT_FOLDER="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION_FILE="${SCRIPT_FOLDER}/lib/tdl/previous_version.rb"
TMP_VERSION_FILE="${SCRIPT_FOLDER}/out/versions.txt"


function gemspec_property() {
    local property=$1
    cat ${TMP_VERSION_FILE} | grep ${property} | cut -d "=" -f2 | tr -d " "
}

echo "Reading gemspec properties. This might take some time."

# Previous
ruby <<-EOS | tee ${TMP_VERSION_FILE}
require "rubygems"
spec = Gem::Specification::load("tdl-client-ruby.gemspec")
puts "PREVIOUS_VERSION = #{spec.metadata['previous_version']}"
puts "CURRENT_VERSION = #{spec.version}"
EOS
PREVIOUS_VERSION=`gemspec_property PREVIOUS_VERSION`
CURRENT_VERSION=`gemspec_property CURRENT_VERSION`


# Prompt for version confirmation
read -p "Going to release version ${CURRENT_VERSION} (previous ${PREVIOUS_VERSION}). Proceed ? [y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Aborting."
    exit
fi

# Release current version
git tag -a "v${CURRENT_VERSION}" -m "Release ${CURRENT_VERSION}"
git push origin "v${CURRENT_VERSION}"
echo "Pushed tag to Git origin. It will now trigger the deployment pipeline."

cat > "${VERSION_FILE}" <<-EOF
module TDL
  PREVIOUS_VERSION = '$CURRENT_VERSION'
  # the current MAJOR.MINOR version is dynamically computed from the version of the Spec
end
EOF