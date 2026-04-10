#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"
source "$ROOT_DIR/scripts/cloud_tools.sh"

test_install_release_binary_skips_when_binary_exists() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/lazygit"
#!/usr/bin/env bash
printf 'already installed\n'
EOF
  chmod +x "$fake_bin/lazygit"

  output="$(
    PATH="$fake_bin:$PATH" \
      SETUP_DEBIAN_DRY_RUN=1 \
      install_release_binary "v0.0.0" "https://example.com/archive.tar.gz" "lazygit"
  )"

  assert_contains "$output" "lazygit already installed" "install_release_binary should skip binaries that already exist in PATH"
}

test_install_github_cli_skips_when_gh_exists() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/gh"
#!/usr/bin/env bash
printf 'gh version test\n'
EOF
  chmod +x "$fake_bin/gh"

  output="$(
    PATH="$fake_bin:$PATH" \
      SETUP_DEBIAN_DRY_RUN=1 \
      install_github_cli
  )"

  assert_contains "$output" "GitHub CLI already installed." "install_github_cli should skip installation when gh is already present"
}

test_install_release_binary_skips_when_binary_exists
test_install_github_cli_skips_when_gh_exists
