# Claude Switch Aliases Reference

Complete documentation of all available shell aliases for `claude-switch`.

## Installation

Aliases are automatically configured during installation via `install.sh` or by running:

```bash
eval "$(claude-switch --shell-config)"
```

## Core Provider Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ccd` | `claude-switch direct` | Anthropic Direct API (requires `ANTHROPIC_API_KEY`) |
| `ccc` | `claude-switch copilot` | GitHub Copilot via copilot-api (default: claude-sonnet-4-6) |
| `cco` | `claude-switch ollama` | Local Ollama models (default: devstral-small-2) |
| `ccoc` | `claude-switch cloud` | Ollama Cloud hosted models (requires `OLLAMA_API_KEY`) |
| `ccs` | `claude-switch status` | Show status of all providers |

## Claude Models via Copilot

| Alias | Model | Billing | Use Case |
|-------|-------|---------|----------|
| `ccc-opus` | `claude-opus-4-6` | 0x (free) | Best quality, production code, critical decisions |
| `ccc-sonnet` | `claude-sonnet-4-6` | 0x (free) | Daily development, balanced quality/speed |
| `ccc-haiku` | `claude-haiku-4.5` | 0x (free) | Fastest responses, quick questions |
| `ccc-opus46` | `claude-opus-4-6` | 0x (free) | Explicit 4.6 alias |
| `ccc-sonnet46` | `claude-sonnet-4-6` | 0x (free) | Explicit 4.6 alias |

**Example:**
```bash
ccc-opus -p "Review this security-critical authentication code"
ccc-sonnet -p "Add validation to login form"
ccc-haiku -p "Explain what this function does"
```

## GPT Models via Copilot

| Alias | Model | Billing | Use Case |
|-------|-------|---------|----------|
| `ccc-gpt41` / `ccc-gpt` | `gpt-4.1` | 0x (free) | Alternative perspective, second opinion |
| `ccc-gpt5` / `ccc-gpt54` | `gpt-5.4` | 1x (premium) | Top GPT, xhigh reasoning |
| `ccc-gpt51` | `gpt-5.1` | 1x (premium) | GPT 5.1 standard |
| `ccc-gpt52` | `gpt-5.2` | 1x (premium) | GPT 5.2 general |
| `ccc-gpt5-mini` | `gpt-5-mini` | 0x (free) | Fast GPT alternative |
| `ccc-gpt53-codex` | `gpt-5.3-codex` | 0x (free) | Latest Codex (via ccunified) |
| `ccc-grok` | `grok-code-fast-1` | 0.25x | Speed-optimized, economical |

**Note:** GPT models have ~80% MCP compatibility due to strict JSON Schema validation. Some MCP servers (e.g., grepai) may fail. Use Claude models for 100% compatibility.

**Example:**
```bash
ccc-gpt41 -p "Different perspective on this architecture"
ccc-gpt5-mini -p "Quick code explanation"
```

## GPT Codex Models via Unified Fork

**⚠️ Requires unified fork:** Run `ccunified` in separate terminal first.

| Alias | Model | Billing | Use Case | Status |
|-------|-------|---------|----------|--------|
| `ccc-codex` | `gpt-5.3-codex` | 0x (free) | Best code generation | ✅ Tested |
| `ccc-codex-std` | `gpt-5.2-codex` | 0x | Previous codex | ✅ Tested |
| `ccc-codex-mini` | `gpt-5.1-codex-mini` | 0x (free) | Fast code generation | ✅ Tested |
| `ccc-codex-max` | `gpt-5.1-codex-max` | 1x (premium) | Max quality code generation | ✅ Tested |

**Setup:**
```bash
# Terminal 1: Launch unified fork (keep running)
ccunified

# Terminal 2: Use Codex models
ccc-codex -p "Generate REST API with authentication"
ccc-codex-mini -p "Quick utility function"
```

**Why separate terminal?**
- Official copilot-api v0.7.0 doesn't support `/responses` endpoint (required for Codex)
- Unified fork adds support via PR #170
- Fork must run on port 4141 instead of official copilot-api

**Example:**
```bash
ccc-codex -p "Create a complete Express API with JWT auth"
ccc-codex-mini -p "Write a binary search function in TypeScript"
```

## Gemini Models via Copilot

| Alias | Model | Billing | Use Case | Status |
|-------|-------|---------|----------|--------|
| `ccc-gemini` | `gemini-2.5-pro` | 0x (free) | Fast iteration, simple prompts | ⚠️ DEPRECATED (since 17 fév 2026) |
| `ccc-gemini3` | `gemini-3-flash-preview` | 0x (free) | Gemini 3 Flash | ✅ Supported (unified fork) |
| `ccc-gemini3-pro` | `gemini-3-pro-preview` | 1x (premium) | Gemini 3 Pro | ✅ Supported (unified fork) |
| `ccc-gemini31` | `gemini-3.1-pro-preview` | 1x (premium) | Gemini 3.1 Pro (new) | ✅ Supported (unified fork v1.3.1) |

**⚠️ Known Limitations:**
- ✅ Simple prompts work well
- ⚠️ Agentic mode (file creation, tool calling, MCP) may have compatibility issues
- **Recommendation:** Use Claude models (`ccc-sonnet`, `ccc-opus`) for 100% reliability

**Example (safe usage):**
```bash
ccc-gemini -p "Explain this algorithm"  # ✅ Works
ccc-gemini -p "Create file.txt"        # ⚠️ May fail
ccc-sonnet -p "Create file.txt"        # ✅ Use Claude instead
```

**See:** `docs/TROUBLESHOOTING.md` for Gemini agentic mode workarounds.

## Ollama Local Models

| Alias | Model | Params | Use Case | SWE-bench |
|-------|-------|--------|----------|-----------|
| `cco-devstral` / `cco` | `devstral-small-2` | 24B | Best agentic (default) | 68.0% |
| `cco-granite` | `ibm/granite4:small-h` | 32B (9B active) | Long context, 70% less VRAM | ~62% |

**Requirements:**
- 32GB RAM minimum for 24B models
- 48GB RAM recommended for 32B + 64K context
- 64K context Modelfile required (see Performance Considerations in CLAUDE.md)

**Example:**
```bash
cco-devstral -p "Analyze this codebase"  # Best agentic performance
cco-granite -p "Review this 50K LOC project"  # Long context
```

## Ollama Cloud Models

Hosted inference for frontier open-source models that won't fit on local hardware. Same Ollama-compatible interface as local `cco`, but pointed at the Ollama Cloud API (`https://ollama.com/api`).

| Alias | Model | Params | Use Case |
|-------|-------|--------|----------|
| `ccoc` | `gpt-oss:120b` (default) | 120B | Base launch command, general-purpose frontier model |
| `ccoc-gpt-oss` | `gpt-oss:120b` | 120B | Explicit default, balanced quality/speed |
| `ccoc-deepseek` | `deepseek-v3.1:671b` | 671B | Deepest reasoning, complex architectural work |
| `ccoc-qwen` | `qwen3-coder:480b` | 480B | Code generation, agentic coding tasks |

**When to use Ollama Cloud (primary use cases):**
- **Remote inference without local GPU** — run 120B–671B models on a laptop with no NVIDIA/Apple Silicon requirement
- **Fixed monthly billing** — predictable cost (Free / Pro ~$20 / Max ~$100), no per-request surprises
- **No privacy concerns with hosted models** — Ollama does not log requests or use them for training (but code still leaves your machine; use `cco` local for NDA/regulated data)

**Requirements:**
- Ollama Cloud account with an active subscription (Free / Pro / Max)
- `OLLAMA_API_KEY` environment variable exported (e.g. in `~/.zshrc`)
- No local GPU or large RAM needed — inference runs on Ollama's infrastructure

**Setup:**
```bash
# 1. Get an API key from ollama.com/settings/api_keys
# 2. Export in your shell profile
echo 'export OLLAMA_API_KEY="your-key-here"' >> ~/.zshrc
source ~/.zshrc

# 3. (Optional) Override endpoint for self-hosted Ollama-compatible deployments
# export OLLAMA_API_ENDPOINT="https://my-ollama.example.com/api"

# 4. Verify and launch
ccoc
```

**Billing — fixed monthly tiers (not per-request):**

| Tier | Price | Request Quota | Use Case |
|------|-------|---------------|----------|
| Free | $0 / month | Limited daily/hourly rate | Evaluation, casual use |
| Pro | ~$20 / month | Much higher quota for regular agentic workloads | Daily development |
| Max | ~$100 / month | Highest quota, prioritized throughput | Heavy agentic usage, teams |

**No Anthropic API or GitHub Copilot quota is consumed** — this is a completely separate billing channel. Exact limits are set by Ollama; see [ollama.com/pricing](https://ollama.com/pricing).

**Example:**
```bash
ccoc -p "Explain this codebase architecture"          # Default gpt-oss:120b
ccoc-deepseek -p "Redesign this system for scale"     # Maximum reasoning
ccoc-qwen -p "Generate a typed REST client"           # Code-optimized
OLLAMA_CLOUD_MODEL=custom-model ccoc            # Custom override
```

**When to use Ollama Cloud vs Ollama Local:**

| Scenario | Use |
|----------|-----|
| Work laptop without GPU | `ccoc` |
| Air-gapped / proprietary code | `cco` (local, offline) |
| Frontier-size models (>100B) | `ccoc` |
| Zero cloud cost preferred | `cco` |
| Quick experiments with big models | `ccoc` |

📖 See [CLAUDE.md](../CLAUDE.md) for full provider architecture details.

## Semantic Aliases (Shortcuts)

User-friendly aliases that map to specific use cases:

| Alias | Resolves To | Use Case |
|-------|-------------|----------|
| `ccc-prod` | `claude-opus-4-6` | Production code, critical decisions |
| `ccc-dev` | `claude-sonnet-4-6` | Daily development |
| `ccc-quick` | `ccc-haiku` | Quick questions, explanations |
| `ccc-code` | `ccc-gpt53-codex` | Pure code generation (requires ccunified) |
| `ccc-alt` | `ccc-gpt41` | Alternative perspective |
| `ccc-private` | `cco-devstral` | Private/offline work |

**Example workflow:**
```bash
ccc-dev        # Start daily work session
ccc-quick      # Ask quick questions during coding
ccc-prod       # Final review before deployment
ccc-private    # Work on proprietary code
```

## Utility Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ccunified` | `~/Sites/perso/cc-copilot-bridge/scripts/launch-unified-fork.sh` | Launch unified fork for Codex/Gemini3 |

## Billing Quick Reference

| Tier | Models | Cost |
|------|--------|------|
| **0x (Free)** | Claude Opus/Sonnet/Haiku, GPT-4.1, GPT-5-mini, All Codex, Gemini 2.5/3-flash | Included in Copilot Pro+ subscription |
| **0.25x** | Grok Code Fast 1 | Economical, consumes minimal quota |
| **1x (Premium)** | GPT-5, GPT-5.2, Codex-Max, Gemini-3-Pro | Consumes completions quota faster |
| **Local (Free)** | All `cco-*` models | No cost, runs on your hardware |
| **Ollama Cloud** | All `ccoc-*` models | Fixed monthly tier via Ollama Cloud (Free / Pro ~$20 / Max ~$100, separate from Copilot) |

**Note:** Copilot models are effectively "free" with Copilot Pro+ subscription, but 1x models consume your quota faster. Ollama Cloud is billed independently via a fixed monthly tier — requires `OLLAMA_API_KEY` and an active Ollama Cloud subscription.

## Decision Tree

```
Need best quality? → ccc-prod (opus)
Daily development? → ccc-dev (sonnet)
Quick question? → ccc-quick (haiku)
Code generation? → ccc-code (codex) + ccunified
Alternative view? → ccc-alt (gpt-4.1)
Private/offline? → ccc-private (ollama devstral)
Long context (>32K)? → cco-granite
Maximum agentic? → cco-devstral
Frontier open model, no GPU? → ccoc (gpt-oss:120b)
Deep reasoning (cloud)? → ccoc-deepseek (671B)
Cloud code generation? → ccoc-qwen (qwen3-coder 480B)
```

## Advanced Usage

### Dynamic Model Override

All aliases support runtime model override via environment variables:

```bash
# Override Copilot model
COPILOT_MODEL=gpt-5 ccc -p "test"

# Override Ollama model
OLLAMA_MODEL=qwen3-coder:30b cco -p "test"

# Override Ollama Cloud model
OLLAMA_CLOUD_MODEL=deepseek-v3.1:671b ccoc -p "test"
```

### Chaining with Other Tools

```bash
# Use with git
ccc-dev -p "Review git diff and suggest improvements" <<< "$(git diff)"

# Pipe output
echo "function add(a, b) { return a + b }" | ccc-quick -p "Explain this"

# Integration with scripts
ccc-prod -p "Review $(cat security-critical.ts)"
```

### Session Logging

All sessions are logged to `~/.claude/claude-switch.log`:

```bash
# View recent sessions
tail -20 ~/.claude/claude-switch.log

# Filter by provider
grep "mode=copilot" ~/.claude/claude-switch.log
grep "model=gpt-5.2-codex" ~/.claude/claude-switch.log

# Session duration analysis
grep "Session ended" ~/.claude/claude-switch.log
```

## Compatibility Matrix

| Alias Family | MCP Support | Tool Calling | File Creation | Recommended For |
|--------------|-------------|--------------|---------------|-----------------|
| Claude (`ccc-*`) | 100% | ✅ Perfect | ✅ Perfect | Everything |
| GPT (`ccc-gpt*`) | ~80% | ✅ Good | ✅ Good | Second opinion |
| Codex (`ccc-codex*`) | ~80% | ✅ Excellent | ✅ Excellent | Code generation |
| Gemini (`ccc-gemini*`) | ⚠️ Limited | ⚠️ Issues | ⚠️ Issues | Simple prompts only |
| Ollama (`cco-*`) | 100% | ✅ Good | ✅ Good | Private/offline |
| Ollama Cloud (`ccoc-*`) | 100% | ✅ Good | ✅ Good | Frontier open models, no GPU |

## Troubleshooting

### "copilot-api not running on :4141"
```bash
# For standard models
copilot-api start

# For Codex models
ccunified
```

### "model not found" (Ollama)
```bash
ollama pull devstral-small-2
ollama pull ibm/granite4:small-h
```

### "OLLAMA_API_KEY not set" (Ollama Cloud)
```bash
# Get your key from https://ollama.com/ and export it
echo 'export OLLAMA_API_KEY="your-key-here"' >> ~/.zshrc
source ~/.zshrc
ccoc  # Retry
```

### Slow Ollama responses
Create 64K context Modelfile (see `CLAUDE.md` Performance Considerations section).

### MCP errors with GPT models
Some MCP servers have schema issues with GPT strict validation. Use Claude models for 100% compatibility:
```bash
ccc-gpt41 -p "..."  # ⚠️ May have MCP issues
ccc-sonnet -p "..." # ✅ Always works
```

## Further Reading

- **CLAUDE.md**: Complete technical documentation
- **QUICKSTART.md**: 2-minute setup guide
- **MODEL-SWITCHING.md**: Dynamic model selection strategies
- **TROUBLESHOOTING.md**: Common issues and solutions
- **MCP-PROFILES.md**: MCP compatibility system

## Version

Aliases documented for:
- **claude-switch**: v1.7.0
- **copilot-api**: v0.7.0 (official, stalled) + unified fork v1.3.1 (recommended)
- **Claude Code CLI**: v2.1.15