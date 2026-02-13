#!/bin/bash
# ============================================================
# OpenClaw Configuration Cleanup Script
# OpenClaw 配置清理腳本
# ============================================================
# 
# Use when you encounter these errors:
# 適用於以下錯誤：
#   - "Provider anthropic is in cooldown (all profiles unavailable)"
#   - "No API key found for provider"
#   - Auth configuration corrupted, want to start fresh
#
# This script clears all API Keys and auth configs,
# allowing you to reconfigure with `openclaw configure`
#
# Author: Ace 🦊 (AceWalkerAI)
# License: MIT
# ============================================================

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧹 OpenClaw Configuration Cleanup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Configuration paths
OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"
BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required"
    echo "   macOS: brew install jq"
    echo "   Ubuntu: sudo apt install jq"
    exit 1
fi

# Check if openclaw.json exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Cannot find $CONFIG_FILE"
    echo "   Please make sure OpenClaw is installed"
    exit 1
fi

echo "📦 Step 1: Creating backup..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "   ✅ Backup created: $BACKUP_FILE"
echo ""

echo "🛑 Step 2: Stopping OpenClaw service..."
openclaw gateway stop 2>&1 | head -1 || echo "   Service not running"
sleep 2
echo ""

echo "🗑️  Step 3: Deleting all auth-profiles.json..."
AUTH_COUNT=$(find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" -type f 2>/dev/null | wc -l | xargs)
if [ "$AUTH_COUNT" -gt 0 ]; then
    find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" -type f -delete
    echo "   ✅ Deleted $AUTH_COUNT auth file(s)"
else
    echo "   ℹ️  No auth-profiles.json files found"
fi
echo ""

echo "🔧 Step 4: Cleaning openclaw.json configuration..."
jq '
  # Delete all environment variables (API Keys)
  del(.env) |
  # Delete all auth profiles
  del(.auth.profiles) |
  # Delete web search API key
  del(.tools.web.search.apiKey) |
  # Clear all fallback models
  .agents.defaults.model.fallbacks = [] |
  # Clear fallbacks for each agent
  .agents.list = [
    .agents.list[] |
    if .model then del(.model.fallbacks) else . end
  ]
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"

if [ $? -eq 0 ]; then
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo "   ✅ Configuration file cleaned"
else
    echo "   ❌ Cleanup failed, configuration unchanged"
    rm -f "${CONFIG_FILE}.tmp"
    exit 1
fi
echo ""

echo "📊 Step 5: Verifying cleanup results..."
echo "   Environment vars: $(jq -r 'if .env then "still present" else "✅ cleared" end' "$CONFIG_FILE")"
echo "   Auth profiles: $(jq -r 'if .auth.profiles then "still present" else "✅ cleared" end' "$CONFIG_FILE")"
echo "   Fallback models: $(jq -r '.agents.defaults.model.fallbacks | length' "$CONFIG_FILE")"
echo "   auth-profiles.json: $(find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" 2>/dev/null | wc -l | xargs) file(s)"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ Cleanup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Cleared:"
echo "   • All API Keys (Anthropic, OpenAI, Gemini, Brave...)"
echo "   • All auth configuration files (auth-profiles.json)"
echo "   • All fallback model configurations"
echo ""
echo "💾 Backup file:"
echo "   $BACKUP_FILE"
echo ""
echo "🚀 Next steps:"
echo "   Run the following command to reconfigure:"
echo ""
echo "   openclaw configure"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
