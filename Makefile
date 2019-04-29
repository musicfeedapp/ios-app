build:
	fastlane sim_debug
.PHONY: build

debug: build
	ios-sim launch /tmp/Debug-iphonesimulator/Musicfeed\ Plus.app
.PHONY: debug
