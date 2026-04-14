#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"

test_base_module_installs_udisks2() {
  local output

  output="$(
    SETUP_LINUX_DRY_RUN=1 \
      bash "$ROOT_DIR/scripts/base.sh"
  )"

  assert_contains "$output" "udisks2" "base module should install udisks2"
}

test_base_module_installs_udisks2
