# Development Container Template

---

A custom development container template with pre-configured tools and settings. Built for use with Zed, but can be adapted for other editors.

## Helpful resources

---

- [Development Containers](https://containers.dev/)
- [Dev Container JSON Reference](https://containers.dev/implementors/json_reference/)
- [Zed Dev Containers](https://zed.dev/docs/dev-containers)
- [Official Dev Container Features](https://github.com/devcontainers/features/tree/main/src)

## Requirements

---

- Docker for Desktop must be installed and running for the development container to work on Windows
- moby set to false for docker-in-docker feature to work on Ubuntu

## Chosen Python tools

---

| Tool | Category | Description |
|---|---|---|
| Bandit | Security | Static scan for common security vulnerabilities |
| Cookiecutter | Scaffolding | Generate project structure from templates |
| Coverage.py | Testing | Measures test coverage |
| Invoke | Task runner | Define and run reusable CLI tasks |
| IPython | REPL | Enhanced interactive Python shell |
| line_profiler | Profiling | Line-by-line profiling for slow functions |
| MkDocs / Sphinx | Docs | Static site generator from Markdown / RST+autodoc |
| mypy / ty | Type checking | Static type checker (mature / fast) |
| pipx | Tool installs | Installs CLI tools in isolated environments |
| pre-commit | Git hooks | Runs checks automatically on commit |
| pytest | Testing | Test runner and framework |
| py-spy | Profiling | Sampling profiler, attaches to running processes |
| PyInstaller | Distribution | Bundles app into standalone executable |
| Ruff | Lint + format | Replaces flake8 + isort + Black in one tool |
| uv | Env + packages | Fast, modern Python/venv/package manager |

## Chosen Rust tools

---

| Tool | Category | Description |
|---|---|---|
| cargo | Build + packages | Build system and package manager |
| clippy | Lint | Collection of lints to catch common mistakes |
| rust-analyzer | Language server | IDE integration, code completion, and diagnostics |
| rust-docs | Docs | Offline copy of the official Rust documentation |
| rustc | Compiler | The Rust compiler |
| rustfmt | Format | Formats code to official Rust style |
| rust-src | Source | Standard library source code (needed by rust-analyzer) |
| rust-std | Standard library | Core types, traits, and APIs for compilation targets |

## Notes

---

- Ubuntu dev container image comes with Git, so no need to install it separately as a feature
- Can specify mutliple postCreateCommands using `;` and `&&`
- Docker Compose files used to run multiple dev container instances in parallel
- `OnCreateCommand` cannot access user-defined assets or secrets, used when caching or prebuilding a container. `postCreateCommand` can access user-defined assets and secrets. Both are executed without a shell.
- `workspaceFolder` sets the default working directory inside the container. `workspaceMount` mounts a host directory into the container, allowing for shared access between the host and container.
- `mounts` can be used to connect additional directories into the container from the host
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

- `overrideFeatureInstallOrder` used to guarantee a specific order of feature installation
- installing `uv` and `pyenv` as Python tools results in an error during feature installation - `pyenv` manages Python versions by compiling from source; `uv` has no concept of it and errors out when the python feature tries to install both via `uv`.
