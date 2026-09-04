#!/bin/bash

for node in $(cat nodes.txt); do nixos-rebuild switch --build-host $node --target-host $node --flake . --sudo ; done
