#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

export N_PREFIX="${N_PREFIX:-$HOME/.n}"
export PATH="$N_PREFIX/bin:$PATH"

resolve_node_binary() {
  if [[ -x "$N_PREFIX/bin/node" ]]; then
    printf '%s\n' "$N_PREFIX/bin/node"
    return
  fi

  command -v node
}

resolve_npm_binary() {
  if [[ -x "$N_PREFIX/bin/npm" ]]; then
    printf '%s\n' "$N_PREFIX/bin/npm"
    return
  fi

  command -v npm
}

refresh_runtime_binaries() {
  hash -r 2>/dev/null || true
}

install_n() {
  if command_exists n; then
    log_info "n is already installed."
    return
  fi

  ensure_dir "$N_PREFIX"
  run_command "Installing n into $N_PREFIX" npm install -g --prefix "$N_PREFIX" n
}

install_node_latest_stable() {
  run_command "Installing latest stable Node.js with n" n latest
  refresh_runtime_binaries
}

update_npm_latest_stable() {
  local npm_bin

  npm_bin="$(resolve_npm_binary)"
  run_command "Updating npm to latest stable" "$npm_bin" install -g npm@latest
  refresh_runtime_binaries
}

ensure_node_constraints() {
  local node_major
  local npm_major
  local node_bin
  local npm_bin

  node_bin="$(resolve_node_binary)"
  npm_bin="$(resolve_npm_binary)"

  node_major="$("$node_bin" -p 'process.versions.node.split(".")[0]')"
  npm_major="$("$npm_bin" -v | cut -d. -f1)"

  if (( node_major < 22 )); then
    abort "GitHub Copilot CLI requires Node.js 22 or newer."
  fi

  if (( npm_major < 10 )); then
    abort "GitHub Copilot CLI requires npm 10 or newer."
  fi
}

install_global_npm_package() {
  local package_name="$1"
  local npm_bin

  npm_bin="$(resolve_npm_binary)"

  run_command "Installing ${package_name}" "$npm_bin" install -g "$package_name"
}

main() {
  install_n
  install_node_latest_stable

  if [[ "${SETUP_DEBIAN_DRY_RUN:-0}" != "1" ]]; then
    update_npm_latest_stable
  fi

  if [[ "${SETUP_DEBIAN_DRY_RUN:-0}" != "1" ]]; then
    ensure_node_constraints
  fi

  install_global_npm_package "pnpm"
  install_global_npm_package "@openai/codex"
  install_global_npm_package "@anthropic-ai/claude-code"
  install_global_npm_package "@github/copilot"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
