# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**claude-switch** is a multi-provider wrapper for Claude Code CLI that enables seamless switching between:
- **Anthropic Direct**: Official API, best quality
- **GitHub Copilot**: Free with Copilot Pro+ via copilot-api proxy
- **Ollama Local**: 100% private, offline capable
- **JetBrains Junie**: Access to JetBrains AI models (incl. Gemini 2.5 Pro) via junie-api proxy, auth via JetBrains OAuth

The project consists of 3 main bash scripts and extensive documentation for optimal usage. A vendored `junie/` directory contains the Node.js/TypeScript junie-api source ([fabienfleureau/junie-api](https://github.com/fabienfleureau/junie-api)) used by the Junie provider.

## Core Scripts

### 1. claude-switch (Main Script)
Location: `~/bin/claude-switch` (installed via `install.sh`)

**Key Functions:**
- `_run_direct()`: Anthropic API direct connection
- `_run_copilot()`: GitHub Copilot via copilot-api proxy (localhost:4141)
- `_run_ollama()`: Local Ollama models via localhost:11434
- `_run_junie()`: JetBrains Junie via junie-api proxy (localhost:4142)
- `_check_port()`: Health checks before launching providers
- `_get_mcp_flags()`: Dynamic MCP profile selection based on model
- `_session_start()`/`_session_end()`: Session logging with durations

**Environment Variables Set:**
```bash
# Copilot mode
ANTHROPIC_BASE_URL="http://localhost:4141"
ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # copilot-api ignores this value
ANTHROPIC_MODEL="${COPILOT_MODEL:-claude-sonnet-4-6}"
DISABLE_NON_ESSENTIAL_MODEL_CALLS="1"

# Ollama mode
ANTHROPIC_BASE_URL="http://localhost:11434"
ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # Ollama ignores this value

# Junie mode
ANTHROPIC_BASE_URL="http://localhost:4142"
ANTHROPIC_AUTH_TOKEN="<PLACEHOLDER>"  # junie-api ignores this value (uses JetBrains OAuth)
ANTHROPIC_MODEL="${JUNIE_MODEL:-google-chat-gemini-pro-2.5}"
```

**Model Switching:**
- Default Copilot model: `claude-sonnet-4-6` (depuis v1.6.0)
- Override via `COPILOT_MODEL` env var (40+ models supported)
- Default Ollama model: `devstral-small-2` (configurable via `OLLAMA_MODEL`)
- Backup Ollama model: `ibm/granite4:small-h` (long context, 70% less VRAM)
- Default Junie model: `google-chat-gemini-pro-2.5` (configurable via `JUNIE_MODEL`)

**Mode/Alias map:**
- `direct|d` → `ccd` (Anthropic)
- `copilot|c` → `ccc` (Copilot)
- `ollama|o` → `cco` (Ollama)
- `junie|j` → `ccj` (Junie)
- `status|s` → `ccs` (provider health)

### 2. install.sh (Installation)
Auto-installer that:
1. Creates `~/bin/` directory if needed
2. Downloads `claude-switch` script
3. Adds shell aliases to `~/.zshrc` or `~/.bashrc`
4. Creates `~/.claude/` directory for logs

**Aliases Created:**

30+ aliases for all providers and models (Claude, GPT, Codex, Gemini, Ollama).

**Quick Reference:**
```bash
# Core providers
ccd, ccc, cco, ccj, ccs

# Claude models
ccc-opus, ccc-sonnet, ccc-haiku

# GPT models
ccc-gpt41, ccc-gpt5, ccc-gpt54, ccc-gpt51, ccc-gpt52, ccc-gpt5-mini

# Codex models (requires ccunified)
ccc-codex, ccc-codex-std, ccc-codex-mini, ccc-codex-max

# Gemini models
ccc-gemini, ccc-gemini3, ccc-gemini3-pro, ccc-gemini31

# Claude extras
ccc-opus-fast

# Ollama models
cco-devstral, cco-granite

# Semantic shortcuts
ccc-prod, ccc-dev, ccc-quick, ccc-code, ccc-alt, ccc-private
```

**📖 Complete documentation:** See `docs/ALIASES.md` for full reference with use cases, examples, and compatibility matrix.

### 3. mcp-check.sh (MCP Diagnostics)
Identifies MCP servers with schema validation issues that fail with GPT-4.1 strict validation.

**Known Issues:**
- `grepai`: object schema missing properties (incompatible with GPT-4.1)

**Usage:**
```bash
mcp-check.sh                # Check configured MCP servers
mcp-check.sh --parse-logs   # Scan recent logs for errors
```

## Architecture

### Session Logging
All sessions logged to `~/.claude/claude-switch.log`:
```
[TIMESTAMP] [LEVEL] message
```

**Log Format:**
- Session start: `mode=<provider> pid=<PID> pwd=<directory>`
- Session end: `mode=<provider> duration=<time> exit=<code>`
- Provider info: `Provider: <name> - Model: <model>`

### Provider Health Checks
Before launching, `claude-switch` verifies:
- **Copilot**: Port 4141 responds (via `nc -z`)
- **Ollama**: Port 11434 responds + model exists (`ollama list`)
- **Junie**: Port 4142 responds (via `nc -z`); requires JetBrains OAuth token
- **Anthropic**: Uses existing `ANTHROPIC_API_KEY` from environment

### Port Map
- `4141` — copilot-api (GitHub Copilot proxy)
- `4142` — junie-api (JetBrains Junie proxy). **Note:** junie-api's upstream default port is `4141`; the bridge overrides it to `4142` so both proxies can coexist.
- `11434` — Ollama local server

### Model Compatibility Matrix

| Provider | Endpoint | Models | MCP Compatibility |
|----------|----------|--------|-------------------|
| Anthropic | Native | Opus/Sonnet/Haiku (4.5/4.6) | 100% (permissive) |
| Copilot-Claude | /chat/completions | claude-sonnet-4-6, claude-opus-4-6, claude-haiku-4.5 | 100% (permissive) |
| Copilot-GPT | /chat/completions | gpt-4.1, gpt-5.1, gpt-5.2, gpt-5.4, gpt-5-mini | ~80% (strict validation) |
| Copilot-Gemini | /chat/completions | gemini-2.5-pro ⚠️ deprecated | ~80% (strict validation) |
| Copilot-Gemini3 | /chat/completions | gemini-3-flash-preview, gemini-3-pro-preview, gemini-3.1-pro-preview | ✅ Supported (via unified fork v1.3.1) |
| Copilot-Codex | /responses | gpt-5.3-codex, gpt-5.2-codex, gpt-5.1-codex-* | ✅ Tested (via unified fork v1.3.1) |
| Copilot-Grok | /chat/completions | grok-code-fast-1 | ✅ Compatible |
| Copilot-Codex | /responses | gpt-*-codex | ✅ Tested (via unified fork) |
| Ollama | Native | devstral, granite4, qwen3-coder | 100% (permissive) |
| Junie | /v1/messages (Anthropic-compat) | google-chat-gemini-pro-2.5 (default), JetBrains AI catalog | ~80% (Gemini strict validation) |

**Unified Fork (PR #167 + #170) - RECOMMENDED:**

The unified fork (v1.3.1) goes far beyond the original PRs:
- **PR #167**: Gemini 3 thinking support (`thought_signature`, `reasoning_text`, `reasoning_opaque`)
- **PR #170**: GPT Codex `/responses` endpoint support
- **v1.2.4**: Fix adaptive thinking with tool choices
- **v1.2.5**: gpt-5.4 (xhigh reasoning), multi-provider support, `--claude-code` flag
- **v1.3.0**: Per-model temperature/topP/topK config
- Native Anthropic Messages API for Claude models (no translation overhead)
- smallModel routing: warmup/compact auto-routed to gpt-5-mini (saves premium requests)

**Usage:**
```bash
# Terminal 1: Launch unified fork
ccunified  # Uses scripts/launch-unified-fork.sh

# Terminal 2: Use models
ccc-codex         # gpt-5.3-codex ✅ Tested
ccc-codex-mini    # gpt-5.1-codex-mini ✅ Tested
ccc-gpt54         # gpt-5.4 ✅ xhigh reasoning
ccc-gemini31      # gemini-3.1-pro-preview ✅ Supported
ccc-gemini3       # gemini-3-flash-preview ✅ Supported
```

**Fork Source:** [caozhiyuan/copilot-api branch 'all'](https://github.com/caozhiyuan/copilot-api/tree/all)
**PR Tracking:** [PR #167](https://github.com/ericc-ch/copilot-api/pull/167), [PR #170](https://github.com/ericc-ch/copilot-api/pull/170)

### MCP Profiles System (Advanced)

**Purpose:** GPT-4.1 applies strict JSON Schema validation that rejects some MCP servers with incomplete schemas. System uses dynamic profile generation to exclude problematic servers.

**Directory Structure:**
```
~/.claude/mcp-profiles/
├── excludes.yaml           # SOURCE OF TRUTH
├── generated/              # Auto-generated
│   ├── gpt.json           # GPT models config
│   └── gemini.json        # Gemini models config
└── generate.sh            # Profile generator
```

**Behavior:**
- Claude models → Use default `~/.claude/claude_desktop_config.json` (all MCPs)
- GPT models → Use `generated/gpt.json` (excludes grepai)
- Gemini models → Use `generated/gemini.json` (excludes grepai)

**Regenerate after config changes:**
```bash
~/.claude/mcp-profiles/generate.sh
```

## Performance Considerations

### Ollama Context Size vs Claude Code Requirements

**Critical Issue:** Claude Code sends ~18K tokens of system prompt + tools. Default Ollama context (4K) causes truncation, hallucinations, and slow responses.

**Solution: Create a 64K Modelfile (persistent):**
```bash
mkdir -p ~/.ollama
cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
FROM devstral-small-2
PARAMETER num_ctx 65536
PARAMETER temperature 0.15
EOF

ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k
```

**Verify effective context:** `ollama ps` (not `ollama show`)

**Memory footprint on M4 Pro 48GB with 64K context:**
- Devstral Q4_K_M (24B): 18-22GB model + 12-15GB KV cache = **30-37GB total**
- Granite4 (32B): 22-26GB model + 12-15GB KV cache = **34-41GB total**
- **Minimum RAM**: 32GB for 24B models, **48GB recommended** for 32B + 64K context

**KV Cache Quantization (Ollama 2025 feature):**
- Enable with `OLLAMA_KV_CACHE_TYPE=q4_0` to reduce cache memory by ~75%
- Enables 64K context on 32GB machines (previously required 48GB+)

**Recommendations by Project Size:**
| Project Size | Files | Recommended Solution |
|--------------|-------|---------------------|
| Small | <500 | Ollama with Modelfile 64K ⚡ |
| Medium | 500-2K | Copilot ⚡ or Ollama 64K |
| Large | >2K | Copilot/Anthropic ⚡ |
| Privacy-critical | Any | Ollama 64K (private) 🔒 |

**Check context usage:** Run `/context` in Claude Code session

### Ollama Models (Updated January 2026)

**Important**: SWE-bench Verified measures real-world agentic coding (GitHub issue resolution with tool calling, multi-file editing, multi-step reasoning). High HumanEval scores don't guarantee agentic performance.

| Model | SWE-bench Verified | Params | Practical Status | Use Case |
|-------|-------------------|--------|------------------|----------|
| **devstral-small-2** (default) | **68.0%** | 24B | ✅ Best agentic | Daily coding, proven reliable |
| **qwen3-coder:30b** | **69.6%** | 30B | ⚠️ Needs template work | Highest bench, config issues |
| **ibm/granite4:small-h** | ~62% | 32B (9B active) | ✅ Long context | 70% less VRAM, 1M context |
| **glm-4.7-flash** | ~65-68% (estimated) | 30B MoE (3B active) | ⚠️ Ollama 0.15.3+ / llama.cpp | Unsloth recommends llama.cpp for best perf |

**Benchmark Sources & Analysis:**

1. **Devstral-small-2**: [Mistral AI](https://mistral.ai/news/devstral-2-vibe-cli) - 68.0% SWE-bench Verified
   - Quote: "Devstral Small 2 excels at using tools to explore codebases, editing multiple files and power software engineering agents"
   - **Native architecture** for agentic tasks (not post-training bolt-on)
   - Proven reliable with Claude Code CLI in practice

2. **Qwen3-coder**: [Index.dev](https://www.index.dev/blog/qwen-ai-coding-review) - 69.6% SWE-bench Verified
   - HumanEval: 85% (excellent code completion)
   - **BUT**: [Qwen blog](https://qwenlm.github.io/blog/qwen3-coder/) reveals "long-horizon RL (Agent RL) was introduced" = **post-training bolt-on**
   - Real-world gap: "needs template work" (CLAUDE.md) - likely prompt engineering or non-standard tool call format
   - Example of bench vs reality disconnect (like Llama3.1:8b: 68% HumanEval but 15% SWE-bench)

3. **GLM-4.7 full**: [Z.AI](https://z.ai/blog/glm-4.7) - 73.8% SWE-bench Verified
   - GLM-4.7-Flash: [WaveSpeedAI](https://wavespeed.ai/blog/posts/glm-4-7-flash-vs-glm-4-7/) = "tier lower" performance
   - No published SWE-bench for Flash variant → estimated ~65-68%
   - 3B active params (MoE) vs 24B full (Devstral) = less "reasoning budget"

**Why Devstral despite 1.6% lower SWE-bench?**

Benchmark scores ≠ practical reliability. Key difference:
- **Architecture**: Devstral = native agentic design vs Qwen3 = Agent RL bolt-on
- **Practice**: Devstral = "best agentic" confirmed vs Qwen3 = "needs template work"
- **Gap precedent**: Llama3.1:8b = 68% HumanEval but **15%** SWE-bench ("catastrophic failure")

Quote from [Understanding LLM Code Benchmarks](https://runloop.ai/blog/understanding-llm-code-benchmarks-from-humaneval-to-swe-bench):
> "This shift reflects a broader trend: moving from the question **'Can the model code?'** to **'Can the model engineer?'**—a far more nuanced and practical inquiry."

**⚠️ Models NOT recommended for agentic tasks:**
| Model | SWE-bench | Why Not |
|-------|-----------|---------|
| CodeLlama:13b | ~40% | No tool calling, weak on multi-file editing |
| Llama3.1:8b | **15%** | "Catastrophic failure" on agentic tasks - cannot reliably use tools |

> **Note**: High HumanEval scores (Llama3.1:8b = 68%) do NOT indicate agentic capability. SWE-bench measures real GitHub issue resolution, which requires tool use and multi-step reasoning.

**Sources:**
- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/)
- [docs.ollama - Context](https://docs.ollama.com/context-length)
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/)

> **Note MLX vs GGUF** : Ollama utilise exclusivement GGUF (format universel). Pour performance maximale sur Mac avec petits modèles (<22B params), LM Studio + MLX peut être jusqu'à 4x plus rapide. Cependant, pour modèles >30B, GGUF redevient plus performant. LM Studio n'est pas compatible avec claude-switch. [Source: lmstudio-ai/mlx-engine#101](https://github.com/lmstudio-ai/mlx-engine/issues/101)

## Commands for Development

### Testing Providers
```bash
# Check all provider status
ccs

# Test Anthropic Direct
ccd
# Expects: ANTHROPIC_API_KEY set in environment

# Test GitHub Copilot (requires copilot-api running)
copilot-api start  # In separate terminal
ccc

# Test Ollama (requires ollama serve + model pulled)
brew services restart ollama
ollama pull devstral-small-2
# Create 64K Modelfile (see Performance Considerations section)
OLLAMA_MODEL=devstral-64k cco

# Test Junie (requires junie-api running on :4142 + JetBrains OAuth)
cd junie && bun install && bun start -- --port 4142  # In separate terminal
ccj
# Default model: google-chat-gemini-pro-2.5 (override via JUNIE_MODEL)
```

### Working on the Vendored junie-api
The `junie/` directory is a **standalone Node.js/TypeScript project** with its own `package.json` and test suite. The main `cc-copilot-bridge` repo is Bash-based; junie is optional and independently buildable.

```bash
cd junie
bun install
bun test       # Run junie-api's test suite
bun run build  # Build TypeScript
bun start      # Start proxy (bridge defaults it to port 4142)
```

### Debugging Session Issues
```bash
# View recent logs
tail -20 ~/.claude/claude-switch.log

# Check provider health
nc -z localhost 4141  # Copilot
nc -z localhost 4142  # Junie
nc -z localhost 11434 # Ollama
curl -s https://api.anthropic.com/v1/messages # Anthropic

# View session durations
grep "Session ended" ~/.claude/claude-switch.log

# Filter by provider
grep "mode=copilot" ~/.claude/claude-switch.log
grep "mode=ollama" ~/.claude/claude-switch.log
grep "mode=junie" ~/.claude/claude-switch.log
```

### Model Switching Commands
```bash
# Copilot with different models
COPILOT_MODEL=claude-opus-4-6 ccc      # Best quality (v4.6)
COPILOT_MODEL=claude-sonnet-4-6 ccc    # Daily driver (v4.6, default)
COPILOT_MODEL=claude-haiku-4.5 ccc     # Fastest
COPILOT_MODEL=gpt-4.1 ccc              # GPT alternative

# Ollama with different models (use 64K Modelfile versions)
OLLAMA_MODEL=devstral-64k cco          # Default (best agentic)
OLLAMA_MODEL=ibm/granite4:small-h cco  # Long context, 70% less VRAM
```

### MCP Troubleshooting
```bash
# Check MCP compatibility
mcp-check.sh

# Scan logs for MCP errors
mcp-check.sh --parse-logs

# Regenerate MCP profiles after config changes
~/.claude/mcp-profiles/generate.sh

# Verify profile content
cat ~/.claude/mcp-profiles/generated/gpt.json | jq -r '.mcpServers | keys[]'
```

## Common Issues & Solutions

### Issue: Ollama Extremely Slow or Hallucinating
**Cause:** Default Ollama context (4K) is too low for Claude Code (~18K system prompt + tools)
**Solution:**
1. **Recommended:** Create a 64K Modelfile (persistent):
   ```bash
   mkdir -p ~/.ollama
   cat > ~/.ollama/Modelfile.devstral-64k << 'EOF'
   FROM devstral-small-2
   PARAMETER num_ctx 65536
   PARAMETER temperature 0.15
   EOF
   ollama create devstral-64k -f ~/.ollama/Modelfile.devstral-64k
   OLLAMA_MODEL=devstral-64k cco
   ```
2. **Alternative:** Quick fix (global, less priority):
   ```bash
   launchctl setenv OLLAMA_CONTEXT_LENGTH 65536
   brew services restart ollama
   ```
3. **Verify:** `ollama ps` should show CONTEXT = 65536

### Issue: "copilot-api not running on :4141"
**Solution:**
```bash
copilot-api start
# Keep running in separate terminal
```

### Issue: Model not found
**Solution:**
```bash
# Pull recommended model
ollama pull devstral-small-2
# Or backup model for long context
ollama pull ibm/granite4:small-h
```

### Issue: MCP Schema Validation Error (GPT-4.1)
**Example:** `Invalid schema for function 'mcp__grepai__grepai_index_status'`
**Solution:**
1. **Preferred:** Use Claude models (`ccc-sonnet`, `ccc-opus`) - 100% MCP compatible
2. **Alternative:** Disable problematic MCP server in `~/.claude/claude_desktop_config.json`
3. **Alternative:** Use MCP profiles system (automatically excludes grepai for GPT)

### Issue: "model gpt-5.2-codex is not accessible via /chat/completions endpoint"
**Cause:** ALL GPT Codex models require `/responses` endpoint (copilot-api v0.7.0 doesn't support it)
**Solution:** Use the unified fork (`ccunified`) which supports `/responses`, or use compatible models:
- `gpt-4.1` (0x premium, recommended)
- `gpt-5.4` (1x premium, xhigh reasoning)
- `gpt-5-mini` (0x premium, fastest)

## Quality Gates (before commit)

```bash
# Lint bash scripts
shellcheck ~/bin/claude-switch install.sh mcp-check.sh

# Test providers manually after any script change
ccs  # Check all providers status
```

No automated test suite — changes must be verified by actually running the affected provider (`ccd`, `ccc`, `cco`) before committing.

## Language & Communication

- **User communicates in French**: Respond in French
- **ALL project artifacts MUST be in English**: commit messages, script comments, README, docs

## Working Directory Confirmation

**ALWAYS confirm before starting any work**:

```bash
pwd  # Verify you're in /Users/florianbruniaux/Sites/perso/cc-copilot-bridge
```

**Key files are NOT in this repo** — the actual scripts live at `~/bin/claude-switch` and `~/.claude/mcp-profiles/`. Edits to files in this repo update the source; run `install.sh` to deploy to `~/bin/`.

---

## File Organization Rules

### DO NOT modify these files directly:
- `~/.claude/mcp-profiles/generated/*.json` - Auto-generated by `generate.sh`

### Modify these when needed:
- `~/.claude/mcp-profiles/excludes.yaml` - Add problematic MCP servers
- `~/.claude/claude_desktop_config.json` - Base MCP configuration
- `~/bin/claude-switch` - Script modifications
- `junie/` - Vendored junie-api source (TypeScript/Node.js); standalone project with its own `package.json` — edit only when patching the Junie proxy

### Documentation structure:
- `README.md` - Complete documentation
- `QUICKSTART.md` - 2-minute setup guide
- `COMMANDS.md` - Command reference
- `TROUBLESHOOTING.md` - Common issues & solutions
- `MODEL-SWITCHING.md` - Dynamic model selection guide
- `MCP-PROFILES.md` - MCP compatibility system
- `OPTIMISATION-M4-PRO.md` - Performance optimization (Apple Silicon)

## Strategic Provider Selection

| Scenario | Command | Reasoning |
|----------|---------|-----------|
| Production code | `ccd` or `ccc-opus` | Best quality, critical decisions |
| Daily development | `ccc` | Free, fast, Claude Sonnet |
| Quick questions | `ccc-haiku` | Fastest responses |
| Code review | `ccc-opus` | Maximum quality |
| Learning/prototyping | `ccc` | Cost-effective iteration |
| Fast iteration | `ccc-gemini` | Gemini 2.5 Pro (stable) |
| Alternative perspective | `ccc-gpt` | GPT-4.1 for second opinion |
| Proprietary code | `cco` | 100% private, no data leaves machine |
| Offline work | `cco` | No internet required |
| Best agentic local | `cco-devstral` | Devstral-small-2 (68% SWE-bench) |
| Long context local | `cco-granite` | Granite4 (70% less VRAM) |
| JetBrains AI subscription | `ccj` | Use existing JetBrains AI quota (Gemini 2.5 Pro default) |

## Package Managers Distribution

### Overview

**Version 1.5.3+** supports distribution via package managers (Homebrew, .deb, .rpm) pour une installation propre et standardisée.

**Avantages** :
- ✅ Installation standard (`brew install`, `apt install`, `dnf install`)
- ✅ Gestion automatique des dépendances (netcat, etc.)
- ✅ Updates faciles (`brew upgrade`, `apt upgrade`)
- ✅ Désinstallation propre
- ✅ Pas d'exécution de scripts curl | bash
- ✅ Configuration shell via `--shell-config` (dynamique)

### Installation Methods

**Homebrew (macOS/Linux)** :
```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
eval "$(claude-switch --shell-config)"
```

**Debian/Ubuntu (.deb)** :
```bash
VERSION="1.5.3"
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch_${VERSION}.deb
sudo dpkg -i claude-switch_${VERSION}.deb
eval "$(claude-switch --shell-config)"
```

**RHEL/Fedora (.rpm)** :
```bash
VERSION="1.5.3"
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v${VERSION}/claude-switch-${VERSION}-1.noarch.rpm
sudo rpm -i claude-switch-${VERSION}-1.noarch.rpm
eval "$(claude-switch --shell-config)"
```

### Shell Configuration

**Option `--shell-config`** (dynamique, recommandée) :

```bash
# Test immédiat
source <(claude-switch --shell-config)

# Ajouter au .zshrc/.bashrc (toujours à jour)
eval "$(claude-switch --shell-config)"
```

**Avantages** :
- Génération dynamique des aliases
- Toujours à jour avec le script
- Pas de fichier statique à maintenir
- Compatible antigen, oh-my-zsh, zinit

**Alternative** (fichier statique) :
```bash
# Générer une fois
claude-switch --shell-config > ~/.claude/aliases.sh

# Sourcer dans .zshrc
source ~/.claude/aliases.sh

# Ou avec antigen
antigen bundle ~/.claude/aliases.sh
```

### GitHub Actions Build Pipeline

**Déclencheur** : Push d'un tag Git (ex: `git tag v1.5.2 && git push --tags`)

**Étapes automatiques** :
1. Compute SHA256 pour Homebrew Formula
2. Build package `.deb` (Debian/Ubuntu)
3. Build package `.rpm` (RHEL/Fedora/CentOS)
4. Update `Formula/cc-copilot-bridge.rb` avec SHA256
5. Create GitHub Release
6. Attach packages (.deb, .rpm, .rb) aux assets
7. Commit Formula update dans le repo

**Workflow** : `.github/workflows/build-packages.yml`

### Homebrew Tap Structure

```
FlorianBruniaux/homebrew-tap/
├── Formula/
│   └── cc-copilot-bridge.rb    # Homebrew formula
└── README.md
```

**Convention** : Le repo `homebrew-tap` devient le tap `FlorianBruniaux/tap`

**Formula** : `Formula/cc-copilot-bridge.rb` (Ruby)
- URL du tarball source (GitHub archive)
- SHA256 checksum (sécurité)
- Dépendances (`netcat`, optionnel: `ollama`, `node`)
- Installation script (copie dans `/usr/local/bin`)

### Release Process

**Quick checklist** :
```bash
# 1. Update version
vim claude-switch  # Version: 1.5.3
vim Formula/cc-copilot-bridge.rb  # version "1.5.3"

# 2. Commit & tag
git add -A
git commit -m "Release v1.5.3: Description"
git tag -a v1.5.3 -m "Release v1.5.3"

# 3. Push tag (triggers GitHub Actions)
git push origin main
git push origin v1.5.3

# 4. Wait for GitHub Actions (~5-10 min)
# Check: https://github.com/FlorianBruniaux/cc-copilot-bridge/actions

# 5. Update Homebrew tap
cd ../homebrew-tap
cp ../cc-copilot-bridge/Formula/cc-copilot-bridge.rb Formula/
git add Formula/cc-copilot-bridge.rb
git commit -m "Update claude-switch to v1.5.3"
git push

# 6. Test
brew update
brew upgrade claude-switch
```

**Détails complets** : Voir `docs/RELEASE-PROCESS.md`

### Documentation

- **PACKAGE-MANAGERS.md** : Guide utilisateur complet (installation, intégration shell)
- **PACKAGE-MANAGERS-EXPLAINED.md** : Explication technique détaillée (Homebrew, .deb, .rpm, GitHub Actions)
- **RELEASE-PROCESS.md** : Process complet de release (checklist, troubleshooting, rollback)
- **INSTALL-OPTIONS.md** : Intégration avec antigen, oh-my-zsh, zinit, etc.

### Testing Locally

**Homebrew Formula** :
```bash
# Build from local formula
brew install --build-from-source Formula/cc-copilot-bridge.rb

# Verify
claude-switch --version
eval "$(claude-switch --shell-config)"
```

**Debian Package** :
```bash
# Build .deb
dpkg-deb --build deb-build/claude-switch_1.5.3

# Install
sudo dpkg -i claude-switch_1.5.3.deb

# Verify
which claude-switch
```

**RPM Package** :
```bash
# Build .rpm
rpmbuild --define "_topdir $(pwd)/rpm-build" -ba rpm-build/SPECS/claude-switch.spec

# Install (Fedora/RHEL)
sudo rpm -i rpm-build/RPMS/*/claude-switch-*.rpm
```

### Troubleshooting Packages

**Homebrew SHA256 mismatch** :
```bash
# Recalculer SHA256
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/archive/refs/tags/v1.5.2.tar.gz
sha256sum v1.5.2.tar.gz

# Update Formula
sed -i 's/sha256 ".*"/sha256 "NEW_SHA"/' Formula/cc-copilot-bridge.rb
```

**Debian dependency issues** :
```bash
sudo apt-get install -f  # Fix broken dependencies
```

**RPM build fails** :
```bash
# Vérifier que le tarball source existe
ls rpm-build/SOURCES/claude-switch-*.tar.gz
```

## Known Issues & Patches

### copilot-api Issue #174: Reserved Billing Header

**Problème**: Claude Code v2.1.15+ injecte `x-anthropic-billing-header` dans le system prompt, causant une erreur `400 invalid_request_body` avec copilot-api.

**Solution 1: Variable d'environnement (Recommandée)**

Désactive l'injection du header à la source. Ajouter dans `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_ATTRIBUTION_HEADER": "0"
  }
}
```

Ou via variable d'environnement shell:
```bash
export CLAUDE_CODE_ATTRIBUTION_HEADER=0
```

**Solution 2: Patch regex dans copilot-api (Alternative)**

Filtre le header côté proxy. Utile si la Solution 1 ne fonctionne pas ou pour une protection défensive.

Fichier: `~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js`

Modification dans `translateAnthropicMessagesToOpenAI`:
```javascript
// FIX #174: Filter x-anthropic-billing-header
systemMessages = systemMessages.map((it) => {
    if (typeof it.content === "string" && it.content.startsWith("x-anthropic-billing-header")) {
        it.content = it.content.replace(/^x-anthropic-billing-header:[^\n]*\n+/, "");
    }
    return it;
});
```

**Vérification**:
```bash
# Test rapide
ccc -p "1+1"
# Attendu: Réponse sans erreur 400
```

**Note**: Le patch regex sera écrasé lors de `npm update -g copilot-api`. La Solution 1 est préférable car persistante.

**Suivi**: [ericc-ch/copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174)

---

### copilot-api Issue #151: Gemini Agentic Mode Limitations

**Problème**: Gemini models (2.5-pro, 3-pro-preview, 3-flash-preview) ont une compatibilité limitée avec le mode agentic (tool calling, file creation, MCP tools) via copilot-api.

**Symptômes**:
- ✅ Prompts simples fonctionnent : `COPILOT_MODEL=gemini-3-pro-preview ccc -p "1+1"` → OK
- ❌ File creation échoue : `COPILOT_MODEL=gemini-3-pro-preview ccc -p "Create hello.txt"` → No file created
- ❌ MCP tools instables : `Use grep to find TODOs` → Inconsistent results
- ❌ Erreurs possibles : `model_not_supported`, `INVALID_ARGUMENT`, `invalid_request_body`

**Cause**: Traduction Claude tool calling → OpenAI → Gemini format introduit des incompatibilités. Gemini utilise un format tool calling spécifique à Google qui diffère de Claude et OpenAI.

**Models affected**:

| Model | Simple Prompts | Agentic Mode | Status |
|--------|----------------|--------------|--------|
| `gemini-2.5-pro` | ✅ OK | ⚠️ Limited | Deprecating 2/17/26 |
| `gemini-3-pro-preview` | ✅ OK | ⚠️ Limited | Supported via fork v1.3.1 |
| `gemini-3-flash-preview` | ✅ OK | ⚠️ Limited | Supported via fork v1.3.1 |
| `gemini-3.1-pro-preview` | ✅ OK | ⚠️ Limited | New, supported via fork v1.3.1 |

**Solutions**:

**Option 0: Utiliser le fork v1.3.1 (RECOMMENDED)** ✅

The unified fork adds PR #167 (Gemini 3 thinking) + PR #170 (Codex).

**⚠️ Important caveat**: PR #167 adds support for Gemini 3 "thinking" response fields (`thought_signature`, `reasoning_opaque`). This is **NOT the same** as fixing tool calling format translation. The core issue (Claude → OpenAI → Gemini) may still exist.

```bash
# Terminal 1: Launch unified fork
ccunified  # Or ~/Sites/perso/cc-copilot-bridge/scripts/launch-unified-fork.sh

# Terminal 2: Test Gemini 3
ccc-gemini3       # gemini-3-flash-preview
ccc-gemini3-pro   # gemini-3-pro-preview

# Agentic test (uncertain result):
❯ Create test.txt with "hello"
# Check: Was the file created?
```

**Option 1: Use Claude (Recommended - 100% compatible)** ⭐

```bash
ccc-sonnet  # Claude Sonnet 4.5 (default)
ccc-opus    # Claude Opus 4.5 (best quality)
ccc-haiku   # Claude Haiku 4.5 (ultra rapide)

❯ Create hello.txt with "test"
✅ Fonctionne parfaitement
```

**Option 2: Workaround Subagent pour Gemini 3 Preview**

Route les tool calls complexes via GPT-5-mini :

```bash
COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini ccc

❯ Create hello.txt with "test"
✅ Subagent GPT gère les tool calls
```

**Option 3: Utiliser Gemini UNIQUEMENT pour prompts simples**

```bash
# ✅ Scénarios adaptés
COPILOT_MODEL=gemini-2.5-pro ccc -p "Explain this code"
COPILOT_MODEL=gemini-2.5-pro ccc -p "Find bugs"

# ❌ Scénarios à éviter (utiliser Claude à la place)
# COPILOT_MODEL=gemini-3-pro-preview ccc -p "Create file"  # ❌
ccc-sonnet -p "Create file"  # ✅
```

**Option 4: Utiliser GPT-4.1 (Alternative stable)**

```bash
COPILOT_MODEL=gpt-4.1 ccc
# Bon compromis entre stabilité et compatibilité
```

**Workaround automatique dans claude-switch**:

Ajouter dans `~/bin/claude-switch`, fonction `_run_copilot()`:

```bash
# Gemini workaround: auto-set subagent for preview models
if [[ "$COPILOT_MODEL" == gemini-3-*-preview ]]; then
    export CLAUDE_CODE_SUBAGENT_MODEL="${CLAUDE_CODE_SUBAGENT_MODEL:-gpt-5-mini}"
    _log "INFO" "Gemini preview detected: subagent=$CLAUDE_CODE_SUBAGENT_MODEL"
fi
```

**Diagnostic**:

```bash
# Dans le projet cc-copilot-bridge
./scripts/test-gemini.sh

# Voir le rapport
cat debug-gemini/diagnostic-report.md

# Analyser les logs copilot-api
./scripts/analyze-copilot-logs.sh debug-gemini/copilot-api-verbose.log
```

**Tests de compatibilité**:

Le script `test-gemini.sh` exécute 5 tests :
1. **Test 1** - Baseline simple (non-agentic) → Vérifie si Gemini fonctionne de base
2. **Test 2** - File creation → Détecte problème tool calling
3. **Test 3** - MCP grep tool → Vérifie compatibilité MCP
4. **Test 4** - Subagent workaround → Valide si GPT subagent corrige le problème
5. **Test 5** - Gemini 2.5 stable → Compare avec version stable

**Arbre de décision basé sur les tests**:
```
Test 1 échoue → Problème auth/config copilot-api (pas Gemini-spécifique)
Test 2 échoue, Test 1 OK → Problème tool format (Gemini-spécifique)
Test 3 échoue → Problème MCP schema validation
Test 4 OK, Test 2 échoue → Workaround subagent fonctionne
Test 5 OK, Test 2 échoue → Gemini 3 preview moins stable que 2.5
```

**Recommandations par scénario**:

| Scénario | Commande Recommandée | Raison |
|----------|---------------------|--------|
| Production code | `ccc-sonnet` | 100% fiable, meilleure qualité |
| Questions rapides | `ccc-haiku` | Rapide, fiable, pas de complexité Gemini |
| Code review | `ccc-opus` | Qualité maximale |
| Expérimentation Gemini | `COPILOT_MODEL=gemini-3-pro-preview CLAUDE_CODE_SUBAGENT_MODEL=gpt-5-mini ccc` | Workaround subagent |
| Alternative GPT | `COPILOT_MODEL=gpt-4.1 ccc` | Stable, bon compromis |

**Migration Path**:

```
Actuellement Gemini 2.5 Pro:
├─ Prompts simples → Continue avec gemini-2.5-pro
├─ Agentic tasks → Migre vers ccc-sonnet
└─ Après 17 fév 2026 → Tout vers ccc-sonnet

Actuellement Gemini 3 Preview:
└─ Tout → Migre vers ccc-sonnet (plus stable, meilleure qualité)
```

**Documentation complète**:
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md#-gemini-agentic-mode-issues-copilot-api) - Section Gemini Agentic Mode Issues
- [docs/MODEL-SWITCHING.md](docs/MODEL-SWITCHING.md#modèles-gemini-via-copilot) - Tableau de compatibilité Gemini
- [debug-gemini/README.md](debug-gemini/README.md) - Testing workspace
- [scripts/test-gemini.sh](scripts/test-gemini.sh) - Automated diagnostic suite

**Suivi**: [ericc-ch/copilot-api#151](https://github.com/ericc-ch/copilot-api/issues/151)

---

## Version Information

- **claude-switch**: v1.7.0 (2026-03-15) - Models update: Claude 4.6, GPT-5.3-Codex, Grok Code Fast 1, Ollama 0.15.3
- **copilot-api**: v0.7.0 (official, stalled since Oct 2025) + unified fork v1.3.1 (recommended)
  - Official: `/chat/completions` only, stalled - voir issue #174 pour fix billing header
  - ⚠️ **Issue #191**: Risque de breaking change API GitHub - surveiller
  - Fork v1.3.1 (caozhiyuan): native Anthropic Messages API, smallModel routing, Codex `/responses`, gpt-5.4, gemini-3.1 - **recommandé par défaut**
  - Flag `--claude-code` : génère la commande de lancement Claude Code (sans claude-switch)
  - Fork source: [caozhiyuan/copilot-api branch 'all'](https://github.com/caozhiyuan/copilot-api/tree/all)
- **Claude Code CLI**: v2.1.15 (@anthropic-ai/claude-code npm package)
- **Ollama**: v0.15.3 stable, default model: devstral-small-2 (backup: ibm/granite4:small-h)

## Testing Changes

When modifying `claude-switch`:
1. Test with all 4 providers (`ccd`, `ccc`, `cco`, `ccj`)
2. Check session logs: `tail ~/.claude/claude-switch.log`
3. Verify health checks: `ccs`
4. Test model switching: `COPILOT_MODEL=<model> ccc`, `JUNIE_MODEL=<model> ccj`
5. Test error handling: Stop provider and try launching

## Notes for AI Assistants

- All bash scripts use `set -euo pipefail` for safety
- Port conflicts: Copilot (4141), Junie (4142), Ollama (11434)
- Session tracking via log file enables usage analytics
- MCP profiles prevent runtime errors with strict validation models
- Default models chosen for best quality/speed balance
- Logs are append-only, consider rotation for long-term use

## Risks & Caveats: Junie Provider

- **Reverse-engineered**: junie-api is a community reverse-engineered proxy to the JetBrains AI / Junie backend; it is not an official JetBrains product and may break without notice when JetBrains changes its internal APIs.
- **ToS**: Usage is subject to the JetBrains AI Terms of Service; programmatic access via third-party proxies may not be explicitly permitted — use at your own risk and only with a valid JetBrains AI subscription.
- **Auth**: Requires a JetBrains OAuth token (obtained via the junie-api auth flow); no Anthropic/OpenAI API key is used.
- **Port override**: junie-api's upstream default is `4141`, which collides with copilot-api. The bridge launches it on `4142`; if you run junie-api outside claude-switch, pass `--port 4142` explicitly.
- **Stability tier**: Treat Junie as experimental — prefer `ccd`/`ccc` for production work.
