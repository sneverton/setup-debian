#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/common.sh"

readonly DEFAULT_MODULES=(
  base
  shell
  git
  node_ai
  docker
  cloud_tools
  dotfiles
)

parse_modules() {
  local modules_csv="${SETUP_DEBIAN_MODULES:-}"

  if [[ -z "$modules_csv" ]]; then
    printf '%s\n' "${DEFAULT_MODULES[@]}"
    return
  fi

  tr ',' '\n' <<<"$modules_csv"
}

main() {
  local module

  require_supported_environment

  while IFS= read -r module; do
    [[ -z "$module" ]] && continue
    log_info "Running module: $module"
    bash "$ROOT_DIR/scripts/${module}.sh"
  done < <(parse_modules)

  log_info "Setup finished."
}

main "$@"
