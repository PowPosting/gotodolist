#!/bin/bash

# Script untuk automated versioning
# Usage: ./version.sh [major|minor|patch] "Release message"

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 [major|minor|patch] \"Release message\"${NC}"
    echo "Example: $0 minor \"Add new feature\""
    exit 1
fi

VERSION_TYPE=$1
MESSAGE=$2

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")
CURRENT_VERSION=${CURRENT_VERSION#v} # Remove 'v' prefix

echo -e "${YELLOW}Current version: $CURRENT_VERSION${NC}"

# Parse version
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Increment version
case $VERSION_TYPE in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo -e "${RED}Invalid version type. Use: major, minor, or patch${NC}"
        exit 1
        ;;
esac

NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo -e "${GREEN}New version: $NEW_VERSION${NC}"

# Confirm
read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
fi

# Update package.json (frontend)
if [ -f "client/package.json" ]; then
    echo "Updating client/package.json..."
    sed -i.bak "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" client/package.json
    rm client/package.json.bak 2>/dev/null || true
fi

# Update version.go (backend)
if [ -f "go-server/version.go" ]; then
    echo "Updating go-server/version.go..."
    sed -i.bak "s/const Version = \".*\"/const Version = \"$NEW_VERSION\"/" go-server/version.go
    rm go-server/version.go.bak 2>/dev/null || true
fi

# Commit version changes
git add client/package.json go-server/version.go 2>/dev/null || true
git commit -m "chore: bump version to $NEW_VERSION" 2>/dev/null || echo "No version files to commit"

# Create tag
TAG="v$NEW_VERSION"
git tag -a "$TAG" -m "$MESSAGE"

echo -e "${GREEN}✓ Created tag: $TAG${NC}"
echo -e "${YELLOW}Message: $MESSAGE${NC}"
echo ""
echo "Next steps:"
echo "  1. Review changes: git log --oneline -5"
echo "  2. Push commits: git push origin main"
echo "  3. Push tag: git push origin $TAG"
echo "  4. Or push all: git push --follow-tags"
echo ""
echo -e "${GREEN}Done!${NC}"
