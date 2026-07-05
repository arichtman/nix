#!/usr/bin/env bash

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
