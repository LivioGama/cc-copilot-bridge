# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

---

## [1.8.0] - 2026-04-16

### 🎉 Added — JetBrains Junie Provider

- **New 4th provider**: `junie` mode (alias `ccj`) routes Claude Code through [junie-api](https://github.com/fabienfleureau/junie-api) — a reverse-engineered proxy for JetBrains Junie/Grazie AI.
- **Vendored source**: `junie/` directory contains an embedded copy of junie-api (upstream: MIT) for local development and offline builds.
- **New aliases**: `ccj`, `ccj-gemini`, `ccj-gemini-flash`, `ccj-gpt`, `ccj-gpt-mini`, `ccj-sonnet`, `ccj-opus`, `ccj-jetbrains`.
- **Port**: Junie runs on `localhost:4142` (copilot-api remains on 4141 — no conflict).
- **Auth**: JetBrains OAuth device flow via `bunx junie-api auth` (one-time setup).
- **Models**: Gemini 2.5 Pro (default), Gemini 2.5 Flash (fast), GPT-5, Claude Sonnet/Opus 4.6 — accessed through JetBrains' AI gateway.
- **Rate limiting**: Supports junie-api's `--rate-limit` and `--wait` flags for managing subscription quotas.
- **Installer**: `install.sh` now detects and optionally configures Junie alongside the other providers.
- **Documentation**: `README.md`, `QUICKSTART.md`, and `CLAUDE.md` updated with Junie sections.

### ⚠️ Risk Disclosure

- Junie integration uses a reverse-engineered proxy; **not officially supported by JetBrains**.
- Excessive automated/scripted use may violate the [JetBrains AI Service ToS](https://www.jetbrains.com/legal/docs/terms/jetbrains-ai-service/) and risk account suspension.
- Intended for personal use with your own JetBrains Junie subscription. Use at your own risk.

### 🙏 Credits

- [fabienfleureau/junie-api](https://github.com/fabienfleureau/junie-api) — the upstream Junie proxy that powers this integration. License: MIT.

---

## [1.7.0] - 2026-03-15

### Added

**🔄 Fork caozhiyuan/copilot-api : v1.1.6 → v1.3.1**

- Fork passe de EXPERIMENTAL à **RECOMMENDED** (plus stable, plus de features)
- Native Anthropic Messages API pour Claude models (sans traduction Chat Completions)
- smallModel routing : warmup/compact auto-routés vers gpt-5-mini (économies premium)
- Flag `--claude-code` : génère la commande Claude Code (pour users sans claude-switch)
- Per-model temperature/topP/topK config (v1.3.0)
- Fix adaptive thinking avec tool choices (v1.2.4)

**🚀 Nouveaux Modèles**

- **gpt-5.4** : top GPT, xhigh reasoning — aliases `ccc-gpt54`, `ccc-gpt5`
- **gpt-5.1** : GPT 5.1 standard — alias `ccc-gpt51`
- **claude-opus-4.6-fast** : Opus rapide — alias `ccc-opus-fast`
- **gemini-3.1-pro-preview** : Gemini 3.1 Pro — alias `ccc-gemini31`

**📦 Nouveaux Aliases**

- `ccc-gpt54` — gpt-5.4 (xhigh reasoning)
- `ccc-gpt5` — gpt-5.4 (replaces deprecated gpt-5)
- `ccc-gpt51` — gpt-5.1 standard
- `ccc-opus-fast` — claude-opus-4.6-fast
- `ccc-gemini31` — gemini-3.1-pro-preview

### Changed

- **Migration Claude 4.5 → 4.6** : Mise à jour globale de toutes les docs (README, guides, scripts) pour refléter claude-opus-4-6 et claude-sonnet-4-6
- **ccfork → ccunified** : Renommage complet dans toutes les docs (QUICK-LAUNCH-GUIDE.md, ALL-MODEL-ALIASES.sh, test-all-models.sh)
- **Fork EXPERIMENTAL → RECOMMENDED** : Le fork caozhiyuan/copilot-api v1.3.1 passe en statut RECOMMENDED dans README et TROUBLESHOOTING
- **Formula Homebrew** : Mise à jour de 1.5.3 → 1.7.0

### Fixed

- **install.sh** : Correction des alias `ccc-opus` et `ccc-sonnet` qui pointaient encore sur 4.5 au lieu de 4.6
- **Codex identity prompt** : Skip de l'injection identity pour les modèles `gpt-*-codex` (évite erreurs de format)

---

## [1.6.0] - 2026-02-18

### Added

**🚀 Nouveaux Modèles (Copilot)**

- **Claude Sonnet 4.6** (`claude-sonnet-4-6`) - Nouveau daily driver (79.6% SWE-bench Verified)
  - Nouvelles aliases: `ccc-sonnet`, `ccc-sonnet46`, `ccc-dev`, `ccc-prod-secondary`
  - Remplace claude-sonnet-4.5 comme modèle par défaut
- **Claude Opus 4.6** (`claude-opus-4-6`) - Best quality 2026
  - Alias: `ccc-opus`, `ccc-opus46`, `ccc-prod`
  - Remplace claude-opus-4.5 dans tous les aliases
- **GPT-5.3-Codex** (`gpt-5.3-codex`) - Latest Codex (via unified fork)
  - Alias: `ccc-codex`, `ccc-gpt53-codex`, `ccc-code`
  - Remplace gpt-5.2-codex comme default codex
- **GPT-5.2** (`gpt-5.2`) - Latest GPT general purpose
  - Alias: `ccc-gpt52`
- **Grok Code Fast 1** (`grok-code-fast-1`) - 0.25x premium, speed-optimized
  - Alias: `ccc-grok`

**📦 Nouveaux Aliases (Shell Config)**

- `ccc-sonnet46` - Claude Sonnet 4.6 (explicit version)
- `ccc-opus46` - Claude Opus 4.6 (explicit version)
- `ccc-gpt52` - GPT-5.2 (latest general GPT)
- `ccc-gpt53-codex` - GPT-5.3-Codex (alias pour `ccc-codex`)
- `ccc-grok` - Grok Code Fast 1 (speed + economical)
- `ccc-gpt5-mini` - GPT-5-mini (alias explicite)
- `ccc-codex-std` - gpt-5.2-codex (previous codex standard)
- `ccc-codex-max` - gpt-5.1-codex-max (max quality codex)

**🎯 Semantic Aliases** (déjà documentés, maintenant dans --shell-config)

- `ccc-prod` → claude-opus-4-6 (Production code)
- `ccc-dev` → claude-sonnet-4-6 (Daily development)
- `ccc-quick` → claude-haiku-4.5 (Quick questions)
- `ccc-code` → gpt-5.3-codex (Code generation, via ccunified)
- `ccc-alt` → gpt-4.1 (Alternative perspective, free)
- `ccc-private` → devstral-small-2 via Ollama (Offline/private)

**🔧 Automatisations CI/CD** (depuis [Unreleased])

- **Automated Homebrew Tap Sync**: GitHub Actions auto-sync Formula to `FlorianBruniaux/homebrew-tap`
- **Daily Tap Sync Verification**: New workflow `.github/workflows/verify-tap-sync.yml`

**📚 Documentation** (depuis [Unreleased])

- MLX vs GGUF note in Ollama sections - performance trade-offs on Apple Silicon
- `docs/ALIASES.md` - Complete reference for 40+ aliases
  - Tables with models, billing tiers, use cases, status
  - Compatibility matrix (MCP, tool calling, file creation)
  - Decision tree for alias selection
  - Advanced usage patterns

### Changed

**🔄 Default Model**
- Default Copilot model: `claude-sonnet-4.5` → `claude-sonnet-4-6`
- Model ID format: dot notation retained for 4.5 models, dash notation for 4.6 (`claude-sonnet-4-6`)

**⚠️ Dépréciations Effectives (17 février 2026)**

| Modèle | Statut | Remplacé par |
|--------|--------|-------------|
| `gpt-5` | ⚠️ DEPRECATED | `gpt-5.2` |
| `gpt-5-codex` | ⚠️ DEPRECATED | `gpt-5.3-codex` (via unified fork) |
| `claude-opus-41` | ⚠️ DEPRECATED | `claude-opus-4-6` |
| `gpt-4o` | Vérifié GA mais vieillissant | `gpt-4.1` (recommandé) |
| `gemini-2.5-pro` | ⚠️ Potentially deprecated | `gemini-3-flash-preview` (agentic non garanti) |

**🚀 copilot-api Status Update**
- Fork caozhiyuan v1.1.6 : promue **option recommandée par défaut** (plus "experimental")
- Official v0.7.0 : stalled depuis oct 2025, risque de casse (issue #191)
- `ccunified` : référence maintenant fork v1.1.6

**🤖 Ollama**
- Version requise mise à jour : 0.15.1+ → **0.15.3+** (stable)
- Adaptive context windows documentées (auto-détection RAM)
- GLM-4.7-Flash : statut mis à jour (Unsloth recommande llama.cpp pour meilleures perf)

**📋 Homebrew Package** (depuis [Unreleased])
- Renamed: `claude-switch` → `cc-copilot-bridge` (matches repo name)
- Deterministic SHA256 from release asset (not git archive)

### Fixed

- **Version inconsistency**: 3 versions différentes dans le script (1.5.3/1.5.2/1.4.0) → toutes à 1.6.0
- **SHA256 Mismatch Bug** (depuis [Unreleased]): `git archive` vs GitHub tarball mismatch

### Technical Details

**Model ID Format (v1.6.0)**
- Anthropic API standard: dashes (`claude-sonnet-4-6`, `claude-opus-4-6`)
- Legacy 4.5 models: dot notation still works (`claude-sonnet-4.5`, `claude-opus-4.5`)
- Note: Si copilot-api rejette le format dash, utiliser `COPILOT_MODEL=claude-sonnet-4.6` (dot)

**Aliases Architecture**
- Semantic aliases (`ccc-prod`, `ccc-dev`) maintenant dans `--shell-config` (plus dans docs seulement)
- `ccc-codex` maintenant pointe sur gpt-5.3-codex (précédemment gpt-5.2-codex)
- `ccc-codex-std` ajouté pour backwards compat sur gpt-5.2-codex

### Files Modified

- `claude-switch` (version 1.6.0, default model, 15+ new aliases)
- `VERSION` (1.5.3 → 1.6.0)
- `README.md` (version, models, copilot-api status)
- `CLAUDE.md` (default model, Model Compat Matrix, Version Info, Ollama)
- `docs/MODEL-SWITCHING.md` (new models, gemini deprecation, v1.6.0)
- `docs/ALIASES.md` (new aliases, version sync)
- `docs/ALL-MODEL-COMMANDS.md` (new models, deprecation markers)
- `docs/TROUBLESHOOTING.md` (issue #191, copilot-api status)
- `docs/OPTIMISATION-M4-PRO.md` (Ollama 0.15.3, adaptive context)
- `scripts/launch-unified-fork.sh` (v1.1.6 ref, gpt-5.3-codex)

### Links

- Release: [v1.6.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.6.0)
- copilot-api fork: [caozhiyuan/copilot-api v1.1.6](https://github.com/caozhiyuan/copilot-api/tree/all)
- Issue #191: [API breaking change risk](https://github.com/ericc-ch/copilot-api/issues/191)

---

## [1.5.3] - 2026-01-26

### Added

**📚 Documentation Updates** - Ollama 0.15.0+ integration

- **FAQ Entry**: "Can I use `ollama launch` instead of `claude-switch ollama`?"
  - Comparative table showing 7 feature differences
  - Clear use cases: `ollama launch` for quick tests, `claude-switch` for production
  - Setup instructions and context size warnings
  - Link to Ollama v0.15.0 release notes

### Changed

**Ollama Version Requirements Updated**:
- `docs/OPTIMISATION-M4-PRO.md`: Updated from 0.14.2+ to **0.15.0+** (4 locations)
  - Header metadata (version + last updated date)
  - Post-installation checklist
  - Troubleshooting verification instructions
  - Added Ollama v0.15.0 and v0.15.1 to sources section

**GLM-4.7-Flash Model Status** (3 files):
- `README.md`, `CLAUDE.md`, `docs/MODEL-SWITCHING.md`
- Status changed: ❌ "Untested with Claude Code" → ⚠️ "Ollama 0.15.1+ required"
- Reason: v0.15.1 fixes repetitive answers and improves tool calling quality
- Updated "Use Case" column: "Speed-optimized variant" → "Tool calling fix (v0.15.1)"

### Technical Details

**Ollama Release Notes Integration**:
- **v0.15.0** (2026-01-21):
  - New `ollama launch` command for zero-config Claude Code integration
  - Multi-line string support (`"""`) in `ollama run` (CLI only, not API)
  - Memory reduction for GLM-4.7-Flash models
- **v0.15.1** (2026-01-24):
  - GLM-4.7-Flash: Fixed repetitive answers + improved tool calling
  - Performance improvements for macOS and ARM64 Linux
  - Fixed bug where `ollama launch` didn't detect `claude` command

**Impact Assessment**:
- `ollama launch` is a **convenience CLI feature** for beginners
- Does NOT replace `claude-switch` (lacks multi-provider, logging, MCP profiles)
- Context size issue (18K tokens) still requires 64K Modelfile configuration
- **Recommendation**: `ollama launch` for quick tests, `claude-switch` for production workflows

### Files Modified
- `claude-switch` (version bump to 1.5.3)
- `docs/OPTIMISATION-M4-PRO.md` (4 changes)
- `README.md` (1 change)
- `CLAUDE.md` (1 change)
- `docs/MODEL-SWITCHING.md` (1 change)
- `docs/FAQ.md` (new entry + date update)

## [1.5.2] - 2026-01-24

### Added

**🎉 Package Managers Support** - Major installation overhaul per community feedback

- **Distribution Methods**:
  - Homebrew Formula (`Formula/cc-copilot-bridge.rb`) for macOS/Linux
  - `.deb` package build for Debian/Ubuntu
  - `.rpm` package build for RHEL/Fedora/CentOS
  - GitHub Actions automated build pipeline (`.github/workflows/build-packages.yml`)

- **`--shell-config` Option** - Respectful shell configuration:
  - Generates aliases dynamically (no static file)
  - User controls their own `.zshrc`/`.bashrc`
  - Compatible with antigen, oh-my-zsh, zinit, sheldon
  - Usage: `eval "$(claude-switch --shell-config)"`

- **Comprehensive Documentation**:
  - `docs/PACKAGE-MANAGERS.md` - User guide (installation per platform)
  - `docs/PACKAGE-MANAGERS-EXPLAINED.md` - Technical deep-dive (100+ pages)
  - `docs/PACKAGE-MANAGERS-SUMMARY.md` - Quick overview
  - `docs/RELEASE-PROCESS.md` - Maintainer guide
  - `docs/INSTALL-OPTIONS.md` - 6 shell integration methods
  - `Formula/README.md` - Homebrew maintainer guide

### Changed

**Installation Script Refactor** (`install.sh`):
- ✅ **Now asks permission** before modifying `.zshrc`/`.bashrc`
- ✅ Default choice: manual configuration (option 2)
- ✅ Creates `~/.claude/aliases.sh` instead of direct modification
- ✅ Provides instructions for antigen, oh-my-zsh, zinit
- ✅ Shows clear warning if user refuses configuration

**Documentation Updates**:
- `README.md` - Package managers as recommended installation method
- `QUICKSTART.md` - 3 installation options (package > script > manual)
- `CLAUDE.md` - New "Package Managers Distribution" section

**User Experience Improvements**:
- Standard installation methods (`brew install`, `apt install`, `dnf install`)
- Automatic dependency management (netcat installed automatically)
- Easy updates (`brew upgrade`, `apt upgrade`)
- Clean uninstall (`brew uninstall`, `dpkg -r`, `rpm -e`)

### Fixed

- **Issue**: `curl | bash` installer modified `.zshrc` without asking (invasive)
- **Issue**: No support for plugin managers (antigen, oh-my-zsh)
- **Issue**: Difficult for LLMs to explain installation process
- **Solution**: Package managers + `--shell-config` option

### Technical Details

- **Version**: 1.5.2 (in `claude-switch` and `Formula/cc-copilot-bridge.rb`)
- **Homebrew Dependencies**: `netcat` (required), `ollama` (optional), `node` (optional)
- **GitHub Actions**: Automatically computes SHA256, builds packages, creates releases
- **SHA256**: Computed automatically for Homebrew Formula security

### Installation

**Homebrew** (recommended):
```bash
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
eval "$(claude-switch --shell-config)"
```

**Debian/Ubuntu**:
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch_1.5.2.deb
sudo dpkg -i claude-switch_1.5.2.deb
eval "$(claude-switch --shell-config)"
```

**RHEL/Fedora**:
```bash
wget https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/download/v1.5.2/claude-switch-1.5.2-1.noarch.rpm
sudo rpm -i claude-switch-1.5.2-1.noarch.rpm
eval "$(claude-switch --shell-config)"
```

### Migration from 1.5.1

**Option 1: Package Manager** (recommended):
```bash
# Remove old installation
rm ~/bin/claude-switch
rm ~/.claude/aliases.sh
# Remove "source ~/.claude/aliases.sh" from .zshrc

# Install via Homebrew
brew tap FlorianBruniaux/tap
brew install cc-copilot-bridge
echo 'eval "$(claude-switch --shell-config)"' >> ~/.zshrc
source ~/.zshrc
```

**Option 2: Keep Script Install**:
```bash
# Re-run installer (now asks permission)
curl -fsSL https://raw.githubusercontent.com/FlorianBruniaux/cc-copilot-bridge/main/install.sh | bash
# Choose option 2 (manual)
# Add to .zshrc: eval "$(claude-switch --shell-config)"
```

## [1.5.1] - 2026-01-23

### Added

**Unified Fork Launcher (PR #167 + #170) - EXPERIMENTAL**
- 🚀 New launcher `scripts/launch-unified-fork.sh` combining both PRs from caozhiyuan/copilot-api:
  - **PR #167**: Gemini 3 thinking support (`thought_signature`, `reasoning_text`, `reasoning_opaque`)
  - **PR #170**: GPT Codex `/responses` endpoint support
- ✨ Source: `caozhiyuan/copilot-api` branch `all` (updated 2026-01-22)
- ✨ Auto-clones fork if not present, auto-updates every 24h
- ✨ Checks PR merge status (informational) before starting
- ✨ Supports both `bun` and `npm` runtimes
- ✨ New aliases: `ccunified`, `ccc-gemini3`, `ccc-gemini3-pro`

**⚠️ IMPORTANT - Experimental Status**:

| Feature | Status | Notes |
|---------|--------|-------|
| GPT Codex (/responses) | ✅ Tested | Works, same as v1.5.0 |
| Standard models | ✅ Working | Claude, GPT-4.1, Gemini 2.5, etc. |
| **Gemini 3 agentic mode** | ⚠️ UNTESTED | PR #167 adds thinking, NOT tool calling fix |

**What PR #167 actually adds**:
- Support for Gemini 3 "thinking" response fields
- This is NOT the same as fixing tool calling format translation
- The core issue (Claude → OpenAI → Gemini format) may still exist
- **Requires testing before claiming it works**

**Supported Models via Unified Fork**:
| Model | Endpoint | Status |
|-------|----------|--------|
| `gpt-5.2-codex` | /responses | ✅ Tested |
| `gpt-5.1-codex-*` | /responses | ✅ Tested |
| All Claude, GPT-4.1, etc. | /chat/completions | ✅ Working |
| `gemini-3-flash-preview` | /chat/completions | ⚠️ Untested agentic |
| `gemini-3-pro-preview` | /chat/completions | ⚠️ Untested agentic |

### Changed

- 📝 Updated README.md with unified fork section
- 📝 Updated TROUBLESHOOTING.md with Gemini 3 unified fork solution
- 📝 Updated CLAUDE.md with unified fork documentation

### Migration from v1.5.0

If you were using `launch-responses-fork.sh` for Codex models:
```bash
# Old way (Codex only)
ccfork && ccc-codex

# New way (Codex + Gemini 3 thinking)
ccunified && ccc-codex
# OR
ccunified && ccc-gemini3
```

### Links

- Fork source: [caozhiyuan/copilot-api](https://github.com/caozhiyuan/copilot-api/tree/all)
- PR #167: [Gemini 3 thinking](https://github.com/ericc-ch/copilot-api/pull/167)
- PR #170: [Codex /responses](https://github.com/ericc-ch/copilot-api/pull/170)
- Release: [v1.5.1](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.1)

---

## [1.5.0] - 2026-01-23

### Added

**GPT Codex Model Support (via copilot-api PR #170)**
- 🚀 Added support for all GPT Codex models via fork of copilot-api
  - `gpt-5.2-codex` (latest, recommended)
  - `gpt-5.1-codex`
  - `gpt-5.1-codex-mini`
  - `gpt-5.1-codex-max`
  - `gpt-5-codex`
- ✨ New launcher script `scripts/launch-responses-fork.sh`:
  - Auto-detects if PR #170 is merged (uses official npm if so)
  - Clones and builds fork automatically if needed
  - Health check before launching Claude Code
- ✨ New aliases: `ccfork`, `ccc-codex`, `ccc-codex-std`, `ccc-codex-mini`, `ccc-codex-max`
- 📝 New documentation:
  - `docs/ALL-MODEL-COMMANDS.md` - Complete model reference (42 models)
  - `docs/ALL-MODEL-ALIASES.sh` - Ready-to-use alias file
  - `docs/QUICK-LAUNCH-GUIDE.md` - Fast setup guide
  - `docs/research/RESPONSES-API-TEST-RESULTS.md` - Fork test results (6/6 passed)

**Why Fork Required?**
- Codex models use OpenAI's `/responses` endpoint (launched Oct 2025)
- Official copilot-api v0.7.0 only supports `/chat/completions`
- PR #170 adds `/responses` endpoint support
- **Tracking**: [ericc-ch/copilot-api#170](https://github.com/ericc-ch/copilot-api/pull/170)

**Research Documentation**
- 📊 Added AgentAPI vs copilot-api comparative analysis in `docs/research/AGENTAPI-VS-COPILOT-API.md`:
  - Architectural differences: Terminal emulator vs API translation layer
  - Complementary tools verdict (not alternatives)
  - Use case decision matrix
  - Community metrics (Jan 2026)
  - Recommendation: Keep copilot-api for cc-copilot-bridge use case

**Security Documentation (Ollama)**
- 🔐 Added Ollama security vulnerabilities section in `docs/SECURITY.md`:
  - CNVD-2025-04094: No authentication by default (Critical)
  - Model File OOB Write: RCE potential via malformed .gguf (High)
  - Model Poisoning: Unrestricted upload API (High)
- 🔐 Added recommended hardening steps (firewall, resource limits)
- 🔐 Source: Cisco Shodan Case Study on Ollama (2025)

**Air-Gapped Model Verification Protocol**
- 🔒 Added 3-stage verification protocol in `docs/SECURITY.md`:
  - Stage 1: Download with SHA-256 checksums
  - Stage 2: Transfer with archive verification
  - Stage 3: Import with individual checksum verification
- 🔒 Added audit trail requirements for regulated environments
- 🔒 Reference: GitHub Issue #9756 (Ollama cannot verify integrity in air-gapped)

**KV Cache Quantization Documentation**
- ✨ Documented `OLLAMA_KV_CACHE_TYPE=q4_0` (Ollama 2025 feature)
- ✨ Reduces KV cache memory by ~75% (48GB → 12GB for 64K context)
- ✨ Enables 64K context on 32GB machines

### Changed

**Memory Requirements Updated**
- 🔧 Corrected RAM specs in `CLAUDE.md`:
  - Devstral 24B: 30-37GB total (was 23-27GB)
  - Granite4 32B: 34-41GB total
  - **Minimum**: 32GB for 24B, **48GB recommended** for 32B + 64K
- 🔧 Updated `docs/OPTIMISATION-M4-PRO.md` with q4_0 cache type

**Model Recommendations**
- ⚠️ Added warning for non-agentic models in `CLAUDE.md`:
  - CodeLlama:13b (~40% SWE-bench) - No tool calling
  - Llama3.1:8b (**15%** SWE-bench) - "Catastrophic failure" on agentic tasks
- ⚠️ Note: High HumanEval ≠ agentic capability (Llama3.1:8b = 68% HumanEval but 15% SWE-bench)

### Security

- 🔐 Added `.gitleaks.toml` configuration for secret detection
- 🔐 Added GitHub Actions workflow `.github/workflows/security-scan.yml` for automated security scanning
- 🔐 Gitleaks scans on every push/PR to detect accidentally committed credentials

### Changed

**Security Hardening**
- 🔧 Replaced `sk-dummy` placeholder with `<PLACEHOLDER>` in `claude-switch` script
- 🔧 Replaced token-like examples (`sk-...`) with `<YOUR_API_KEY>` in documentation
- 🔧 Sanitized all credential placeholders across docs (CLAUDE.md, ARCHITECTURE.md, FEATURES.md, BEST-PRACTICES.md, TROUBLESHOOTING.md)
- 🔧 Added explanatory comments for placeholder values (e.g., "copilot-api ignores this value")

**Documentation Cleanup**
- 📝 CHEATSHEET.md: Complete rewrite (250 → 39 lines) - now a true printable quick reference
  - Removed emojis (ASCII-only for terminal/printer compatibility)
  - Removed duplicate content from README/COMMANDS/TROUBLESHOOTING
  - Updated version v1.2.0 → v1.4.0
  - Max line width: 65 columns (fits 80-column terminals)
- 📝 QUICKSTART.md: Removed duplicate cheat sheet table, replaced with link
- 📝 COMMANDS.md: Updated version header v1.2.0 → v1.4.0

---

## [1.4.0] - 2026-01-22

### Changed

**Ollama Provider Overhaul**
- 🔧 **Default model changed**: `qwen2.5-coder:32b-instruct` → `devstral-small-2` (68% SWE-bench, better agentic coding)
- 🔧 **Backup model added**: `ibm/granite4:small-h` (70% less VRAM with hybrid Mamba architecture)
- 🔧 **Context warning**: Script now warns if Ollama context < 32K (Claude Code needs ~18K for system prompt + tools)

**New Aliases**
- `cco-devstral` → Devstral-small-2 (default, best agentic)
- `cco-granite` → Granite4 (long context, RAM-efficient)

### Added

**Ollama Context Configuration**
- ✨ New `_check_ollama_context()` function warns when context is too low
- 📝 Instructions for creating 64K Modelfile (persistent context configuration)
- 📝 Verification command: `ollama ps` shows effective context

**Documentation Updates**
- 📝 CLAUDE.md: Updated Ollama section with new models, context setup, memory footprint
- 📝 TROUBLESHOOTING.md: Complete rewrite of Ollama slow/hallucination section with 64K Modelfile solution
- 📝 MODEL-SWITCHING.md: New "Modèles Ollama" section with Devstral, Granite4, and context configuration
- 📝 README.md: Updated Ollama section with context warning and new recommended models

### Technical Details

**Why Devstral over Qwen2.5?**
- Devstral uses Mistral/OpenAI-style tool-calling format → more compatible with Claude Code
- Qwen2.5 emits tools in `content` instead of structured `tool_calls` → parsing issues
- Confirmed bug: "stuck on Explore" behavior with Qwen2.5 ([GitHub issue](https://github.com/QwenLM/Qwen3-Coder/issues/180))

**Context Configuration**
- Claude Code sends ~18K tokens of system prompt + tools
- Default Ollama context (4K) causes: hallucinations, "stuck on Explore", 2-6 min responses
- Recommended: 64K Modelfile (persistent) > environment variable (global fallback)
- Verification: `ollama ps` shows CONTEXT column (not `ollama show`)

**Memory Footprint (M4 Pro 48GB with 64K context)**
- Devstral Q4_K_M: 15GB model + 8-12GB cache = ~27GB total → ~21GB free
- Granite4 hybrid: ~10GB active → more headroom for context

### Sources

- [Taletskiy blog](https://taletskiy.com/blogs/ollama-claude-code/) - Original Ollama + Claude Code research
- [docs.ollama - Context](https://docs.ollama.com/context-length) - Official context configuration
- [r/LocalLLaMA benchmarks](https://www.reddit.com/r/LocalLLaMA/comments/1plbjqg/) - Community SWE-bench results
- [Devstral HuggingFace](https://huggingface.co/mistralai/Devstral-Small-2-24B-Instruct-2512) - Model card
- [Granite4 InfoQ](https://www.infoq.com/news/2025/11/ibm-granite-mamba2-enterprise/) - Architecture details

### Links

- Release: [v1.4.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.4.0)
- Commits: [v1.3.0...v1.4.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.3.0...v1.4.0)

---

## [1.3.0] - 2026-01-22

### Fixed

**claude-switch v1.3.0 - Prompt Injection Bug**
- 🐛 Fixed "am" appearing automatically at startup when using `ccc-gpt`
- 🔧 Replaced `eval` string execution with native bash arrays for prompt injection
- ✅ Proper handling of newlines and special characters in system prompts
- 🔐 Eliminated command injection vulnerability from prompt content
- 📝 Technical details: [BUGFIX-AM.md](BUGFIX-AM.md)

**install.sh**
- 🐛 Fixed `ccc-gpt` alias pointing to incompatible `gpt-5.2-codex` → changed to `gpt-4.1`

### Added

**Documentation**
- 📝 Documentation complète de l'issue copilot-api #174 (Reserved Billing Header Error) dans TROUBLESHOOTING.md
- 📝 Guide détaillé d'application du patch communautaire (@mrhanhan) pour filtrer `x-anthropic-billing-header`
- 📝 Documentation du script de test automatique dans scripts/README.md

**Scripts**
- ✨ Nouveau script `scripts/test-billing-header-fix.sh` pour tester le fix de l'issue #174
  - Vérifie que copilot-api filtre correctement le header réservé
  - Test automatique avec requêtes système simulant Claude Code v2.1.15+
  - Validation complète : requête avec billing header + requête normale (contrôle)
- 📋 Nouveau `scripts/README.md` documentant tous les scripts utilitaires du projet

**Visual Examples**
- 📸 6 screenshots ajoutés dans `assets/` pour documentation visuelle
  - Claude Sonnet 4.5 (default model)
  - Claude Opus 4.5 (premium quality)
  - GPT-4.1 (OpenAI)
  - Ollama offline (100% private)
  - Help menu (claude-switch --help)
  - copilot-api proxy server logs
- 🎨 Screenshots intégrés dans README.md (Usage + Features sections)
- 🎨 Screenshots intégrés dans QUICKSTART.md (First Use section)

**Documentation Overhaul**
- 📝 **TL;DR technique** ajouté en haut du README (compréhension immédiate)
- 📝 **Optimisation positionnement GitHub** : killer metrics en ligne 28 (au lieu de 101)
- 📝 **Positionnement confiant** : "Serving Copilot Pro+ subscribers specifically"
- 📝 Retrait langage défensif et marketing excessif
- 📝 Structure claire : Core (Copilot) → Bonus (Ollama) → Fallback (Anthropic)

**Patch Communautaire**
- 🔧 Patch appliqué à copilot-api v0.7.0 pour filtrer `x-anthropic-billing-header`
  - Modifie `dist/main.js` fonction `translateAnthropicMessagesToOpenAI`
  - Ajoute filtrage regex pour supprimer le header réservé du system prompt
  - Log de confirmation : "Filtered x-anthropic-billing-header from system message"
  - Backup automatique créé : `dist/main.js.backup`

### Fixed

- ✅ Résolution de l'erreur `invalid_request_body` avec Claude Code v2.1.15+ via copilot-api
- ✅ Compatibilité restaurée entre Claude Code CLI et GitHub Copilot proxy

### Changed

**Repository Organization**
- 🗂️ Création du dossier `claudedocs/` (non versionné) pour documentation interne
- 🗂️ Documentation déplacée dans `docs/` (CHEATSHEET, CODE_OF_CONDUCT, CONTRIBUTING, FEATURES, ROADMAP)
- 🗂️ VERSION déplacé dans `scripts/`
- 🧹 Nettoyage : RECAP.md et SUMMARY.txt supprimés (obsolètes)

**TROUBLESHOOTING.md**
- ⚠️ Ajout section "Reserved Billing Header Error" avec 3 solutions
  - Option 1: Utiliser Anthropic Direct (`ccd`) - Recommandé
  - Option 2: Utiliser Ollama Local (`cco`) - Alternative gratuite
  - Option 3: Attendre fix officiel copilot-api
- 🔧 Ajout section "Patch communautaire" avec guide étape par étape
  - Localisation du fichier à patcher
  - Création backup
  - Application du patch
  - Tests de validation
  - Procédure de restauration
  - Limitations et suivi de l'issue officielle

### Technical Details

**Patch copilot-api #174**
- Fichier modifié : `~/.nvm/versions/node/v22.18.0/lib/node_modules/copilot-api/dist/main.js`
- Fonction patchée : `translateAnthropicMessagesToOpenAI` (ligne 897)
- Regex utilisée : `/x-anthropic-billing-header: \?cc_version=.+; \?cc_entrypoint=\\+\n{0,2}\./`
- Impact : Filtre automatique du header réservé avant envoi à l'API Anthropic
- Compatibilité : Testé avec copilot-api v0.7.0, Claude Code v2.1.15

**Script de test**
- Langage : Bash
- Dépendances : `curl`, `nc`, `jq`
- Tests : 2 requêtes POST /v1/messages (avec/sans billing header)
- Exit code : 0 si succès, 1 si échec
- Logs : Console + vérification logs copilot-api

### Links

- Issue GitHub : [copilot-api#174](https://github.com/ericc-ch/copilot-api/issues/174)
- Patch original : [@mrhanhan comment](https://github.com/ericc-ch/copilot-api/issues/174#issuecomment)
- Documentation : [TROUBLESHOOTING.md - Patch communautaire](docs/TROUBLESHOOTING.md#patch-communautaire-solution-avancée)
- Release : [v1.3.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.3.0)
- Commits : [v1.2.0...v1.3.0](https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.2.0...v1.3.0)

---

## [1.2.0] - 2026-01-21

### Added

**MCP Profiles System**
- ✨ Auto-generated MCP profiles for strict model validation (GPT-4.1)
- ✨ Model identity injection via system prompts
- ✨ Dynamic profile selection based on model type

**Documentation**
- 📝 MCP-PROFILES.md guide
- 📝 MODEL-SWITCHING.md comprehensive guide

---

## [1.0.0] - 2026-01-20

### Added

**Core Features**
- ✨ Multi-provider support: Anthropic Direct, GitHub Copilot, Ollama
- ✨ Dynamic model switching via `COPILOT_MODEL` environment variable
- ✨ Health checks before provider switching (port availability, model existence)
- ✨ Comprehensive session logging (timestamps, durations, exit codes, models used)
- ✨ Smart shell aliases for instant switching
- ✨ Status command to check all providers at once

**Providers**
- 🚀 **Anthropic Direct**: Official API, best quality, production-ready
- 💰 **GitHub Copilot**: Free with Copilot Pro+ subscription (via copilot-api proxy)
- 🔒 **Ollama Local**: 100% private, offline capable, local inference

**Shell Aliases**
- `ccd` → Anthropic Direct
- `ccc` → GitHub Copilot (default: Sonnet 4.5)
- `cco` → Ollama Local
- `ccs` → Status check all providers
- `ccc-opus` → Copilot with Claude Opus 4.5
- `ccc-sonnet` → Copilot with Claude Sonnet 4.5
- `ccc-haiku` → Copilot with Claude Haiku 4.5
- `ccc-gpt` → Copilot with GPT-5.2 Codex

**Supported Models** (via GitHub Copilot)
- **Claude**: Opus 4.5, Sonnet 4.5, Sonnet 4, Opus 41, Haiku 4.5
- **GPT**: 5.2 Codex, 5.2, 5.1 Codex, 5.1 Codex Max, 5 Mini, 4o variants
- **Gemini**: 3 Pro Preview, 3 Flash Preview, 2.5 Pro
- **Grok**: Code Fast 1
- **Embedding**: text-embedding-3-small

**Documentation**
- 📚 Comprehensive README with examples and troubleshooting
- 📖 MODEL-SWITCHING.md guide for dynamic model selection
- 🏗️ REPO-STRUCTURE.md for repo organization
- ⚙️ Automatic installation script with OS detection

**Logging Features**
- Session start/end timestamps
- Provider and model used
- Working directory path
- Process ID tracking
- Duration calculation (minutes/seconds)
- Exit code tracking
- Colored console output (errors, warnings, info)

### Technical Details

**Script Features**
- Bash 4+ compatible
- Error handling with `set -euo pipefail`
- Health check functions with timeouts
- Session tracking with environment variables
- Colored output for better UX
- Modular function design
- Fail-fast on missing dependencies

**Environment Variables Set**
- `ANTHROPIC_BASE_URL` (provider-specific)
- `ANTHROPIC_AUTH_TOKEN` (provider-specific)
- `ANTHROPIC_MODEL` (dynamic model selection)
- `ANTHROPIC_API_KEY` (Ollama)
- `DISABLE_NON_ESSENTIAL_MODEL_CALLS` (Copilot)
- `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` (Copilot)
- `COPILOT_MODEL` (user-controlled model override)

**Tested Platforms**
- ✅ macOS (M4 Pro, 48GB RAM)
- ✅ Linux (Ubuntu/Debian)
- ❌ Windows (not supported yet)

### Performance

**Latency Benchmarks** (tested on MacBook Pro M4 Pro)
- Anthropic Direct: ~1-2s first token
- GitHub Copilot: ~1-2s first token
- Ollama 32b: ~5-10s first token (local)
- Ollama 7b: ~2-3s first token (local)

**Resource Usage**
- Script overhead: <5MB RAM
- Log file: ~1KB per session
- No background processes

### Security & Privacy

**Data Flow**
- Anthropic Direct: Data sent to Anthropic cloud
- GitHub Copilot: Data sent through Copilot API (Microsoft/GitHub)
- Ollama: 100% local, no external data transmission

**Logging Privacy**
- Log file location: `~/.claude/claude-switch.log`
- Contains: timestamps, providers, durations, working directories
- Does NOT contain: code content, API keys, personal data
- Recommended: Add to `.gitignore`

### Known Limitations

- No Windows support (Bash script)
- Requires netcat (nc) for health checks
- copilot-api must be manually started/managed
- Ollama requires manual model pulling
- No automatic provider fallback on failure
- No cost tracking

### Breaking Changes

None (initial release)

### Deprecated

None (initial release)

### Removed

None (initial release)

### Fixed

None (initial release)

### Security

- No known security vulnerabilities
- Script does not handle API keys directly
- Relies on existing environment variables
- Log file contains only metadata

---

## Roadmap (historical)

### Planned for v1.1

- [ ] Windows PowerShell support
- [ ] Shell completion (Bash/Zsh)
- [ ] Automated tests (health checks, model switching)
- [ ] Better error messages for common issues
- [ ] Config file support (`~/.claude-switch.conf`)

### Planned for v1.2

- [ ] Web UI for status monitoring
- [ ] Cost tracking per provider
- [ ] Usage analytics and reports
- [ ] Automatic provider selection based on context
- [ ] Background service mode for copilot-api

### Planned for v2.0

- [ ] Plugin system for custom providers
- [ ] OpenRouter integration
- [ ] Perplexity integration
- [ ] Team configuration sync
- [ ] Session replay from logs

---

## Contributing

See [REPO-STRUCTURE.md](REPO-STRUCTURE.md) for contribution guidelines.

---

## Links

- **Repository**: https://github.com/FlorianBruniaux/cc-copilot-bridge
- **Issues**: https://github.com/FlorianBruniaux/cc-copilot-bridge/issues

[1.8.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.8.0
[1.7.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.7.0
[1.6.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.6.0
[1.5.3]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.3
[1.5.2]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.2
[1.5.1]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.1
[1.5.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.5.0
[1.4.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.4.0
[1.3.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.3.0
[1.2.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.2.0
[1.0.0]: https://github.com/FlorianBruniaux/cc-copilot-bridge/releases/tag/v1.0.0
[Unreleased]: https://github.com/FlorianBruniaux/cc-copilot-bridge/compare/v1.8.0...HEAD
