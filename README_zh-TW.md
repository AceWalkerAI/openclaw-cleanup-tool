# 🧹 OpenClaw 配置清理工具

當你的 OpenClaw 遇到認證錯誤無法恢復時，使用此工具清理配置並重新設定。

## 🔥 適用情境

當你看到以下錯誤時：

```
⚠️ Agent failed before reply: All models failed (4): 
anthropic/claude-opus-4-5: Provider anthropic is in cooldown (all profiles unavailable) (rate_limit) | 
anthropic/claude-sonnet-4-5: Provider anthropic is in cooldown (all profiles unavailable) (rate_limit) | 
...
```

或者：

```
No API key found for provider "anthropic"
```

這通常是因為：
- API Key 過期或失效
- 認證配置檔案損壞
- cooldown 機制被錯誤觸發

## 📥 安裝

```bash
# 下載腳本
curl -O https://raw.githubusercontent.com/AceWalkerAI/openclaw-cleanup-tool/main/cleanup-openclaw.sh

# 給予執行權限
chmod +x cleanup-openclaw.sh
```

或者直接 clone：

```bash
git clone https://github.com/AceWalkerAI/openclaw-cleanup-tool.git
cd openclaw-cleanup-tool
chmod +x cleanup-openclaw.sh
```

## 🚀 使用方法

### 步驟 1：執行清理腳本

```bash
./cleanup-openclaw.sh
```

腳本會：
1. ✅ 備份你的 `openclaw.json`
2. ✅ 停止 OpenClaw 服務
3. ✅ 刪除所有 `auth-profiles.json`
4. ✅ 清除配置中的 API Keys
5. ✅ 清除所有 fallback models

### 步驟 2：重新設定 OpenClaw

```bash
openclaw configure
```

按照提示輸入你的 API Key 和偏好設定。

### 步驟 3：啟動服務

```bash
openclaw gateway start
```

## ⚙️ 關於預設模型

清理後執行 `openclaw configure` 時，會讓你選擇預設模型。

### 常用模型選項

| Provider | Model | 說明 |
|----------|-------|------|
| Anthropic | `anthropic/claude-opus-4-5` | 最強，適合複雜任務 |
| Anthropic | `anthropic/claude-sonnet-4-5` | 平衡，日常使用 |
| Anthropic | `anthropic/claude-3-5-haiku-20241022` | 快速便宜，簡單任務 |
| Google | `google-gemini-cli/gemini-3-pro-preview` | Gemini Pro |
| OpenAI | `openai/gpt-4o` | GPT-4o |

### 手動修改預設模型

如果想手動修改，編輯 `~/.openclaw/openclaw.json`：

```json
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-sonnet-4-5",
        "fallbacks": [
          "anthropic/claude-opus-4-5",
          "anthropic/claude-3-5-haiku-20241022"
        ]
      }
    }
  }
}
```

修改後重啟：

```bash
openclaw gateway restart
```

### 設定模型別名

在配置中加入別名，方便切換：

```json
{
  "agents": {
    "defaults": {
      "models": {
        "anthropic/claude-opus-4-5": { "alias": "opus" },
        "anthropic/claude-sonnet-4-5": { "alias": "sonnet" },
        "anthropic/claude-3-5-haiku-20241022": { "alias": "haiku" }
      }
    }
  }
}
```

## 📂 清理的內容

| 項目 | 位置 | 說明 |
|------|------|------|
| API Keys | `openclaw.json` → `env` | 所有環境變數 |
| 認證配置 | `openclaw.json` → `auth.profiles` | OAuth/Token 設定 |
| Brave API | `openclaw.json` → `tools.web.search.apiKey` | 網頁搜尋金鑰 |
| 認證檔案 | `~/.openclaw/agents/*/agent/auth-profiles.json` | 各 agent 認證 |
| Fallbacks | `openclaw.json` → `agents.defaults.model.fallbacks` | 備援模型列表 |

## 💾 備份與還原

### 備份位置

每次執行清理會自動建立備份：

```
~/.openclaw/openclaw.json.backup.YYYYMMDD-HHMMSS
```

### 還原備份

如果清理後想還原：

```bash
# 找到備份檔案
ls ~/.openclaw/openclaw.json.backup.*

# 還原
cp ~/.openclaw/openclaw.json.backup.XXXXXXXX-XXXXXX ~/.openclaw/openclaw.json

# 重啟
openclaw gateway restart
```

## ❓ FAQ

### Q: 清理後我的對話記錄會消失嗎？

**不會。** 此工具只清理認證配置，不會影響：
- 對話記錄 (`~/.openclaw/agents/*/sessions/`)
- Memory 檔案 (`~/.openclaw/workspace/memory/`)
- 工作區檔案 (`~/.openclaw/workspace/`)

### Q: 需要重新設定 Telegram Bot 嗎？

**不需要。** Bot Token 不會被清除（除非你手動刪除）。但建議在 `openclaw configure` 時確認 channel 設定。

### Q: jq 是什麼？為什麼需要？

`jq` 是 JSON 處理工具，用來安全地修改配置檔案。

安裝方式：
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt install jq`
- Windows: `choco install jq`

## 🤝 貢獻

歡迎提交 Issue 或 PR！

## 📄 授權

MIT License

---

Made with 🦊 by [Ace](https://github.com/AceWalkerAI)
