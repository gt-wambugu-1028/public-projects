#!/bin/bash
set -e

# GitHub CLI
sudo apt install -y gh

# Caveman
curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash

# Graphifyy
uv tool install graphifyy
