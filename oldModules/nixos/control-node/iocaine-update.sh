#!/usr/bin/env bash

cd /etc/iocaine/data
echo "In $(pwd)"
echo "Downloading new file"
curl \
  --follow-redirects \
  --output \
  https://github.com/ai-robots-txt/ai.robots.txt/raw/refs/heads/main/robots.json
echo "Downloaded"
echo "Swapping in new file"
mv --force robots.json ai.robots.txt-robots.json
echo "Swapped in, restarting Iocaine"
systemctl restart iocaine
echo "Completed!"
