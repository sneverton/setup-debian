#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

log_info() {
  printf '[info] %s\n' "$1"
}

log_warn() {
  printf '[warn] %s\n' "$1" >&2
}

log_error() {
  printf '[error] %s\n' "$1" >&2
}

abort() {
  log_error "$1"
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_dry_run() {
  [[ "${SETUP_DEBIAN_DRY_RUN:-0}" == "1" ]]
}

installer_profile() {
  if [[ -n "${SETUP_DEBIAN_PROFILE:-}" ]]; then
    printf '%s\n' "$SETUP_DEBIAN_PROFILE"
    return
  fi

  detect_os_id
}

run_command() {
  local description="$1"
  shift

  if is_dry_run; then
    printf '[dry-run] %s: %s\n' "$description" "$*"
    return 0
  fi

  log_info "$description"
  "$@"
}

ensure_dir() {
  mkdir -p "$1"
}

detect_os_id() {
  if [[ -n "${SETUP_DEBIAN_FORCE_OS_ID:-}" ]]; then
    printf '%s\n' "$SETUP_DEBIAN_FORCE_OS_ID"
    return
  fi

  . /etc/os-release
  printf '%s\n' "$ID"
}

detect_os_version_id() {
  if [[ -n "${SETUP_DEBIAN_FORCE_OS_VERSION_ID:-}" ]]; then
    printf '%s\n' "$SETUP_DEBIAN_FORCE_OS_VERSION_ID"
    return
  fi

  . /etc/os-release
  printf '%s\n' "$VERSION_ID"
}

detect_arch() {
  if [[ -n "${SETUP_DEBIAN_FORCE_ARCH:-}" ]]; then
    printf '%s\n' "$SETUP_DEBIAN_FORCE_ARCH"
    return
  fi

  uname -m
}

repo_distro_name() {
  local os_id

  os_id="$(detect_os_id)"

  case "$os_id" in
    debian|ubuntu)
      printf '%s\n' "$os_id"
      ;;
    *)
      abort "Unsupported operating system for repository configuration: $os_id"
      ;;
  esac
}

require_supported_environment() {
  local arch
  local profile
  local os_id
  local version_id

  arch="$(detect_arch)"
  if [[ "$arch" != "x86_64" && "$arch" != "amd64" ]]; then
    abort "This setup supports x86_64/amd64 only."
  fi

  profile="$(installer_profile)"
  os_id="$(detect_os_id)"
  version_id="$(detect_os_version_id)"

  case "$profile" in
    debian)
      if [[ "$os_id" != "debian" && "${SETUP_DEBIAN_ALLOW_NON_DEBIAN:-0}" != "1" ]]; then
        abort "This setup targets Debian 13 Trixie only."
      fi

      if [[ "$version_id" != "13" ]]; then
        abort "This setup targets Debian 13 Trixie only."
      fi
      ;;
    ubuntu)
      if [[ "$os_id" != "ubuntu" && "${SETUP_DEBIAN_ALLOW_NON_DEBIAN:-0}" != "1" ]]; then
        abort "This setup targets Ubuntu only."
      fi
      ;;
    *)
      abort "Unsupported installer profile: $profile"
      ;;
  esac

  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    abort "Run this installer as a regular user with sudo, not as root."
  fi
}

backup_and_link() {
  local source_path="$1"
  local target_path="$2"
  local backup_root="$3"
  local target_name
  local backup_path

  ensure_dir "$backup_root"
  target_name="$(basename "$target_path")"
  backup_path="$backup_root/$target_name"

  if [[ -L "$target_path" ]]; then
    if [[ "$(readlink "$target_path")" == "$source_path" ]]; then
      return 0
    fi

    rm -f "$target_path"
  elif [[ -e "$target_path" ]]; then
    mv "$target_path" "$backup_path"
  fi

  ln -s "$source_path" "$target_path"
}

apt_install() {
  run_command "Updating apt cache" sudo apt-get update
  run_command "Installing packages" sudo apt-get install -y "$@"
}

fetch_latest_github_tag() {
  local repo="$1"

  curl -fsSL "https://api.github.com/repos/${repo}/releases/latest" | jq -r '.tag_name'
}
