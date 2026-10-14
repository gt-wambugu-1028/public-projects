#!/usr/bin/env bash
# Run inside the container as 'ubuntu'. Usage: bash dockerfile-tests.sh
pass=0; fail=0
t() {  # t "name" "expected-regex" "command"
  local out first
  out=$(bash -c "$3" 2>&1); first=$(printf '%s' "$out" | head -n1 | cut -c1-90)
  if printf '%s' "$out" | grep -Eq "$2"; then pass=$((pass+1)); printf 'PASS  %-34s %s\n' "$1" "$first"
  else fail=$((fail+1)); printf 'FAIL  %-34s expected /%s/ got: %s\n' "$1" "$2" "$first"; fi
}
cmd() { t "cmd: $1" "^${2//+/\\+}\$" "command -v $1 >/dev/null && echo $2 || echo MISSING"; }

echo "== OS, user, env =="
t "ubuntu version"        '^26\.04$'                     '. /etc/os-release; echo $VERSION_ID'
t "user"                  '^ubuntu$'                     'whoami'
t "home dir"              '^/home/ubuntu$'               'echo $HOME'
t "in sudo group"         '(^| )sudo( |$)'               'id -nG'
t "NOT in docker group"   '^0$'                          'id -nG | tr " " "\n" | grep -c "^docker$"'
t "sudo needs password"   'password is required'         'sudo -n true'
t "UV_PYTHON"             '^/usr/bin/python3$'           'echo $UV_PYTHON'
t "NPM_CONFIG_PREFIX"     '^/home/ubuntu/\.npm-global$'  'echo $NPM_CONFIG_PREFIX'
t "PATH has 3 user dirs"  '^3$'                          'echo $PATH | tr ":" "\n" | sort -u | grep -cE "^/home/ubuntu/(\.npm-global/bin|\.cargo/bin|\.local/bin)$"'

echo "== apt package commands =="
for c in batcat btop gcc g++ make curl docker dust eza fdfind fzf gh git delta jq lazygit less nano \
         node npm patch procs python3 rg shellcheck sudo tmux unzip wget zoxide; do cmd "$c" "$c"; done
t "ca-certificates"       'ca-certificates\.crt'         'ls /etc/ssl/certs/ca-certificates.crt'
t "bash-completion"       'bash_completion'              'ls /usr/share/bash-completion/bash_completion'

echo "== versions =="
t "python 3.14"           '^Python 3\.14\.'              'python3 --version'
t "uv 0.13.0 (pinned)"    '^uv 0\.13\.0'                 'uv --version'
t "uvx"                   '^uvx 0\.13\.0'                'uvx --version'
t "uv finds system py"    '^/usr/bin/python3$'           'uv python find'
t "node 22"               '^v22\.'                       'node --version'
t "npm 9"                 '^9\.'                         'npm --version'
t "pnpm"                  '^[0-9]+\.[0-9]+'              'pnpm --version'
t "docker client"         '^Docker version 29\.'         'docker --version'
t "lazydocker"            '[Vv]ersion'                   'lazydocker --version'

echo "== npm prefix =="
t "npm prefix"            '^/home/ubuntu/\.npm-global$'  'npm config get prefix'
t "pnpm in user prefix"   '^/home/ubuntu/\.npm-global/bin/pnpm$' 'command -v pnpm'

echo "== Python tools (14 tools + graphifyy = 15 expected) =="
t "uv tool count"         '^15$'                         'uv tool list | grep -vc "^-"'
for c in bandit cookiecutter invoke ipython jupyter-lab kernprof mkdocs pipx pre-commit py-spy \
         pyinstaller pytest ruff ty; do cmd "$c" "$c"; done
t "graphifyy installed"   '^graphifyy'                   'uv tool list | grep "^graphifyy"'

echo "== Rust =="
t "rustc"                 '^rustc '                      'rustc --version'
t "cargo"                 '^cargo '                      'cargo --version'
t "rustfmt"               '^rustfmt '                    'rustfmt --version'
t "clippy"                '^clippy '                     'cargo clippy --version'
t "rust-analyzer"         '^rust-analyzer '              'rust-analyzer --version'
t "7 components"          '^7$'                          'rustup component list --installed | wc -l'
t "rust-src present"      '^rust-src'                    'rustup component list --installed | grep rust-src'
t "rust-docs absent"      '^0$'                          'rustup component list --installed | grep -c rust-docs'
t "compile + run"         'Hello, world!'                'd=$(mktemp -d) && cargo new -q $d/hello && cargo run -q --manifest-path $d/hello/Cargo.toml; rm -rf $d'

echo "== Node functional (needs network) =="
t "npm install + require" '^true$'                       'd=$(mktemp -d) && cd $d && npm init -y >/dev/null && npm install --silent is-odd && node -e "console.log(require(\"is-odd\")(3))"; rm -rf $d'
t "pnpm add + require"    '^true$'                       'd=$(mktemp -d) && cd $d && pnpm init >/dev/null && pnpm add is-even >/dev/null && node -e "console.log(require(\"is-even\")(4))"; rm -rf $d'

echo "== Claude Code, codeburn, caveman =="
cmd claude claude; cmd codeburn codeburn
t "claude runs"           '[0-9]+\.[0-9]+'               'claude --version'

echo "== Docker (client only; no daemon expected) =="
t "daemon not running"    'daemon|permission denied|connect' 'docker info'

echo "== Size hygiene =="
t "uv cache < 20 MB"      '^OK$'                         'n=$(du -sm ~/.cache/uv 2>/dev/null | cut -f1); [ "${n:-0}" -lt 20 ] && echo OK || echo "BIG: ${n}M"'
t "npm cache < 10 MB"     '^OK$'                         'n=$(du -sm ~/.npm 2>/dev/null | cut -f1); [ "${n:-0}" -lt 10 ] && echo OK || echo "BIG: ${n}M"'

echo; echo "passed=$pass failed=$fail"
