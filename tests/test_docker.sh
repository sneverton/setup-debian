#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"

test_docker_module_uses_ubuntu_repository_on_ubuntu() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  output="$(
    HOME="$sandbox/home" \
      USER="tester" \
      SETUP_LINUX_DRY_RUN=1 \
      SETUP_LINUX_FORCE_OS_ID=ubuntu \
      SETUP_LINUX_FORCE_OS_VERSION_ID=24.04 \
      SETUP_LINUX_FORCE_OS_VERSION_CODENAME=noble \
      bash "$ROOT_DIR/scripts/docker.sh"
  )"

  assert_contains "$output" "https://download.docker.com/linux/ubuntu" "docker.sh should use the Ubuntu Docker repository on Ubuntu"
  assert_contains "$output" "ubuntu noble stable" "docker.sh should resolve the Ubuntu codename before writing the Docker repository"
}

test_docker_module_uses_ubuntu_repository_on_ubuntu
