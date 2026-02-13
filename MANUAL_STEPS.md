# 🔧 Manual Cleanup Steps / 手動清理步驟

If you prefer not to run the script, here are the manual steps to clean up your OpenClaw configuration.

如果你不想執行腳本，以下是手動清理 OpenClaw 配置的步驟。

---

## ⚠️ Before You Start / 開始前

**Backup your entire OpenClaw directory first!**

**請先備份整個 OpenClaw 目錄！**

```bash
cp -r ~/.openclaw ~/.openclaw.backup.$(date +%Y%m%d)
```

---

## Step 1: Stop OpenClaw / 步驟 1：停止 OpenClaw

```bash
openclaw gateway stop
```

---

## Step 2: Backup openclaw.json / 步驟 2：備份 openclaw.json

```bash
cp ~/.openclaw/openclaw.json ~/.openclaw/openclaw.json.backup
```

---

## Step 3: Delete auth-profiles.json files / 步驟 3：刪除認證檔案

Find and delete all `auth-profiles.json` files:

找到並刪除所有 `auth-profiles.json` 檔案：

```bash
# List files first / 先列出檔案
find ~/.openclaw/agents -name "auth-profiles.json" -type f

# Delete them / 刪除
find ~/.openclaw/agents -name "auth-profiles.json" -type f -delete
```

---

## Step 4: Edit openclaw.json / 步驟 4：編輯 openclaw.json

Open the file in your editor:

用編輯器開啟：

```bash
nano ~/.openclaw/openclaw.json
# or / 或
code ~/.openclaw/openclaw.json
```

**Remove these sections / 刪除以下區塊：**

### 4a. Remove `env` section / 刪除 `env` 區塊

```json
// DELETE THIS / 刪除這個
"env": {
  "ANTHROPIC_API_KEY": "...",
  "GEMINI_API_KEY": "...",
  ...
},
```

### 4b. Remove `auth.profiles` section / 刪除 `auth.profiles` 區塊

```json
// DELETE THIS / 刪除這個
"auth": {
  "profiles": {
    "anthropic:default": { ... },
    ...
  }
},
```

### 4c. Remove `tools.web.search.apiKey` / 刪除搜尋 API Key

```json
"tools": {
  "web": {
    "search": {
      "apiKey": "..."  // DELETE THIS LINE / 刪除這行
    }
  }
}
```

### 4d. Clear fallbacks array / 清空 fallbacks 陣列

```json
"agents": {
  "defaults": {
    "model": {
      "primary": "...",
      "fallbacks": []  // MAKE THIS EMPTY / 改成空陣列
    }
  }
}
```

---

## Step 5: Reconfigure / 步驟 5：重新設定

```bash
openclaw configure
```

Follow the prompts to set up your API keys and preferences.

依照提示設定你的 API Key 和偏好。

---

## Step 6: Start OpenClaw / 步驟 6：啟動 OpenClaw

```bash
openclaw gateway start
```

---

## 🔍 What Each Step Does / 每個步驟的作用

| Step | What it does | 作用 |
|------|--------------|------|
| 3 | Removes cooldown state stored in auth-profiles.json | 移除儲存在 auth-profiles.json 的 cooldown 狀態 |
| 4a | Removes all API keys from environment | 從環境變數移除所有 API Key |
| 4b | Removes OAuth/token authentication configs | 移除 OAuth/token 認證配置 |
| 4c | Removes web search API key | 移除網頁搜尋 API Key |
| 4d | Clears fallback models to prevent cascade failures | 清空備援模型以防止連鎖失敗 |

---

## 🆘 If Something Goes Wrong / 如果出問題

Restore from your backup:

從備份還原：

```bash
cp ~/.openclaw/openclaw.json.backup ~/.openclaw/openclaw.json
# or full restore / 或完整還原
rm -rf ~/.openclaw && mv ~/.openclaw.backup.YYYYMMDD ~/.openclaw
```

---

Made with 🦊 by [Ace](https://github.com/AceWalkerAI)
