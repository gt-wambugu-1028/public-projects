ARG UBUNTU_VERSION=26.04
ARG UV_VERSION=0.13.0

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM ubuntu:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=ubuntu

# Ubuntu packages via apt, skipping recommended extras and deleting apt lists to keep the layer small
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         bash-completion bat btop build-essential ca-certificates curl docker.io \
         du-dust eza fd-find fzf gh git git-delta jq lazygit less nano nodejs npm \
         patch procs python3 ripgrep shellcheck sudo tmux unzip wget zoxide \
    && rm -rf /var/lib/apt/lists/*

# uv, copied from the pinned uv stage above
COPY --from=uv /uv /uvx /usr/local/bin/

# lazydocker: downloads the latest GitHub release binary for this CPU arch (x86_64/arm64) into /usr/local/bin; failure warns and the build continues
RUN case "$(uname -m)" in x86_64) A=x86_64;; aarch64) A=arm64;; *) A=;; esac; \
    tmp="$(mktemp -d)"; \
    { [ -n "$A" ] \
      && tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' https://github.com/jesseduffield/lazydocker/releases/latest)" \
      && tag="${tag##*/}" \
      && case "$tag" in v[0-9]*) true;; *) false;; esac \
      && curl -fsSL -o "$tmp/ld.tar.gz" "https://github.com/jesseduffield/lazydocker/releases/download/${tag}/lazydocker_${tag#v}_Linux_${A}.tar.gz" \
      && tar -xzf "$tmp/ld.tar.gz" -C "$tmp" \
      && install -m 0755 "$tmp/lazydocker" /usr/local/bin/lazydocker; \
    } || echo "WARNING: lazydocker not installed" >&2; \
    rm -rf "$tmp"

# Creates the user if missing and adds it to the sudo group; password deliberately not set here, set it after the container is running
RUN (id "$USERNAME" >/dev/null 2>&1 || useradd -m -s /bin/bash "$USERNAME") \
    && usermod -aG sudo "$USERNAME"

USER ${USERNAME}
WORKDIR /home/${USERNAME}

# User-owned npm global prefix, user tool bin dirs (npm, cargo, uv) added to PATH, and uv pinned to the system python3
ENV NPM_CONFIG_PREFIX="/home/${USERNAME}/.npm-global" \
    PATH="/home/${USERNAME}/.npm-global/bin:/home/${USERNAME}/.cargo/bin:/home/${USERNAME}/.local/bin:${PATH}" \
    UV_PYTHON=/usr/bin/python3

# pnpm, installed globally with npm into the user-owned prefix (no sudo needed); npm cache cleared afterwards
RUN npm install -g pnpm \
    && npm cache clean --force

# Python tools, each installed in its own isolated environment with `uv tool install`; any failure fails the build
RUN for t in bandit cookiecutter invoke ipython jupyterlab line_profiler mkdocs pipx \
             pre-commit py-spy pyinstaller pytest ruff ty; do \
      uv tool install --no-cache "$t" || exit 1; \
    done

# Rust via rustup: stable toolchain, minimal profile (rustc, cargo, rust-std), plus clippy, rust-analyzer, rust-src and rustfmt
RUN curl --proto '=https' --tlsv1.2 -fsS -o /tmp/rustup-init.sh https://sh.rustup.rs \
    && sh /tmp/rustup-init.sh --default-toolchain none -y \
    && rm /tmp/rustup-init.sh \
    && rustup toolchain install stable --profile minimal \
    && rustup default stable \
    && rustup component add clippy rust-analyzer rust-src rustfmt

# Claude Code and codeburn via npm, caveman via its install script, graphifyy via uv tool
RUN npm install -g @anthropic-ai/claude-code codeburn \
    && curl -fsSL -o /tmp/caveman-install.sh https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh \
    && bash /tmp/caveman-install.sh \
    && rm /tmp/caveman-install.sh \
    && npm cache clean --force \
    && uv tool install --no-cache graphifyy
