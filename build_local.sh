#!/bin/bash
set -e

REPO_URL=$(git remote get-url origin)
COMMIT_ID=$(git rev-parse HEAD)
SHORT_COMMIT_ID=$(git rev-parse --short=12 HEAD)
RELEASE_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "KBASE_DEVELOPMENT.$(date -u +%Y-%m-%dT%H-%M-%SZ)")

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
    --build-arg SHORT_COMMIT_ID="${SHORT_COMMIT_ID}" \
    --build-arg RELEASE_TAG="${RELEASE_TAG}" \
    -t minio:latest \
    .