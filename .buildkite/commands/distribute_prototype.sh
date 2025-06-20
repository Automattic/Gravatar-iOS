#!/bin/bash -eu

"$(dirname "${BASH_SOURCE[0]}")/setup_shared.sh"

echo "--- :arrow_down: Downloading Prototype Build"
buildkite-agent artifact download ".build/artifacts/*.ipa" . --step prototype_build
buildkite-agent artifact download ".build/artifacts/*.app.dSYM.zip" . --step prototype_build

echo "--- :firebase: Distributing Prototype Build"
bundle exec fastlane distribute_enterprise
