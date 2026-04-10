#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  apt_install \
    git curl wget build-essential \
    zsh tmux neovim \
    htop unzip zip ripgrep fd-find fzf \
    ca-certificates gnupg lsb-release jq \
    python3 python3-pip python3-venv pipx \
    nodejs npm \
    udisks2
}

main "$@"
