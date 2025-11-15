#!/usr/bin/env bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Podman Setup for macOS${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    echo -e "${RED}❌ Error: podman is not installed${NC}"
    echo ""
    echo "Install with: brew install podman"
    exit 1
fi

echo -e "${GREEN}✅ Podman is installed${NC}"
echo ""

# Check if podman machine is already initialized
if podman machine list --format json 2>/dev/null | grep -q '"Name"'; then
    echo -e "${YELLOW}ℹ️  Podman machine already exists${NC}"

    # Check if it's running
    if podman machine list --format json | grep -q '"Running":true'; then
        echo -e "${GREEN}✅ Podman machine is running${NC}"
    else
        echo -e "${YELLOW}🔄 Starting podman machine...${NC}"
        podman machine start
        echo -e "${GREEN}✅ Podman machine started${NC}"
    fi
else
    echo -e "${YELLOW}🔄 Initializing podman machine...${NC}"
    echo ""

    # Initialize with reasonable defaults for macOS
    # - 2 CPUs, 4GB RAM, 100GB disk
    # - rootful mode disabled (rootless is default and recommended)
    podman machine init \
        --cpus 2 \
        --memory 4096 \
        --disk-size 100

    echo ""
    echo -e "${GREEN}✅ Podman machine initialized${NC}"
    echo ""

    echo -e "${YELLOW}🔄 Starting podman machine...${NC}"
    podman machine start
    echo -e "${GREEN}✅ Podman machine started${NC}"
fi

echo ""

# Configure auto-start with brew services
echo -e "${YELLOW}🔄 Configuring auto-start...${NC}"
if brew services list | grep -q "podman.*started"; then
    echo -e "${GREEN}✅ Podman auto-start already configured${NC}"
else
    brew services start podman
    echo -e "${GREEN}✅ Podman auto-start configured${NC}"
fi

echo ""

# Verify podman is working
echo -e "${YELLOW}🔍 Verifying podman installation...${NC}"
if podman version &> /dev/null; then
    echo -e "${GREEN}✅ Podman is working correctly${NC}"
    echo ""
    podman version | head -n 5
else
    echo -e "${RED}❌ Podman verification failed${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Podman setup complete!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Next steps:"
echo "  1. Reload your shell or run: source ~/.zshrc"
echo "  2. Test: docker ps (should work via podman alias)"
echo "  3. Test compose: docker-compose --version"
echo ""
echo "Note: The 'docker' command is aliased to 'podman' in your shell config"
echo ""
