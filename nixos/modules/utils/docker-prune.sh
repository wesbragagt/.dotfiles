#!/bin/bash

# Prune dangling Docker images
docker image prune -f

# Get a list of Docker images that haven't been used in the past 2 weeks
unused_images=$(docker image ls --format "{{.ID}} {{.CreatedAt}}" | awk -v limit=$(date -d '2 weeks ago' '+%s') '$2 < limit {print $1}')

# Remove the unused images in parallel
echo "$unused_images" | xargs -P 0 -n 1 docker image rm

# Prune dangling Docker volumes
docker volume prune -f
