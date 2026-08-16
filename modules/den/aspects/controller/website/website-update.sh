#!/usr/bin/env bash

# Required for Nix v3 CLI use
export NIX_CONFIG="experimental-features = nix-command flakes"
cd /var/lib/caddy/www.richtman.au
echo "In $(pwd)"
echo "Starting git fetch"
git fetch --all
echo "Git fetched"
echo "Resetting to remote main"
git reset --hard origin/main
echo "Ensuring submodules"
git submodule update --init --recursive
echo "Submodules initialized"
echo "Entering shell and building..."
nix develop --command zola build --force --output-dir ../www
echo "Completed!"
