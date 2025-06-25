#!/bin/bash -eu

"$(dirname "${BASH_SOURCE[0]}")/setup_shared.sh"

echo "--- :swift: Installing Swift Package Manager Dependencies"
install_swiftpm_dependencies

echo "--- :hammer: Set up repo"
make setup
