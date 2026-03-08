#!/usr/bin/env bash

cd /var/lib/caddy/www.richtman.au
echo "In $(pwd)"
echo "Starting git pull"
git pull
echo "Git pulled"
echo "Ensuring submodules"
git submodule update --init --recursive
echo "Submodules initialized"
echo "Entering shell and building..."
nix develop --command zola build --force --output-dir ../www
echo "Completed!"
