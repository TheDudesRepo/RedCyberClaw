#!/bin/bash
# RedCyberClaw Uninstaller
# Cleanly removes RedCyberClaw and restores system to pre-install state

RED='\033[0;31m'
DARK_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${DARK_RED}"
echo "    🩸 RedCyberClaw Uninstaller"
echo -e "${NC}"

RCC_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "  ${YELLOW}This will:${NC}"
echo -e "    • Remove the global ${WHITE}rcc${NC} symlink (if installed)"
echo -e "    • Delete the ${WHITE}${RCC_ROOT}${NC} directory"
echo -e "    • Leave Claude Code itself untouched"
echo ""
echo -e "  ${RED}⚠ Your Ops/ data (findings, engagement logs) will be lost.${NC}"
echo -e "  ${GRAY}  Back up Ops/ first if you want to keep your engagement data.${NC}"
echo ""
read -p "  Proceed? [y/N] " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "  ${GRAY}Aborted.${NC}"
    exit 0
fi

echo ""

# Remove global symlink
if [ -L /usr/local/bin/rcc ]; then
    echo -e "  ${YELLOW}○${NC} Removing /usr/local/bin/rcc symlink..."
    sudo rm -f /usr/local/bin/rcc 2>/dev/null || rm -f /usr/local/bin/rcc 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} Removed /usr/local/bin/rcc"
    else
        echo -e "  ${RED}✗${NC} Could not remove /usr/local/bin/rcc (try: sudo rm /usr/local/bin/rcc)"
    fi
else
    echo -e "  ${GRAY}○${NC} No global rcc symlink found"
fi

# Remove the RedCyberClaw directory
echo -e "  ${YELLOW}○${NC} Removing ${RCC_ROOT}..."
cd /tmp  # move out of the directory before deleting it
rm -rf "$RCC_ROOT"
if [ $? -eq 0 ]; then
    echo -e "  ${GREEN}✓${NC} Removed ${RCC_ROOT}"
else
    echo -e "  ${RED}✗${NC} Failed to remove ${RCC_ROOT}"
    exit 1
fi

echo ""
echo -e "${DARK_RED}  ──────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}✓${NC} ${WHITE}RedCyberClaw has been removed.${NC}"
echo -e "  ${GRAY}  Claude Code is still installed. To remove it too:${NC}"
echo -e "  ${GRAY}  npm uninstall -g @anthropic-ai/claude-code${NC}"
echo -e "${DARK_RED}  ──────────────────────────────────────────────────${NC}"
