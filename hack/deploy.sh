#!/bin/bash

for node in $(cat nodes.txt); do
nixos-rebuild ${1:-test} --build-host "nixos@${node}.systems.richtman.au" --target-host "nixos@${node}.systems.richtman.au" --flake ".#${node}" --sudo ;
done
