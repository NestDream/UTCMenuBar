#!/bin/bash
# Runs the custom test runner. Tests use fatalError on failure (no XCTest).
# Exit code 0 = all passed; non-zero = at least one fatalError fired.
set -euo pipefail
cd "$(dirname "$0")/.."
swift run UTCMenuBarTests
