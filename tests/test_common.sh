#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"
source "$ROOT_DIR/scripts/lib/common.sh"

test_backup_and_link_creates_backup_and_symlink() {
  local sandbox
  local home_dir
  local source_file
  local target_file
  local backup_root
  local backup_file

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN

  home_dir="$sandbox/home"
  mkdir -p "$home_dir"

  source_file="$sandbox/source.zshrc"
  target_file="$home_dir/.zshrc"
  backup_root="$sandbox/backups"

  printf 'export TEST=1\n' > "$source_file"
  printf 'legacy\n' > "$target_file"

  backup_and_link "$source_file" "$target_file" "$backup_root"

  backup_file="$backup_root/.zshrc"
  assert_file_exists "$backup_file" "backup_and_link should move the old file into backup storage"
  assert_symlink_target "$target_file" "$source_file" "backup_and_link should replace the target with a symlink"
}

test_command_exists_reports_available_binary() {
  if ! command_exists bash; then
    fail "command_exists should succeed for binaries in PATH"
  fi
}

test_run_command_prints_dry_run_without_execution() {
  local output
  local sandbox
  local marker

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  marker="$sandbox/marker"

  output="$(
    SETUP_LINUX_DRY_RUN=1 \
      run_command "sample step" touch "$marker"
  )"

  assert_contains "$output" "[dry-run] sample step" "run_command should announce dry-run steps"
  if [[ -e "$marker" ]]; then
    fail "run_command should not execute commands when dry-run is enabled"
  fi
}

test_backup_and_link_creates_backup_and_symlink
test_command_exists_reports_available_binary
test_run_command_prints_dry_run_without_execution
