#!/bin/bash
set -e

REPO_URL=$(git remote get-url origin)
COMMIT_ID=$(git rev-parse HEAD)
VERSION=$(git describe --tags --exact-match 2>/dev/null || echo "dev")

# Use podman if available, otherwise docker
if command -v podman &>/dev/null; then
    DOCKER_CMD="podman"
    EXTRA_FLAGS="--format docker"
else
    DOCKER_CMD="docker"
    EXTRA_FLAGS=""
fi

$DOCKER_CMD build \
    -f KB_Dockerfile \
    --platform linux/amd64 \
    $EXTRA_FLAGS \
    --build-arg REPO_URL="${REPO_URL}" \
    --build-arg COMMIT_ID="${COMMIT_ID}" \
    --build-arg VERSION="${VERSION}" \
    -t minio:latest \
    .