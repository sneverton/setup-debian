#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"

test_tmux_config_enables_modern_defaults() {
  local config

  config="$(cat "$ROOT_DIR/dotfiles/tmux.conf")"

  assert_contains "$config" "set -g mouse on" "tmux config should keep mouse support enabled"
  assert_contains "$config" "set -g base-index 1" "tmux config should start window numbering at 1"
  assert_contains "$config" "setw -g pane-base-index 1" "tmux config should start pane numbering at 1"
  assert_contains "$config" "setw -g mode-keys vi" "tmux copy mode should use vi keys"
  assert_contains "$config" "set -g prefix C-a" "tmux config should move the prefix to C-a"
  assert_contains "$config" "#{pane_current_path}" "new panes and windows should inherit the current path"
  assert_contains "$config" "bind T new-window -c \"#{pane_current_path}\"" "tmux config should provide an explicit T shortcut for new windows"
  assert_contains "$config" "bind -n PageDown split-window -h -c \"#{pane_current_path}\"" "tmux config should split side by side with PageDown"
  assert_contains "$config" "bind -n PageUp split-window -v -c \"#{pane_current_path}\"" "tmux config should split top-bottom with PageUp"
  assert_contains "$config" "bind -r h select-pane -L" "tmux config should provide vim-style pane navigation"
  assert_contains "$config" "bind -r L resize-pane -R 5" "tmux config should provide pane resizing shortcuts"
}

test_tmux_config_enables_modern_defaults
