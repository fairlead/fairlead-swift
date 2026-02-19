.PHONY: build test test-verbose clean fmt lint check

build:
	swift build

test:
	swift test

test-verbose:
	swift test --verbose

clean:
	swift package clean

fmt:
	swift-format format --in-place --recursive Sources Tests

lint:
	swift-format lint --recursive Sources Tests

check: build test
