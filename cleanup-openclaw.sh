#!/bin/bash
# ============================================================
# OpenClaw 配置清理腳本 (Configuration Cleanup Script)
# ============================================================
# 
# 用途：當遇到以下錯誤時使用
#   - "Provider anthropic is in cooldown (all profiles unavailable)"
#   - "No API key found for provider"
#   - 認證配置混亂，想從頭設定
#
# 此腳本會清除所有 API Keys 和認證配置，讓你可以重新執行 openclaw configure
#
# 作者：Ace 🦊 (AceWalkerAI)
# 授權：MIT
# ============================================================

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🧹 OpenClaw 配置清理腳本"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 配置路徑
OPENCLAW_DIR="$HOME/.openclaw"
CONFIG_FILE="$OPENCLAW_DIR/openclaw.json"
BACKUP_FILE="$CONFIG_FILE.backup.$(date +%Y%m%d-%H%M%S)"

# 檢查 jq 是否安裝
if ! command -v jq &> /dev/null; then
    echo "❌ 錯誤: 需要安裝 jq"
    echo "   macOS: brew install jq"
    echo "   Ubuntu: sudo apt install jq"
    exit 1
fi

# 檢查 openclaw.json 是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ 錯誤: 找不到 $CONFIG_FILE"
    echo "   請確認 OpenClaw 已安裝"
    exit 1
fi

echo "📦 步驟 1: 建立備份..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "   ✅ 備份已建立: $BACKUP_FILE"
echo ""

echo "🛑 步驟 2: 停止 OpenClaw 服務..."
openclaw gateway stop 2>&1 | head -1 || echo "   服務未運行"
sleep 2
echo ""

echo "🗑️  步驟 3: 刪除所有 auth-profiles.json..."
AUTH_COUNT=$(find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" -type f 2>/dev/null | wc -l | xargs)
if [ "$AUTH_COUNT" -gt 0 ]; then
    find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" -type f -delete
    echo "   ✅ 已刪除 $AUTH_COUNT 個認證檔案"
else
    echo "   ℹ️  沒有找到 auth-profiles.json 檔案"
fi
echo ""

echo "🔧 步驟 4: 清理 openclaw.json 配置..."
jq '
  # 刪除所有環境變數（API Keys）
  del(.env) |
  # 刪除所有認證配置
  del(.auth.profiles) |
  # 刪除 web search API key
  del(.tools.web.search.apiKey) |
  # 清空所有備援模型（fallbacks）
  .agents.defaults.model.fallbacks = [] |
  # 清空各 agent 的備援
  .agents.list = [
    .agents.list[] |
    if .model then del(.model.fallbacks) else . end
  ]
' "$CONFIG_FILE" > "${CONFIG_FILE}.tmp"

if [ $? -eq 0 ]; then
    mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"
    echo "   ✅ 配置檔案已清理"
else
    echo "   ❌ 清理失敗，配置檔案未修改"
    rm -f "${CONFIG_FILE}.tmp"
    exit 1
fi
echo ""

echo "📊 步驟 5: 驗證清理結果..."
echo "   環境變數: $(jq -r 'if .env then "仍有殘留" else "✅ 已清除" end' "$CONFIG_FILE")"
echo "   認證配置: $(jq -r 'if .auth.profiles then "仍有殘留" else "✅ 已清除" end' "$CONFIG_FILE")"
echo "   備援模型: $(jq -r '.agents.defaults.model.fallbacks | length' "$CONFIG_FILE") 個"
echo "   auth-profiles.json: $(find "$OPENCLAW_DIR/agents" -name "auth-profiles.json" 2>/dev/null | wc -l | xargs) 個"
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ✅ 清理完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 已清除:"
echo "   • 所有 API 金鑰 (Anthropic, OpenAI, Gemini, Brave...)"
echo "   • 所有認證配置檔 (auth-profiles.json)"
echo "   • 所有備援模型配置 (fallbacks)"
echo ""
echo "💾 備份檔案:"
echo "   $BACKUP_FILE"
echo ""
echo "🚀 下一步:"
echo "   執行以下指令重新設定："
echo ""
echo "   openclaw configure"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
