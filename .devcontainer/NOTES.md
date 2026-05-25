# Helpful resources

- Development Containers(https://containers.dev/)
- Dev Container JSON Reference(https://containers.dev/implementors/json_reference/)
- Zed Dev Containers(https://zed.dev/docs/dev-containers)
- Official Dev Container Features(https://github.com/devcontainers/features/tree/main/src)

# Requirements

- Docker Desktop must be installed and running for the dev container to work
- moby set to false for Ubuntu images

# Notes

- Can specify mutliple postCreateCommands using ; and &&
- Docker Compose file used to run multiple containers

# Questions

1. Which Python tools should I use?
2. Which Rust components should I specify?
3. OnCreateCommand vs postCreateCommand?
4. workspaceMount and workspaceFolder
5. Ports
6. PostCreateCommands:
   - Install npm
   - Install Claude Code CLI
   - Install ubuntu packages
7. PostStartCommand:
   - Update package lists
   - sudo service start
