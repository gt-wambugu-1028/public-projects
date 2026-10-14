# Dockerfile test: expected results

Run `dockerfile-tests.sh` inside the container as `ubuntu`.

```powershell
docker cp dockerfile-tests.sh devbox-test:/tmp/dockerfile-tests.sh
docker exec -it devbox-test bash /tmp/dockerfile-tests.sh
```

## Expected results

| Area | Expected |
|---|---|
| OS and user | `26.04`, user `ubuntu`, home `/home/ubuntu`, in group `sudo`, not in `docker`. `sudo -n true` prints `a password is required`. |
| Env | `UV_PYTHON=/usr/bin/python3`, `NPM_CONFIG_PREFIX=/home/ubuntu/.npm-global`, all three user `bin` dirs on `PATH` (`.npm-global/bin`, `.cargo/bin`, `.local/bin`). |
| apt commands | All present: `batcat`, `btop`, `gcc`, `g++`, `make`, `curl`, `docker`, `dust`, `eza`, `fdfind`, `fzf`, `gh`, `git`, `delta`, `jq`, `lazygit`, `less`, `nano`, `node`, `npm`, `patch`, `procs`, `python3`, `rg`, `shellcheck`, `sudo`, `tmux`, `unzip`, `wget`, `zoxide`. Also `/etc/ssl/certs/ca-certificates.crt` and bash-completion file. |
| Versions | Python 3.14.x, `uv 0.13.0`, `uvx 0.13.0`, `uv python find` = `/usr/bin/python3`, node v22.x, npm 9.x, pnpm any, Docker 29.x. |
| npm prefix | `npm config get prefix` = `/home/ubuntu/.npm-global`; `pnpm` under `/home/ubuntu/.npm-global/bin`. |
| Python tools | `uv tool list` has 14 entries (13 tools plus `graphifyy`). Commands present: `bandit`, `cookiecutter`, `invoke`, `ipython`, `jupyter-lab`, `kernprof`, `mkdocs`, `pipx`, `pre-commit`, `py-spy`, `pyinstaller`, `pytest`, `ruff`, `ty`. |
| Rust | `rustc`, `cargo`, `rustfmt`, `cargo clippy`, `rust-analyzer` all report versions. 7 components: `cargo`, `clippy`, `rust-analyzer`, `rust-src`, `rustc`, `rust-std`, `rustfmt`. `rust-docs` absent. `cargo run` prints `Hello, world!`. |
| Node functional | `npm install is-odd` and `pnpm add is-even` both work; each test prints `true` (needs network). |
| Claude tooling | `claude` and `codeburn` on `PATH`; `claude --version` prints a version. |
| Docker | Client works. `docker info` fails to reach a daemon (the Dockerfile does not start `dockerd`). |
| Size | `~/.cache/uv` under 20 MB, `~/.npm` under 10 MB. |

Final line of the script output should read `passed=<n> failed=0`.

## Caveats

**Unverified expectations** (a FAIL on one of these may be a wrong test, not a wrong image):

- Command names `kernprof`, `jupyter-lab`, `codeburn`.
- Output formats of `lazydocker --version` and `claude --version`.
- The `graphifyy` line in `uv tool list`.
- One output line per component in `rustup component list --installed`.

**Not tested:**

- caveman (unknown what it leaves behind).
- Docker daemon behaviour.
- Password set-up: after `docker exec -it -u root <container> passwd ubuntu`, check `sudo whoami` prints `root` by hand.

The script was syntax-checked and its PASS/FAIL logic exercised in a sandbox. It has not run against the image.
