#!/usr/bin/env bash

set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

main() {
  local docker_repo
  local docker_repo_base
  local repo_codename
  local repo_distro

  repo_distro="$(repo_distro_name)"
  repo_codename="$(detect_os_version_codename)"
  docker_repo_base="https://download.docker.com/linux/${repo_distro}"
  docker_repo="deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] ${docker_repo_base} ${repo_codename} stable"

  if [[ -z "$repo_codename" ]]; then
    abort "Could not determine the distribution codename for Docker repository configuration."
  fi

  run_command "Creating Docker keyring directory" sudo install -m 0755 -d /etc/apt/keyrings
  run_command \
    "Installing Docker GPG key" \
    bash -lc "curl -fsSL ${docker_repo_base}/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg"
  run_command "Fixing Docker key permissions" sudo chmod a+r /etc/apt/keyrings/docker.gpg
  run_command \
    "Configuring Docker apt repository" \
    bash -lc "printf '%s\n' '${docker_repo}' | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null"
  run_command "Updating apt cache" sudo apt-get update
  run_command \
    "Installing Docker engine and plugins" \
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  if ! id "$USER" >/dev/null 2>&1; then
    if is_dry_run; then
      run_command "Adding $USER to docker group" sudo usermod -aG docker "$USER"
      return
    fi

    abort "User $USER does not exist on this system."
  fi

  if id -nG "$USER" | grep -qw docker; then
    log_info "User already belongs to docker group."
    return
  fi

  run_command "Adding $USER to docker group" sudo usermod -aG docker "$USER"
}

main "$@"
