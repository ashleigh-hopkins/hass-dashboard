#!/bin/bash
set -euo pipefail

# Tag and push a release version
# Usage: scripts/release.sh <version>
# Example: scripts/release.sh 1.0.0

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
    echo "Usage: scripts/release.sh <version>"
    echo "Example: scripts/release.sh 1.0.0"
    exit 1
fi

# Validate version format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid version format: $VERSION"
    echo "Expected: X.Y.Z (e.g., 1.0.0)"
    exit 1
fi

TAG="v${VERSION}"

# Check if tag already exists
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Tag $TAG already exists"
    exit 1
fi

# Show what will be tagged
echo "Creating release $TAG at $(git rev-parse --short HEAD)"
echo ""
echo "Commits since last tag:"
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -n "$LAST_TAG" ]]; then
    git log --oneline "$LAST_TAG..HEAD"
else
    git log --oneline -10
fi

echo ""
read -p "Tag and push $TAG? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

git tag "$TAG"
git push origin "$TAG"

REMOTE_URL=$(git remote get-url origin 2>/dev/null | sed 's|.*github.com[:/]||; s|\.git$||')
echo ""
echo "Pushed $TAG -- GitHub Actions will build and release."
echo "  Monitor: https://github.com/${REMOTE_URL}/actions"
