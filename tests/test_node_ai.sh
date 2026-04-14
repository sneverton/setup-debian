#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT_DIR/tests/lib/assert.sh"
source "$ROOT_DIR/scripts/node_ai.sh"

test_resolve_npm_binary_prefers_n_prefix() {
  local sandbox
  local fake_path
  local n_bin
  local resolved

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_path="$sandbox/path-bin"
  n_bin="$sandbox/.n/bin"
  mkdir -p "$fake_path" "$n_bin"

  printf '#!/usr/bin/env bash\n' > "$fake_path/npm"
  printf 'printf "/usr/bin/npm\\n"\n' >> "$fake_path/npm"
  chmod +x "$fake_path/npm"

  printf '#!/usr/bin/env bash\n' > "$n_bin/npm"
  printf 'printf "n-prefix npm\\n"\n' >> "$n_bin/npm"
  chmod +x "$n_bin/npm"

  resolved="$(
    PATH="$fake_path:$PATH" \
      N_PREFIX="$sandbox/.n" \
      resolve_npm_binary
  )"

  assert_eq "$resolved" "$n_bin/npm" "resolve_npm_binary should prefer the npm installed under N_PREFIX"
}

test_install_node_latest_stable_uses_latest_alias() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/n"
#!/usr/bin/env bash
printf '/usr/bin/n\n'
EOF
  chmod +x "$fake_bin/n"

  output="$(
    PATH="$fake_bin" \
      SETUP_LINUX_DRY_RUN=1 \
      N_PREFIX="$sandbox/.n" \
      install_node_latest_stable
  )"

  assert_contains "$output" "n latest" "install_node_latest_stable should request the latest stable Node.js release"
}

test_install_global_npm_package_skips_existing_binary() {
  local sandbox
  local fake_bin
  local output

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_bin="$sandbox/bin"
  mkdir -p "$fake_bin"

  cat <<'EOF' > "$fake_bin/codex"
#!/usr/bin/env bash
printf 'codex already present\n'
EOF
  chmod +x "$fake_bin/codex"

  output="$(
    PATH="$fake_bin:$PATH" \
      SETUP_LINUX_DRY_RUN=1 \
      install_global_npm_package "@openai/codex" "codex"
  )"

  assert_contains "$output" "codex already installed." "install_global_npm_package should skip packages whose binary is already available"
}

test_ensure_node_constraints_uses_n_prefix_runtime() {
  local sandbox
  local fake_path
  local n_bin

  sandbox="$(mktemp -d)"
  trap 'rm -rf "$sandbox"' RETURN
  fake_path="$sandbox/path-bin"
  n_bin="$sandbox/.n/bin"
  mkdir -p "$fake_path" "$n_bin"

  cat <<'EOF' > "$fake_path/node"
#!/usr/bin/env bash
printf 'v18.0.0\n'
EOF
  chmod +x "$fake_path/node"

  cat <<'EOF' > "$fake_path/npm"
#!/usr/bin/env bash
printf '9.0.0\n'
EOF
  chmod +x "$fake_path/npm"

  cat <<'EOF' > "$n_bin/node"
#!/usr/bin/env bash
if [[ "$1" == "-p" ]]; then
  printf '24\n'
else
  printf 'v24.0.0\n'
fi
EOF
  chmod +x "$n_bin/node"

  cat <<'EOF' > "$n_bin/npm"
#!/usr/bin/env bash
printf '11.0.0\n'
EOF
  chmod +x "$n_bin/npm"

  PATH="$fake_path:$PATH" \
    N_PREFIX="$sandbox/.n" \
    ensure_node_constraints
}

test_resolve_npm_binary_prefers_n_prefix
test_install_node_latest_stable_uses_latest_alias
test_install_global_npm_package_skips_existing_binary
test_ensure_node_constraints_uses_n_prefix_runtime
