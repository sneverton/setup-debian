#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"

test_install_runs_requested_modules_in_dry_run_mode() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  output="$(
    HOME="$sandbox/home" \
      USER="tester" \
      SETUP_DEBIAN_DRY_RUN=1 \
      SETUP_DEBIAN_ALLOW_NON_DEBIAN=1 \
      SETUP_DEBIAN_FORCE_ARCH=x86_64 \
      SETUP_DEBIAN_FORCE_OS_ID=debian \
      SETUP_DEBIAN_FORCE_OS_VERSION_ID=13 \
      SETUP_DEBIAN_MODULES=base,dotfiles \
      bash "$ROOT_DIR/install.sh"
  )"

  assert_contains "$output" "Running module: base" "install.sh should execute the base module when requested"
  assert_contains "$output" "Running module: dotfiles" "install.sh should execute the dotfiles module when requested"
  assert_contains "$output" "Setup finished." "install.sh should print a completion message"
}

test_install_runs_full_dry_run_without_system_dependencies() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  output="$(
    HOME="$sandbox/home" \
      USER="tester" \
      SETUP_DEBIAN_DRY_RUN=1 \
      SETUP_DEBIAN_ALLOW_NON_DEBIAN=1 \
      SETUP_DEBIAN_FORCE_ARCH=x86_64 \
      SETUP_DEBIAN_FORCE_OS_ID=debian \
      SETUP_DEBIAN_FORCE_OS_VERSION_ID=13 \
      bash "$ROOT_DIR/install.sh"
  )"

  assert_contains "$output" "Running module: shell" "install.sh should include the shell module in the default run"
  assert_contains "$output" "Running module: node_ai" "install.sh should include the Node and AI tooling module in the default run"
  assert_contains "$output" "Running module: cloud_tools" "install.sh should include the cloud tools module in the default run"
  if [[ "$output" == *"Running module: auth"* ]]; then
    fail "install.sh should not run interactive login steps as part of setup"
  fi
  assert_contains "$output" "Setup finished." "install.sh should finish during a full dry-run"
}

test_install_auto_detects_ubuntu_and_runs_requested_modules_in_dry_run_mode() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  output="$(
    HOME="$sandbox/home" \
      USER="tester" \
      SETUP_DEBIAN_DRY_RUN=1 \
      SETUP_DEBIAN_FORCE_ARCH=x86_64 \
      SETUP_DEBIAN_FORCE_OS_ID=ubuntu \
      SETUP_DEBIAN_FORCE_OS_VERSION_ID=24.04 \
      SETUP_DEBIAN_MODULES=base,shell \
      bash "$ROOT_DIR/install.sh"
  )"

  assert_contains "$output" "Running module: base" "install.sh should execute the base module when requested on Ubuntu"
  assert_contains "$output" "Running module: shell" "install.sh should execute the shell module when requested on Ubuntu"
  assert_contains "$output" "Setup finished." "install.sh should print a completion message on Ubuntu"
}

test_install_prompts_for_multiple_modules_interactively() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  output="$(
    printf '2,5\n' | \
      HOME="$sandbox/home" \
        USER="tester" \
        SETUP_DEBIAN_DRY_RUN=1 \
        SETUP_DEBIAN_INTERACTIVE=1 \
        SETUP_DEBIAN_FORCE_ARCH=x86_64 \
        SETUP_DEBIAN_FORCE_OS_ID=ubuntu \
        SETUP_DEBIAN_FORCE_OS_VERSION_ID=24.04 \
        bash "$ROOT_DIR/install.sh"
  )"

  assert_contains "$output" "Running module: shell" "interactive selection should include the second module"
  assert_contains "$output" "Running module: docker" "interactive selection should include the fifth module"
  assert_contains "$output" "Setup finished." "interactive selection should finish cleanly"
}

test_install_fails_for_unsupported_debian_release() {
  local output

  set +e
  output="$(
    HOME="$(mktemp -d)" \
      USER="tester" \
      SETUP_DEBIAN_DRY_RUN=1 \
      SETUP_DEBIAN_ALLOW_NON_DEBIAN=1 \
      SETUP_DEBIAN_FORCE_ARCH=x86_64 \
      SETUP_DEBIAN_FORCE_OS_ID=debian \
      SETUP_DEBIAN_FORCE_OS_VERSION_ID=12 \
      bash "$ROOT_DIR/install.sh" 2>&1
  )"
  status=$?
  set -e

  if [[ $status -eq 0 ]]; then
    fail "install.sh should reject unsupported Debian releases"
  fi

  assert_contains "$output" "Debian 13" "install.sh should explain the supported Debian version"
}

test_install_runs_requested_modules_in_dry_run_mode
test_install_runs_full_dry_run_without_system_dependencies
test_install_auto_detects_ubuntu_and_runs_requested_modules_in_dry_run_mode
test_install_prompts_for_multiple_modules_interactively
test_install_fails_for_unsupported_debian_release
