#!/bin/bash
# Generate aliases file for manual sourcing
# Does NOT modify your shell config automatically

set -e

ALIASES_FILE="$HOME/.claude/aliases.sh"

mkdir -p "$HOME/.claude"

cat > "$ALIASES_FILE" << 'EOF'
# Claude Code Multi-Provider Aliases
# Source this file in your .zshrc: source ~/.claude/aliases.sh

export PATH="$HOME/bin:$PATH"

# Core Commands
alias ccd='claude-switch direct'
alias ccc='claude-switch copilot'
alias cco='claude-switch ollama'
alias ccj='claude-switch junie'
alias ccs='claude-switch status'

# Copilot Model Shortcuts
alias ccc-opus='COPILOT_MODEL=claude-opus-4-6 claude-switch copilot'
alias ccc-sonnet='COPILOT_MODEL=claude-sonnet-4-6 claude-switch copilot'
alias ccc-haiku='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
alias ccc-opus46='COPILOT_MODEL=claude-opus-4-6 claude-switch copilot'
alias ccc-sonnet46='COPILOT_MODEL=claude-sonnet-4-6 claude-switch copilot'
alias ccc-opus-fast='COPILOT_MODEL=claude-opus-4.6-fast claude-switch copilot'
alias ccc-gpt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
alias ccc-gpt41='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
alias ccc-gpt5='COPILOT_MODEL=gpt-5.4 claude-switch copilot'
alias ccc-gpt54='COPILOT_MODEL=gpt-5.4 claude-switch copilot'
alias ccc-gpt51='COPILOT_MODEL=gpt-5.1 claude-switch copilot'
alias ccc-gpt52='COPILOT_MODEL=gpt-5.2 claude-switch copilot'
alias ccc-gpt5-mini='COPILOT_MODEL=gpt-5-mini claude-switch copilot'
alias ccc-grok='COPILOT_MODEL=grok-code-fast-1 claude-switch copilot'
alias ccc-gemini='COPILOT_MODEL=gemini-2.5-pro claude-switch copilot'
alias ccc-gemini3='COPILOT_MODEL=gemini-3-flash-preview claude-switch copilot'
alias ccc-gemini3-pro='COPILOT_MODEL=gemini-3-pro-preview claude-switch copilot'
alias ccc-gemini31='COPILOT_MODEL=gemini-3.1-pro-preview claude-switch copilot'

# Ollama Model Shortcuts
alias cco-devstral='OLLAMA_MODEL=devstral-small-2 claude-switch ollama'
alias cco-granite='OLLAMA_MODEL=ibm/granite4:small-h claude-switch ollama'

# Ollama Cloud Shortcuts
alias ccoc='claude-switch cloud'
alias ccoc-gpt-oss='OLLAMA_CLOUD_MODEL=gpt-oss:120b ccoc'
alias ccoc-deepseek='OLLAMA_CLOUD_MODEL=deepseek-v3.1:671b ccoc'
alias ccoc-qwen='OLLAMA_CLOUD_MODEL=qwen3-coder:480b ccoc'

# Junie Model Shortcuts
# Note: Gemini models (ccj-gemini, ccj-gemini-flash) are tier-gated on JetBrains AI
# and may return 404 on Personal subscriptions. GPT-4.1 / Claude aliases work on all tiers.
alias ccj-gemini='JUNIE_MODEL=google-chat-gemini-pro-2.5 claude-switch junie'
alias ccj-gemini-flash='JUNIE_MODEL=google-chat-gemini-flash-2.5 claude-switch junie'
alias ccj-gpt='JUNIE_MODEL=openai-gpt4.1 claude-switch junie'
alias ccj-gpt-mini='JUNIE_MODEL=openai-gpt4.1-mini claude-switch junie'
alias ccj-sonnet='JUNIE_MODEL=claude-sonnet-4-6 claude-switch junie'
alias ccj-opus='JUNIE_MODEL=claude-opus-4-6 claude-switch junie'

# Unified Fork (Recommended - Codex + Gemini 3 + gpt-5.4)
alias ccunified='~/Sites/perso/cc-copilot-bridge/scripts/launch-unified-fork.sh'
alias ccc-codex='COPILOT_MODEL=gpt-5.3-codex claude-switch copilot'
alias ccc-codex-std='COPILOT_MODEL=gpt-5.2-codex claude-switch copilot'
alias ccc-codex-mini='COPILOT_MODEL=gpt-5.1-codex-mini claude-switch copilot'
alias ccc-codex-max='COPILOT_MODEL=gpt-5.1-codex-max claude-switch copilot'
alias ccc-gpt53-codex='COPILOT_MODEL=gpt-5.3-codex claude-switch copilot'

# Semantic Shortcuts
alias ccc-prod='COPILOT_MODEL=claude-opus-4-6 claude-switch copilot'
alias ccc-dev='COPILOT_MODEL=claude-sonnet-4-6 claude-switch copilot'
alias ccc-quick='COPILOT_MODEL=claude-haiku-4.5 claude-switch copilot'
alias ccc-code='COPILOT_MODEL=gpt-5.3-codex claude-switch copilot'
alias ccc-alt='COPILOT_MODEL=gpt-4.1 claude-switch copilot'
alias ccc-private='OLLAMA_MODEL=devstral-small-2 claude-switch ollama'
alias ccj-jetbrains='JUNIE_MODEL=google-chat-gemini-pro-2.5 claude-switch junie'  # JetBrains native stack
EOF

echo "✓ Created $ALIASES_FILE"
echo ""
echo "Add to your .zshrc:"
echo "  source ~/.claude/aliases.sh"
echo ""
echo "Or with antigen:"
echo "  antigen bundle ~/.claude/aliases.sh"
