.PHONY: run

# To see how to drive this makefile use:
#
#   % make help

# SwiftFormat
SWIFTFORMAT_VERSION := $(shell awk '/^--minversion/ { print $$2 }' .swiftformat)

# Derived values (don't change these).
CURRENT_MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
CURRENT_MAKEFILE_DIR := $(patsubst %/,%,$(dir $(CURRENT_MAKEFILE_PATH)))

SCHEME = "GravatarApp"

# If no target is specified, display help
.DEFAULT_GOAL := help

help:  # Display this help.
	@-+echo "Run make with one of the following targets:"
	@-+echo
	@-+grep -Eh "^[a-z-]+:.*#" $(CURRENT_MAKEFILE_PATH) | sed -E 's/^(.*:)(.*#+)(.*)/  \1 @@@ \3 /' | column -t -s "@@@"

dev: # Open the package in xcode
	xed .

test: # Run the app unit tests
	@xcodebuild test -project GravatarApp.xcodeproj -scheme GravatarApp -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

swiftformat: check-docker # Automatically find and fixes lint issues
	@docker run --rm -v $(shell pwd):$(shell pwd) -w $(shell pwd) ghcr.io/nicklockwood/swiftformat:$(SWIFTFORMAT_VERSION) GravatarApp GravatarAppTests Packages

swiftformat-lint: check-docker
	@Docker run --rm -v $(shell pwd):$(shell pwd) -w $(shell pwd) ghcr.io/nicklockwood/swiftformat:$(SWIFTFORMAT_VERSION) GravatarApp GravatarAppTests Packages --lint

lint: # Use swiftformat to warn about format issues
	@make swiftformat-lint

check-docker:
	@command -v docker >/dev/null 2>&1 || { echo "Error: Docker is not installed or not in PATH"; false; }
	@docker info >/dev/null 2>&1 || { echo "Error: Docker is installed but not running or accessible by the current user"; false; }


dump:  # Dump all derived values used by the Makefile.
	@echo "CURRENT_MAKEFILE_PATH = $(CURRENT_MAKEFILE_PATH)"
	@echo "CURRENT_MAKEFILE_DIR = $(CURRENT_MAKEFILE_DIR)"
	@echo "SWIFTFORMAT_VERSION = $(SWIFTFORMAT_VERSION)"
