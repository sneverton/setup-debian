#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  local timestamp
  local backup_root

  timestamp="$(date +%Y%m%d-%H%M%S)"
  backup_root="${SETUP_LINUX_BACKUP_ROOT:-$HOME/.setup-linux-backups/$timestamp}"

  ensure_dir "$HOME/.config/nvim"

  if [[ "${SETUP_LINUX_DRY_RUN:-0}" == "1" ]]; then
    printf '[dry-run] Linking dotfiles into %s\n' "$HOME"
    return
  fi

  backup_and_link "$REPO_ROOT/dotfiles/zshrc" "$HOME/.zshrc" "$backup_root"
  backup_and_link "$REPO_ROOT/dotfiles/tmux.conf" "$HOME/.tmux.conf" "$backup_root"
  backup_and_link "$REPO_ROOT/dotfiles/gitconfig" "$HOME/.gitconfig" "$backup_root"
  backup_and_link "$REPO_ROOT/dotfiles/nvim/init.lua" "$HOME/.config/nvim/init.lua" "$backup_root"
}

main "$@"
