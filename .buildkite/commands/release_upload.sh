#!/bin/bash -eu

# Ensure we get the latest commit of the `release/*` branch, especially to get last version bump commit before publishing the GitHub Release and creating the git tag
RELEASE_VERSION="${1:?RELEASE_VERSION parameter missing}"
"$(dirname "${BASH_SOURCE[0]}")/checkout_release_branch.sh" "$RELEASE_VERSION"

echo "--- :arrow_down: Downloading Artifacts"
ARTIFACTS_DIR='.build/artifacts' # Defined in Fastlane, see ARTIFACTS_FOLDER
STEP=testflight_build
buildkite-agent artifact download "$ARTIFACTS_DIR/*.ipa" . --step $STEP
buildkite-agent artifact download "$ARTIFACTS_DIR/*.zip" . --step $STEP

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :testflight: Uploading to TestFlight"
bundle exec fastlane upload_to_app_store_connect

echo "--- :arrow_up: Uploading dSYM to Sentry"
set +e
bundle exec fastlane symbols_upload
SENTRY_UPLOAD_STATUS=$?
set -e

if [[ $SENTRY_UPLOAD_STATUS -ne 0 ]]; then
  echo "^^^ +++ Failed to upload dSYM to Sentry! Make sure to download dSYM from the build step artifacts and upload manually."
  buildkite-agent annotate --style error --context sentry-failure 'Failed to upload dSYM to Sentry! Make sure to download dSYM from the build step artifacts and upload manually.'
fi
