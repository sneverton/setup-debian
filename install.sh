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

declare -A MODULE_DESCRIPTIONS=(
  [base]="Pacotes base de terminal, build, Python e utilitários"
  [shell]="Zsh, Oh My Zsh e plugins"
  [git]="Configuração de Git"
  [node_ai]="Node.js, pnpm e ferramentas de IA"
  [docker]="Docker Engine e Compose plugin"
  [cloud_tools]="GitHub CLI, LazyGit e doctl"
  [dotfiles]="Dotfiles versionados"
)

print_module_menu() {
  local index
  local module

  printf 'Escolha os modulos para instalar.\n' >&2
  printf 'Use numeros ou nomes separados por virgula ou espaco, ou digite all.\n' >&2
  printf 'Opcoes:\n' >&2

  for index in "${!DEFAULT_MODULES[@]}"; do
    module="${DEFAULT_MODULES[$index]}"
    printf '  %d) %s - %s\n' "$((index + 1))" "$module" "${MODULE_DESCRIPTIONS[$module]}" >&2
  done
}

module_is_known() {
  local module="$1"

  [[ -n "${MODULE_DESCRIPTIONS[$module]:-}" ]]
}

parse_module_selection() {
  local selection="$1"
  local -a selected=()
  local -A seen=()
  local token
  local module
  local index

  selection="${selection//,/ }"

  if [[ -z "${selection//[[:space:]]/}" || "$selection" == "all" ]]; then
    printf '%s\n' "${DEFAULT_MODULES[@]}"
    return 0
  fi

  for token in $selection; do
    case "$token" in
      all)
        printf '%s\n' "${DEFAULT_MODULES[@]}"
        return 0
        ;;
      none)
        return 0
        ;;
      '')
        continue
        ;;
      [0-9]*)
        if [[ ! "$token" =~ ^[0-9]+$ ]]; then
          abort "Unknown module selection: $token"
        fi

        index=$((token - 1))
        if (( index < 0 || index >= ${#DEFAULT_MODULES[@]} )); then
          abort "Unknown module selection number: $token"
        fi
        module="${DEFAULT_MODULES[$index]}"
        ;;
      *)
        module="$token"
        ;;
    esac

    if ! module_is_known "$module"; then
      abort "Unknown module: $module"
    fi

    if [[ -z "${seen[$module]:-}" ]]; then
      selected+=("$module")
      seen["$module"]=1
    fi
  done

  if [[ "${#selected[@]}" -eq 0 ]]; then
    return 0
  fi

  printf '%s\n' "${selected[@]}"
}

should_prompt_for_modules() {
  if [[ "${SETUP_DEBIAN_INTERACTIVE:-0}" == "1" ]]; then
    return 0
  fi

  if [[ -t 0 && -t 1 ]]; then
    return 0
  fi

  return 1
}

determine_modules_to_run() {
  local modules_csv="${SETUP_DEBIAN_MODULES:-}"
  local selection

  if [[ -n "$modules_csv" ]]; then
    parse_module_selection "$modules_csv"
    return 0
  fi

  if should_prompt_for_modules; then
    print_module_menu
    if ! read -r -p "Selection [all]: " selection; then
      selection="all"
    fi

    parse_module_selection "${selection:-all}"
    return 0
  fi

  printf '%s\n' "${DEFAULT_MODULES[@]}"
}

run_modules() {
  local module

  while IFS= read -r module; do
    [[ -z "$module" ]] && continue
    log_info "Running module: $module"
    bash "$ROOT_DIR/scripts/${module}.sh"
  done
}

main() {
  require_supported_environment
  determine_modules_to_run | run_modules
  log_info "Setup finished."
}

main "$@"
