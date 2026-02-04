#!/bin/bash
set -euo pipefail

DEV_BUILD=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --dev) DEV_BUILD=true; shift ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

VERSION=$(git describe --tags --exact-match 2>/dev/null || true)

if [[ -z "${VERSION}" ]]; then
    if [[ "${DEV_BUILD}" == "true" ]]; then
        VERSION="0.0.0-dev"
    else
        echo "Error: No git tag found. Please tag this commit first:" >&2
        echo "  git tag v0.0.1" >&2
        echo "" >&2
        echo "For PR/dev builds, use: $0 --dev" >&2
        exit 1
    fi
fi

REPO_URL=$(git remote get-url origin)
COMMIT_ID=$(git rev-parse HEAD)
SHORT_COMMIT_ID=$(git rev-parse --short=12 HEAD)

# Use podman if available, otherwise docker
if command -v podman &>/dev/null; then
    DOCKER_CMD="podman"
    EXTRA_FLAGS="--format docker"
else
    DOCKER_CMD="docker"
    EXTRA_FLAGS=""
fi

echo "Building MinIO: ${VERSION} (${SHORT_COMMIT_ID})"

$DOCKER_CMD build \
    -f KB_Dockerfile \
    --platform linux/amd64 \
    ${EXTRA_FLAGS} \
    --build-arg REPO_URL="${REPO_URL}" \
    --build-arg COMMIT_ID="${COMMIT_ID}" \
    --build-arg SHORT_COMMIT_ID="${SHORT_COMMIT_ID}" \
    --build-arg VERSION="${VERSION}" \
    -t "minio:${VERSION}" \
    -t minio:latest \
    .