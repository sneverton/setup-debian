#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"
source "$ROOT_DIR/scripts/shell.sh"

test_install_zsh_plugin_targets_oh_my_zsh_custom_directory() {
  local sandbox
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  mkdir -p "$sandbox/home/.oh-my-zsh"

  output="$(
    HOME="$sandbox/home" \
      SETUP_LINUX_DRY_RUN=1 \
      install_zsh_plugin "zsh-users/zsh-autosuggestions"
  )"

  assert_contains "$output" ".oh-my-zsh/custom/plugins/zsh-autosuggestions" "install_zsh_plugin should clone into the Oh My Zsh custom plugins directory"
}

test_set_default_shell_uses_privileged_account_update() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/getent"
#!/usr/bin/env bash
printf 'tester:x:1000:1000:Tester:/home/tester:/bin/bash\n'
EOF
  chmod +x "$fake_bin/getent"

  output="$(
    PATH="$fake_bin:$PATH" \
      USER="tester" \
      SHELL="/bin/bash" \
      SETUP_LINUX_DRY_RUN=1 \
      set_default_shell
  )"

  assert_contains "$output" "sudo usermod --shell" "set_default_shell should use a privileged non-interactive account update"
}

test_set_default_shell_skips_when_login_shell_is_already_zsh() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/getent"
#!/usr/bin/env bash
printf 'tester:x:1000:1000:Tester:/home/tester:/usr/bin/zsh\n'
EOF
  chmod +x "$fake_bin/getent"

  output="$(
    PATH="$fake_bin:$PATH" \
      USER="tester" \
      SHELL="/bin/bash" \
      SETUP_LINUX_DRY_RUN=1 \
      set_default_shell
  )"

  assert_contains "$output" "Default shell already set to zsh." "set_default_shell should inspect the login shell, not only SHELL env"
}

test_install_zsh_plugin_targets_oh_my_zsh_custom_directory
test_set_default_shell_uses_privileged_account_update
test_set_default_shell_skips_when_login_shell_is_already_zsh
