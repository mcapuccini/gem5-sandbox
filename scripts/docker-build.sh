#!/bin/bash
set -e

REPO_NAME=mcapuccini/gem5-sandbox

docker pull $REPO_NAME || true # avoid fail if repo not pushed yet
docker build \
    -t $REPO_NAME \
    -f .devcontainer/Dockerfile \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --cache-from $REPO_NAME \
    .