#!/bin/bash -eu

"$(dirname "${BASH_SOURCE[0]}")/setup_for_building_app.sh"

echo "--- :xcode: Building Prototype Build"
bundle exec fastlane build_prototype

# We'll let Buildkite upload the artifacts to S3
