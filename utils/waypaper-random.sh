#!/bin/bash

set -e

if command -v waypaper &> /dev/null; then   
  while true; do sleep 600; waypaper --random; done
else
  echo "Waypaper is not installed. Try to pipx install waypaper."
  exit 0
fi
