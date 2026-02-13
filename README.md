# 🧹 OpenClaw Cleanup Tool

When your OpenClaw encounters authentication errors that won't recover, use this tool to clean up the configuration and start fresh.

[繁體中文版 README](./README_zh-TW.md)

> ⚠️ **WARNING: Please backup your `~/.openclaw/` directory before running this script!**
> 
> The script automatically backs up `openclaw.json`, but a full manual backup is recommended.

## 🔥 When to Use

When you see errors like:

```
⚠️ Agent failed before reply: All models failed (4): 
anthropic/claude-opus-4-5: Provider anthropic is in cooldown (all profiles unavailable) (rate_limit) | 
anthropic/claude-sonnet-4-5: Provider anthropic is in cooldown (all profiles unavailable) (rate_limit) | 
...
```

Or:

```
No API key found for provider "anthropic"
```

This usually happens because:
- API Key expired or invalid
- Auth configuration files corrupted
- Cooldown mechanism incorrectly triggered

## 📥 Installation

```bash
# Download the script
curl -O https://raw.githubusercontent.com/AceWalkerAI/openclaw-cleanup-tool/main/cleanup-openclaw.sh

# Make it executable
chmod +x cleanup-openclaw.sh
```

Or clone the repo:

```bash
git clone https://github.com/AceWalkerAI/openclaw-cleanup-tool.git
cd openclaw-cleanup-tool
chmod +x cleanup-openclaw.sh
```

## 🚀 Usage

### Step 1: Run the cleanup script

```bash
./cleanup-openclaw.sh
```

The script will:
1. ✅ Backup your `openclaw.json`
2. ✅ Stop OpenClaw service
3. ✅ Delete all `auth-profiles.json` files
4. ✅ Clear API Keys from config
5. ✅ Clear all fallback models

### Step 2: Reconfigure OpenClaw

```bash
openclaw configure
```

Follow the prompts to enter your API Key and preferences.

### Step 3: Start the service

```bash
openclaw gateway start
```

## ⚙️ About Default Models

After cleanup, running `openclaw configure` will let you choose a default model.

### Common Model Options

| Provider | Model | Description |
|----------|-------|-------------|
| Anthropic | `anthropic/claude-opus-4-5` | Most capable, for complex tasks |
| Anthropic | `anthropic/claude-sonnet-4-5` | Balanced, daily use |
| Anthropic | `anthropic/claude-3-5-haiku-20241022` | Fast & cheap, simple tasks |
| Google | `google-gemini-cli/gemini-3-pro-preview` | Gemini Pro |
| OpenAI | `openai/gpt-4o` | GPT-4o |

### Manually Change Default Model

To manually change, edit `~/.openclaw/openclaw.json`:

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

Then restart:

```bash
openclaw gateway restart
```

### Setting Model Aliases

Add aliases in config for easy switching:

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

## 📂 What Gets Cleaned

| Item | Location | Description |
|------|----------|-------------|
| API Keys | `openclaw.json` → `env` | All environment variables |
| Auth Config | `openclaw.json` → `auth.profiles` | OAuth/Token settings |
| Brave API | `openclaw.json` → `tools.web.search.apiKey` | Web search key |
| Auth Files | `~/.openclaw/agents/*/agent/auth-profiles.json` | Per-agent auth |
| Fallbacks | `openclaw.json` → `agents.defaults.model.fallbacks` | Fallback model list |

## 💾 Backup & Restore

### Backup Location

Each cleanup automatically creates a backup:

```
~/.openclaw/openclaw.json.backup.YYYYMMDD-HHMMSS
```

### Restore from Backup

If you want to restore after cleanup:

```bash
# Find backup file
ls ~/.openclaw/openclaw.json.backup.*

# Restore
cp ~/.openclaw/openclaw.json.backup.XXXXXXXX-XXXXXX ~/.openclaw/openclaw.json

# Restart
openclaw gateway restart
```

## ❓ FAQ

### Q: Will cleanup delete my conversation history?

**No.** This tool only cleans auth configuration. It does NOT affect:
- Conversation history (`~/.openclaw/agents/*/sessions/`)
- Memory files (`~/.openclaw/workspace/memory/`)
- Workspace files (`~/.openclaw/workspace/`)

### Q: Do I need to reconfigure Telegram Bot?

**No.** Bot tokens are not cleared (unless you manually delete them). But it's recommended to verify channel settings during `openclaw configure`.

### Q: What is jq? Why is it required?

`jq` is a JSON processing tool used to safely modify configuration files.

Installation:
- macOS: `brew install jq`
- Ubuntu/Debian: `sudo apt install jq`
- Windows: `choco install jq`

## 🤝 Contributing

Issues and PRs are welcome!

## 📄 License

MIT License

---

Made with 🦊 by [Ace](https://github.com/AceWalkerAI)
