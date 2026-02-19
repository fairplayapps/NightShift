# AI Provider Setup Guide

NightShift supports two AI coding providers: **Claude Code** and **OpenAI Codex CLI**. This guide explains how to set up and use each one.

---

## Quick Provider Comparison

| Feature | Claude Code | OpenAI Codex CLI |
|---------|-------------|------------------|
| **Install** | Visit claude.ai/code | `npm install -g @openai/codex-cli` |
| **Auth** | Anthropic API key | OpenAI API key |
| **Default Model** | Claude Sonnet 4.5 | GPT-4o |
| **Available Models** | Opus 4.6, Sonnet 4.5, Haiku 4.5 | GPT-4o, o1, o3-mini |
| **Cost** | Pay-per-token | Pay-per-token |
| **Speed** | Fast | Fast |
| **Privacy** | Cloud | Cloud |
| **Status** | ✅ Fully Supported | ✅ Fully Supported |
| **Best For** | General coding, long context, balanced performance | OpenAI ecosystem users, complex reasoning |

---

## 1. Claude Code (Recommended)

### Installation

Visit [claude.ai/code](https://claude.ai/code) and follow the installation wizard for your platform.

### Authentication

1. Get an API key from [Anthropic Console](https://console.anthropic.com/)
2. The Claude Code CLI will prompt for your API key on first run
3. Alternatively, set environment variable:
   ```powershell
   [System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your-key-here", "User")
   ```

### Configuration

In `config.json`:
```json
{
  "provider": "claude",
  "defaultModel": "sonnet"
}
```

**Available models:**
- `opus` - Claude Opus 4.6 (most capable, best for complex tasks)
- `sonnet` - Claude Sonnet 4.5 (default, best balance of speed/capability)
- `haiku` - Claude Haiku 4.5 (fastest, most affordable)

### Command Syntax

NightShift invokes Claude Code like this:
```powershell
claude -p "<prompt>" --allowedTools "Read,Glob,Grep,Edit,Write,Bash,Task,TodoWrite,..." --model "<model>"
```

### Verify Installation

```powershell
# Check if installed
claude --version

# Test with NightShift
.\tests\test-claude.ps1
```

### Pricing

Pay-per-token pricing from Anthropic:
- Input: ~$3-15 per million tokens (depending on model)
- Output: ~$15-75 per million tokens (depending on model)

Check latest pricing at [anthropic.com/pricing](https://www.anthropic.com/pricing)

### Tips

- **Sonnet** is recommended for most autonomous sessions (good balance)
- **Opus** for complex architectural decisions or difficult debugging
- **Haiku** for simple tasks or when burning through credits quickly
- Use `defaultModel` in config.json to set globally, or override with `-Model` parameter

---

## 2. OpenAI Codex CLI

### Installation

```powershell
npm install -g @openai/codex-cli
```

### Authentication

1. Get an API key from [OpenAI Platform](https://platform.openai.com/api-keys)
2. Run authentication command:
   ```powershell
   codex auth
   ```
3. Enter your OpenAI API key when prompted

### Configuration

In `config.json`:
```json
{
  "provider": "codex",
  "defaultModel": ""
}
```

**Note:** Model selection is handled by the Codex CLI directly. NightShift passes the model parameter if you specify one, but Codex uses its own defaults.

### Command Syntax

NightShift invokes Codex like this:
```powershell
codex exec "<prompt>" --full-auto --skip-git-repo-check --sandbox workspace-write
```

### Verify Installation

```powershell
# Check if installed
codex --version

# Test with NightShift
.\tests\test-codex.ps1
```

### Pricing

Pay-per-token pricing from OpenAI:
- GPT-4o: ~$2.50-10 per million tokens
- o1-preview: ~$15-60 per million tokens
- o3-mini: ~$1-4 per million tokens

Check latest pricing at [openai.com/api/pricing](https://openai.com/api/pricing)

### Tips

- Codex CLI is optimized for coding workflows with built-in safety features
- `--full-auto` enables autonomous operation (required for NightShift)
- `--sandbox workspace-write` allows file modifications within project directory
- Good choice if you're already in the OpenAI ecosystem

---

## Choosing a Provider

### Use Claude Code if:
- You want the best balance of capability and cost
- You need long context windows (200K+ tokens)
- You prefer explicit model control (opus/sonnet/haiku)
- You're new to AI coding assistants (good documentation, stable)

### Use OpenAI Codex if:
- You're already using OpenAI APIs
- You prefer OpenAI's models (GPT-4o, o1, o3-mini)
- You want OpenAI's specific capabilities (vision, reasoning models)

### Both work great!
NightShift is designed to be provider-agnostic. The core workflow (read ROADMAP → implement → test → commit) works identically regardless of provider.

---

## Switching Providers

You can switch providers anytime by changing `config.json`:

```json
{
  "provider": "claude"   // or "codex"
}
```

Or override per-session:
```powershell
.\autonomous_loop.ps1 -Provider "codex"
```

---

## Provider-Specific Features

### Claude Code
- **Model Selection**: Choose opus/sonnet/haiku via `defaultModel` or `-Model` parameter
- **Tool Control**: Claude supports explicit tool allowlists (configured in `lib/providers.ps1`)
- **Context Windows**: Up to 200K tokens for long codebases

### Codex CLI
- **Autonomous Sandbox**: Built-in `--sandbox` modes for safe execution
- **Git Integration**: Can skip git checks with `--skip-git-repo-check`
- **Model Routing**: Automatically selects best model for task

---

## Troubleshooting

### Claude Code

**"claude: command not found"**
- Install from [claude.ai/code](https://claude.ai/code)
- Verify installation: `claude --version`

**"API key not found"**
- Set `ANTHROPIC_API_KEY` environment variable
- Or let CLI prompt you on first run

**"Rate limit exceeded"**
- Increase `delaySeconds` in config.json (try 60-120 seconds)
- Reduce `maxSessions`
- Check your Anthropic API tier limits

### Codex CLI

**"codex: command not found"**
- Install: `npm install -g @openai/codex-cli`
- Verify installation: `codex --version`

**"Authentication failed"**
- Run `codex auth` and enter valid OpenAI API key
- Check key has not expired at [OpenAI Platform](https://platform.openai.com/api-keys)

**"Rate limit exceeded"**
- Increase `delaySeconds` in config.json
- Check your OpenAI API rate limits
- Consider upgrading to higher tier

### General Issues

**Sessions complete too fast**
- AI might be skipping tasks - review your project shortcut prompt
- Check `logs/autonomous_sessions.log` for details
- Ensure ROADMAP.md has clear, specific tasks

**Sessions fail immediately**
- Check provider CLI is authenticated: `claude --version` or `codex --version`
- Verify ROADMAP.md exists in project directory
- Review last session in `logs/autonomous_sessions.log`

---

## Advanced Configuration

### Rate Limiting Best Practices

Both providers have rate limits. Configure NightShift accordingly:

```json
{
  "maxSessions": 10,        // Limit total sessions
  "delaySeconds": 45,       // 45-60 seconds recommended
  "stopTime": "23:30",      // Auto-stop to prevent overruns
  "commitEveryNSessions": 3 // Checkpoint every 3 sessions
}
```

### Model Selection Strategy

For multi-session autonomous workflows:

1. **Start with Sonnet/GPT-4o** - Test your ROADMAP with balanced model
2. **Switch to Haiku/o3-mini** - If tasks are simple and working well
3. **Upgrade to Opus/o1** - If tasks are failing or need complex reasoning

### Cost Optimization

To minimize API costs:

- Use **Haiku** (Claude) or **o3-mini** (OpenAI) for simple tasks
- Set `maxSessions` based on budget (estimate tokens per session × sessions)
- Use `stopTime` to prevent overnight overruns
- Review `meta/session_reports/` to identify inefficient prompts

---

## Getting Help

- **Claude Code**: https://claude.ai/code/docs
- **OpenAI Codex**: https://platform.openai.com/docs
- **NightShift Issues**: Create GitHub issue with provider name and error details

---

**Both providers work excellently with NightShift. Choose based on your preferences and existing API subscriptions.**
