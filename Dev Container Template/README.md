# Development Container Template

A custom development container template with pre-configured tools and settings. Built for use with Zed, but can be adapted for other editors.

**Edit**: The original dev container, built from a prebuilt Ubuntu dev container image plus official dev container features, stopped working unexpectedly. I replaced it with a custom Dockerfile that gives me:

- Control over the Ubuntu version (`UBUNTU_VERSION`, currently 26.04) and the `uv` version (`UV_VERSION`, currently 0.13.0), both pinned as build args
- Explicit control of every installed package and tool, listed in the sections below, instead of whatever the image and features bundle
- No dependency on dev container features, so one less layer of third-party install scripts to break

Some tools are still fetched at build time and are not pinned: `lazydocker`, Rust (`stable`), npm and `uv` tools, and the Claude Code and caveman installers. A failed `lazydocker` download only warns; other failures fail the build.

## Helpful resources

- [Development Containers](https://containers.dev/)
- [Dev Container JSON Reference](https://containers.dev/implementors/json_reference/)
- [Zed Dev Containers](https://zed.dev/docs/dev-containers)
- [Official Dev Container Features](https://github.com/devcontainers/features/tree/main/src)

## Requirements

- Docker Desktop must be installed and running for the development container to work on Windows
- To mount files from the host into the container, they must be added to Docker Desktop as a file sharing directory (Settings > Resources > File Sharing)
- Set the container user's password after the container is running, from a host terminal outside the container. Without it, `sudo` does not work.
  - **Not in the Dockerfile:** passwords in `RUN`/`ARG`/`ENV` end up in image layers (`docker history`) and in the repo, shared by every container. Leaving it out keeps the secret out of both.
  - **Outside the container:** `passwd` asks for a current password that does not exist, and `sudo passwd` needs the password being set. Root via `docker exec` avoids the loop.
  - Find the container: `docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"`
  - Set the password: `docker exec -it -u root <container-id-or-name> passwd ubuntu` (use your `USERNAME` if changed)
  - Recreating the container resets the password.

## Chosen Ubuntu packages

| Package | Category | Description |
|---|---|---|
| bash-completion | Shell | Tab completion for bash commands |
| bat | File viewer | `cat` clone with syntax highlighting |
| btop | Monitoring | Interactive resource monitor |
| build-essential | Build | gcc, g++, make and related build tools |
| ca-certificates | Security | Trusted CA certificates for TLS |
| curl | Networking | Transfer data via URLs |
| docker.io | Containers | Docker engine and CLI |
| du-dust | Disk usage | Visual `du` replacement |
| eza | File listing | Modern `ls` replacement |
| fd-find | Search | Fast, friendly `find` alternative |
| fzf | Search | Fuzzy finder for the command line |
| gh | Git | GitHub CLI |
| git | Git | Version control |
| git-delta | Git | Syntax-highlighting pager for diffs |
| jq | Data | JSON processor |
| lazydocker | Containers | Terminal UI for Docker (installed from GitHub releases, not apt) |
| lazygit | Git | Terminal UI for git |
| less | Pager | Page through text output |
| nano | Editor | Simple terminal text editor |
| nodejs / npm | JavaScript | Node.js runtime and package manager |
| patch | Utilities | Apply diff files to sources |
| procs | Monitoring | Modern `ps` replacement |
| python3 | Python | System Python interpreter (`UV_PYTHON` points here) |
| ripgrep | Search | Fast recursive text search |
| shellcheck | Lint | Static analysis for shell scripts |
| sudo | Admin | Run commands as another user |
| tmux | Terminal | Terminal multiplexer |
| unzip | Archives | Extract zip files |
| wget | Networking | Download files over HTTP/FTP |
| zoxide | Navigation | Smarter `cd` that learns frequent directories |

## Chosen Python tools

| Tool | Category | Description |
|---|---|---|
| Bandit | Security | Static scan for common security vulnerabilities |
| Cookiecutter | Scaffolding | Generate project structure from templates |
| graphifyy | Knowledge graph | Turns code, docs and media into a queryable knowledge graph for AI assistants |
| Invoke | Task runner | Define and run reusable CLI tasks |
| IPython | REPL | Enhanced interactive Python shell |
| JupyterLab | Notebooks | Browser-based notebook and code environment |
| line_profiler | Profiling | Line-by-line profiling for slow functions |
| MkDocs | Docs | Static site generator from Markdown |
| pipx | Tool installs | Installs CLI tools in isolated environments |
| pre-commit | Git hooks | Runs checks automatically on commit |
| py-spy | Profiling | Sampling profiler, attaches to running processes |
| PyInstaller | Distribution | Bundles app into standalone executable |
| pytest | Testing | Test runner and framework |
| Ruff | Lint + format | Replaces flake8 + isort + Black in one tool |
| ty | Type checking | Fast static type checker |
| uv | Env + packages | Fast, modern Python/venv/package manager |

## Chosen Rust tools

| Tool | Category | Description |
|---|---|---|
| cargo | Build + packages | Build system and package manager |
| clippy | Lint | Collection of lints to catch common mistakes |
| rust-analyzer | Language server | IDE integration, code completion, and diagnostics |
| rustc | Compiler | The Rust compiler |
| rustfmt | Format | Formats code to official Rust style |
| rustup | Toolchain manager | Installs and manages Rust toolchains and components |
| rust-src | Source | Standard library source code (needed by rust-analyzer) |
| rust-std | Standard library | Core types, traits, and APIs for compilation targets |

## Testing

`Testing/dockerfile-tests.sh` checks the built container against the Dockerfile: OS, user, env, apt commands, pinned versions, Python and Rust tools, Node installs, Claude tooling and cache sizes. `Testing/expected-results.md` lists what each area should report. Run the steps below inside the container as `ubuntu`.

1. The script can arrive in the container with CRLF line endings even if saved as LF on the host, and CRLF breaks the `\` line continuations. Check with `grep -c $'\r' ./Testing/dockerfile-tests.sh` - a count higher than 0 confirms CRLF.
2. If CRLF is present, use `sed -i 's/\r$//' ./Testing/dockerfile-tests.sh` to strip the `\r` from every line, in place.
3. Run the testing script with bash so a CRLF shebang line can't interfere: `bash ./Testing/dockerfile-tests.sh`. If the folder isn't mounted, copy the script in first with `docker cp Testing/dockerfile-tests.sh <container>:/tmp/dockerfile-tests.sh` and run it from `/tmp`.
4. The last line should read `passed=<n> failed=0`.

**Note**: Tests were valid as of 14 Oct 2026. This may change depending on future product updates. Some tests need network access. Not covered: caveman, Docker daemon behaviour, and password set-up (after setting it, check `sudo whoami` prints `root`).

## Notes

- You can specify multiple postCreateCommands using `;` and `&&`
- Docker Compose files are used to run multiple dev container instances in parallel
- `onCreateCommand` cannot access user-defined assets or secrets and is used when caching or prebuilding a container. `postCreateCommand` can access user-defined assets and secrets. Both are executed without a shell.
- `workspaceFolder` sets the default working directory inside the container. `workspaceMount` mounts a host directory into the container, allowing for shared access between the host and container.
- `mounts` can be used to connect additional directories into the container from the host
- `lazydocker` is not in the Ubuntu repositories, so it is installed separately from GitHub releases. The `RUN` block picks the binary for the CPU architecture, resolves the latest release tag, downloads and installs it to `/usr/local/bin`, and only warns if any step fails.
- The `ENV` block is critical because it gives npm a user-owned global prefix and puts the npm, cargo and uv bin directories on `PATH`, so non-root installs work without `sudo` and the installed tools can be found.
- `--no-cache` is the default for `uv tool install` (and the npm cache is cleaned) so download caches are not stored in the image layers, keeping the image smaller.

### Previous setup

Notes from the original image-and-features setup, kept for reference.

- Ubuntu dev container image comes with Git, so no need to install it separately as a feature
- `FeatureOptions` must either be a string or boolean, e.g.

```json
"features": {
    "ghcr.io/devcontainers/features/common-utils": {
        "installZsh": true,
        "installOhMyZsh": true,
        "ohMyZshTheme": "robbyrussell",
        "username": ""
    }
}
```

- `overrideFeatureInstallOrder` is used to guarantee a specific order of feature installation
- Installing `uv` and `pyenv` as Python tools results in an error during feature installation - `pyenv` manages Python versions by compiling from source; `uv` has no concept of it and errors out when the Python feature tries to install both via `uv`.
