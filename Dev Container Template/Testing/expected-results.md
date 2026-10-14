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
| Env | `UV_PYTHON=/usr/bin/python3`, `NPM_CONFIG_PREFIX=/home/ubuntu/.npm-global`, all three user `bin` dirs on `PATH` (`.npm-global/bin`, `.cargo/bin`, `.local/bin`); duplicates are tolerated (the test de-duplicates). |
| apt commands | All present: `batcat`, `btop`, `gcc`, `g++`, `make`, `curl`, `docker`, `dust`, `eza`, `fdfind`, `fzf`, `gh`, `git`, `delta`, `jq`, `lazygit`, `less`, `nano`, `node`, `npm`, `patch`, `procs`, `python3`, `rg`, `shellcheck`, `sudo`, `tmux`, `unzip`, `wget`, `zoxide`. Also `/etc/ssl/certs/ca-certificates.crt` and bash-completion file. |
| Versions | Python 3.14.x, `uv 0.13.0`, `uvx 0.13.0`, `uv python find` = `/usr/bin/python3`, node v22.x, npm 9.x, pnpm any, Docker 29.x. |
| npm prefix | `npm config get prefix` = `/home/ubuntu/.npm-global`; `pnpm` under `/home/ubuntu/.npm-global/bin`. |
| Python tools | `uv tool list` has 15 entries (14 tools plus `graphifyy`). Commands present: `bandit`, `cookiecutter`, `invoke`, `ipython`, `jupyter-lab`, `kernprof`, `mkdocs`, `pipx`, `pre-commit`, `py-spy`, `pyinstaller`, `pytest`, `ruff`, `ty`. |
| Rust | `rustc`, `cargo`, `rustfmt`, `cargo clippy`, `rust-analyzer` all report versions. 7 components: `cargo`, `clippy`, `rust-analyzer`, `rust-src`, `rustc`, `rust-std`, `rustfmt`. `rust-docs` absent. `cargo run` prints `Hello, world!`. |
| Node functional | `npm install is-odd` and `pnpm add is-even` both work; each test prints `true` (needs network). |
| Claude Code, graphifyy, codeburn | `claude` and `codeburn` on `PATH`; `claude --version` prints a version; `graphifyy` appears in `uv tool list`. |
| Size | `~/.cache/uv` under 20 MB, `~/.npm` under 10 MB. |

Final line of the script output should read `passed=<n> failed=0`.

## Last run (14 Oct 2026)

83 passed, 2 failed on the first run (85 tests). Both failures were test errors, now fixed in the script (`uv tool count` expects 15; the `PATH` check de-duplicates). The Docker daemon test has since been deleted, so expect `passed=84 failed=0` on the next run (not yet run).

Observed versions: Python 3.14.4, uv 0.13.0, Node v22.22.1, npm 9.2.0, pnpm 12.11.2, Docker 29.1.3, lazydocker 0.25.2, rustc 1.99.0, Claude Code 2.1.299, graphifyy v0.9.90.

## Caveats

**Not tested:**

- caveman (unknown what it leaves behind).
- Docker daemon behaviour: the Dockerfile installs only the client and does not start `dockerd`. The only Docker check is `docker --version`.
- Password set-up: after `docker exec -it -u root <container> passwd ubuntu`, check `sudo whoami` prints `root` by hand.

Line endings: save the script with LF endings. CRLF breaks the `\` line continuations (`sed -i 's/\r$//' dockerfile-tests.sh` fixes it).
