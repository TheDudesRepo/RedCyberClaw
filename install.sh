#!/bin/bash
# RedCyberClaw Installer

RED='\033[0;31m'
DARK_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'

echo -e "${DARK_RED}"
echo "    🩸 RedCyberClaw Installer"
echo -e "${NC}"

# Check for Claude Code
if command -v claude &> /dev/null; then
    CLAUDE_VER=$(claude --version 2>/dev/null || echo "installed")
    echo -e "  ${GREEN}✓${NC} Claude Code detected: ${WHITE}${CLAUDE_VER}${NC}"
else
    echo -e "  ${RED}✗${NC} Claude Code not found."
    echo -e "  ${GRAY}  Install it first: npm install -g @anthropic-ai/claude-code${NC}"
    echo -e "  ${GRAY}  Then re-run this installer.${NC}"
    exit 1
fi

# Create .env from example if needed
if [ ! -f .env ]; then
    echo -e "  ${YELLOW}○${NC} Creating .env from .env.example..."
    cp .env.example .env
    echo -e "    ${GRAY}Edit .env with your API keys (Shodan, Censys, etc.)${NC}"
else
    echo -e "  ${GREEN}✓${NC} .env already exists"
fi

# Set up Ops directory
echo -e "  ${YELLOW}○${NC} Setting up Ops directory..."
mkdir -p Ops

if [ ! -f Ops/scope.json ]; then
    cat > Ops/scope.json << 'EOF'
{
  "target": "",
  "program": "",
  "in_scope": [],
  "out_of_scope": [],
  "rules_of_engagement": {
    "testing_window": "24/7",
    "rate_limiting": true,
    "destructive_testing": false,
    "social_engineering": false
  }
}
EOF
    echo -e "    ${GREEN}✓${NC} Created Ops/scope.json"
fi

if [ ! -f Ops/engagement.md ]; then
    cat > Ops/engagement.md << 'EOF'
# Engagement Log

> Auto-maintained by RedCyberClaw. Do not delete.

---
EOF
    echo -e "    ${GREEN}✓${NC} Created Ops/engagement.md"
fi

# Make scripts executable
chmod +x rcc rc-exec.sh
echo -e "  ${GREEN}✓${NC} Made rcc and rc-exec.sh executable"

# Symlink rcc to PATH (optional)
echo ""
echo -e "  ${WHITE}Optional: Install 'rcc' command globally${NC}"
echo -e "  ${GRAY}  sudo ln -sf $(pwd)/rcc /usr/local/bin/rcc${NC}"

echo ""
echo -e "${DARK_RED}  ──────────────────────────────────────────────────${NC}"
echo -e "  ${GREEN}✓${NC} ${WHITE}Installation complete!${NC}"
echo -e ""
echo -e "  ${WHITE}Launch RedCyberClaw:${NC}"
echo -e "    ${GREEN}./rcc${NC}                    ${GRAY}# from this directory${NC}"
echo -e "    ${GREEN}rcc${NC}                      ${GRAY}# if you added to PATH${NC}"
echo -e ""
echo -e "  ${WHITE}First steps:${NC}"
echo -e "    1. Edit ${YELLOW}Ops/scope.json${NC} with your target"
echo -e "    2. Run ${GREEN}./rcc${NC}"
echo -e "    3. Tell the AI: ${GRAY}\"Run recon against example.com\"${NC}"
echo -e "${DARK_RED}  ──────────────────────────────────────────────────${NC}"
