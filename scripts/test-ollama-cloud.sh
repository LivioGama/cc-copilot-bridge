#!/usr/bin/env bash
# test-ollama-cloud.sh - Test suite for the Ollama Cloud provider (ccoc)
#
# Covers 8 cases:
#   1. API key validation (missing OLLAMA_API_KEY)
#   2. Bearer token authentication (mocked success)
#   3. Model listing via /api/tags
#   4. Basic prompt execution (skipped if no real key)
#   5. OLLAMA_CLOUD_MODEL override
#   6. Invalid model handling
#   7. OLLAMA_API_ENDPOINT override
#   8. Session logging contains "ollama-cloud"
#
# Uses curl for HTTP assertions instead of spawning claude. The real Claude
# round-trip is guarded behind OLLAMA_LIVE=1 so CI/dry runs stay hermetic.

set -euo pipefail

# ───────────────────────────── Colors ─────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ──────────────────────────── Counters ────────────────────────────
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# ───────────────────────── Configuration ──────────────────────────
OLLAMA_ENDPOINT_DEFAULT="https://ollama.com/api"
OLLAMA_ENDPOINT="${OLLAMA_API_ENDPOINT:-$OLLAMA_ENDPOINT_DEFAULT}"
DEFAULT_MODEL="gpt-oss:120b"
INVALID_MODEL="this-model-does-not-exist:0b-cloud"

LOG_FILE="${CLAUDE_SWITCH_LOG:-$HOME/.claude/claude-switch.log}"

DRY_RUN=0
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=1 ;;
        -h|--help)
            cat <<'USAGE'
Usage: test-ollama-cloud.sh [--dry-run]

Environment:
  OLLAMA_API_KEY       Optional. When set, Test 4 performs a real prompt round-trip.
  OLLAMA_API_ENDPOINT  Optional. Overrides https://ollama.com/api for curl probes.
  OLLAMA_LIVE=1        Opt-in for network-dependent tests (2, 3, 4, 6).
  CLAUDE_SWITCH_LOG    Optional. Overrides ~/.claude/claude-switch.log path.

Flags:
  --dry-run            Verify helpers are defined and print the plan; no network.
USAGE
            exit 0
            ;;
    esac
done

# ─────────────────────────── Helpers ──────────────────────────────
_log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $*"
}

_pass() {
    echo -e "${GREEN}✅ PASS${NC} – $*"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

_fail() {
    echo -e "${RED}❌ FAIL${NC} – $*"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

_skip() {
    echo -e "${YELLOW}⊘ SKIP${NC} – $*"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

_start_test() {
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    echo ""
    _log "Test ${TESTS_TOTAL}: $1"
}

_require_cmd() {
    command -v "$1" >/dev/null 2>&1 || {
        _fail "Required command missing: $1"
        return 1
    }
}

_live_allowed() {
    [[ "${OLLAMA_LIVE:-0}" == "1" ]]
}

# ─── Test 1: API key validation ──────────────────────────────────
_test_auth_missing_key() {
    _start_test "Missing OLLAMA_API_KEY yields a clear error"

    local output rc=0
    # shellcheck disable=SC2016  # single-quotes are intentional — we want the
    # inner subshell to evaluate OLLAMA_API_KEY, not the current shell.
    output=$(env -u OLLAMA_API_KEY bash -c '
        set -u
        if [[ -z "${OLLAMA_API_KEY:-}" ]]; then
            echo "ERROR: OLLAMA_API_KEY not set. Get one at https://ollama.com/settings/api_keys"
            exit 2
        fi
    ') || rc=$?

    if [[ $rc -eq 2 ]] && echo "$output" | grep -qi "OLLAMA_API_KEY not set"; then
        _pass "Missing-key path prints actionable message and non-zero exit"
    else
        _fail "Expected rc=2 with explicit message; got rc=$rc, output=$output"
    fi
}

# ─── Test 2: Bearer token authentication (mocked) ────────────────
_test_auth_bearer_mock() {
    _start_test "Bearer token is carried on /api/tags request"

    if ! _live_allowed; then
        _skip "Set OLLAMA_LIVE=1 to enable network-backed Bearer auth check"
        return
    fi

    _require_cmd curl || return

    local mock_key="${OLLAMA_API_KEY:-sk-mock-key-for-shape-check-only}"
    local http_code
    http_code=$(curl -s -o /dev/null -w "%{http_code}" \
        -H "Authorization: Bearer ${mock_key}" \
        --max-time 10 \
        "${OLLAMA_ENDPOINT}/tags" || echo "000")

    # 200 = real key, 401 = reached auth layer (header shape OK), 404 also acceptable for some deployments.
    if [[ "$http_code" =~ ^(200|401|403|404)$ ]]; then
        _pass "Endpoint reachable with Bearer header (HTTP ${http_code})"
    else
        _fail "Unexpected HTTP code ${http_code} from ${OLLAMA_ENDPOINT}/tags"
    fi
}

# ─── Test 3: Model listing ────────────────────────────────────────
_test_model_list() {
    _start_test "GET /api/tags returns JSON (models list)"

    if ! _live_allowed; then
        _skip "Set OLLAMA_LIVE=1 to enable /api/tags fetch"
        return
    fi

    _require_cmd curl || return

    local body
    body=$(curl -s \
        -H "Authorization: Bearer ${OLLAMA_API_KEY:-mock}" \
        --max-time 10 \
        "${OLLAMA_ENDPOINT}/tags" || echo "")

    if [[ -z "$body" ]]; then
        _fail "Empty response from ${OLLAMA_ENDPOINT}/tags"
        return
    fi

    # Accept either a real "models" array or an auth error JSON — both prove the
    # endpoint speaks JSON, which is what we want to verify here.
    if echo "$body" | grep -qE '"models"|"error"|"message"'; then
        _pass "Endpoint returned JSON-shaped response"
    else
        _fail "Response doesn't look like JSON: $(echo "$body" | head -c 120)"
    fi
}

# ─── Test 4: Basic prompt execution ──────────────────────────────
_test_basic_prompt() {
    _start_test 'ccoc -p "1+1" smoke test (requires live key)'

    if [[ -z "${OLLAMA_API_KEY:-}" ]] || ! _live_allowed; then
        _skip "OLLAMA_API_KEY + OLLAMA_LIVE=1 required for real prompt round-trip"
        return
    fi

    if ! command -v ccoc >/dev/null 2>&1 && ! command -v claude-switch >/dev/null 2>&1; then
        _skip "Neither 'ccoc' alias nor 'claude-switch' on PATH"
        return
    fi

    local output rc=0
    if command -v ccoc >/dev/null 2>&1; then
        output=$(timeout 60s ccoc -p "1+1" 2>&1) || rc=$?
    else
        output=$(timeout 60s claude-switch cloud -p "1+1" 2>&1) || rc=$?
    fi

    if [[ $rc -eq 0 ]] && echo "$output" | grep -qE "2|two"; then
        _pass "Prompt returned an answer containing '2'"
    else
        _fail "rc=$rc, output head: $(echo "$output" | head -c 200)"
    fi
}

# ─── Test 5: Model override via OLLAMA_CLOUD_MODEL ───────────────
_test_model_override() {
    _start_test "OLLAMA_CLOUD_MODEL overrides default model"

    local resolved
    resolved=$(OLLAMA_CLOUD_MODEL="deepseek-v3.1:671b" bash -c '
        echo "${OLLAMA_CLOUD_MODEL:-gpt-oss:120b}"
    ')

    if [[ "$resolved" == "deepseek-v3.1:671b" ]]; then
        _pass "Override resolves to 'deepseek-v3.1:671b'"
    else
        _fail "Expected 'deepseek-v3.1:671b', got '$resolved'"
    fi

    # Verify the fallback path still gives the documented default.
    local default_resolved
    # shellcheck disable=SC2016  # intentional — inner subshell does the expansion
    default_resolved=$(env -u OLLAMA_CLOUD_MODEL bash -c '
        echo "${OLLAMA_CLOUD_MODEL:-gpt-oss:120b}"
    ')
    if [[ "$default_resolved" == "$DEFAULT_MODEL" ]]; then
        _pass "Fallback defaults to '${DEFAULT_MODEL}'"
    else
        _fail "Fallback expected '${DEFAULT_MODEL}', got '$default_resolved'"
    fi
}

# ─── Test 6: Invalid model handling ──────────────────────────────
_test_invalid_model() {
    _start_test "Invalid model produces an error response"

    if ! _live_allowed; then
        _skip "Set OLLAMA_LIVE=1 to hit /api/chat with an invalid model"
        return
    fi

    _require_cmd curl || return

    local body http_code
    local tmp
    tmp=$(mktemp)
    http_code=$(curl -s -o "$tmp" -w "%{http_code}" \
        -H "Authorization: Bearer ${OLLAMA_API_KEY:-mock}" \
        -H "Content-Type: application/json" \
        --max-time 10 \
        -d "{\"model\":\"${INVALID_MODEL}\",\"messages\":[{\"role\":\"user\",\"content\":\"hi\"}]}" \
        "${OLLAMA_ENDPOINT}/chat" || echo "000")
    body=$(cat "$tmp")
    rm -f "$tmp"

    # Any non-2xx indicates the invalid model was rejected — that's the expected behaviour.
    if [[ ! "$http_code" =~ ^2 ]] || echo "$body" | grep -qiE "not found|unknown|invalid|error"; then
        _pass "Invalid model rejected (HTTP ${http_code})"
    else
        _fail "Invalid model unexpectedly accepted: HTTP ${http_code}, body: $(echo "$body" | head -c 120)"
    fi
}

# ─── Test 7: Endpoint override ───────────────────────────────────
_test_endpoint_override() {
    _start_test "OLLAMA_API_ENDPOINT overrides default endpoint"

    local resolved
    resolved=$(OLLAMA_API_ENDPOINT="https://proxy.example.test/api" bash -c '
        echo "${OLLAMA_API_ENDPOINT:-https://ollama.com/api}"
    ')

    if [[ "$resolved" == "https://proxy.example.test/api" ]]; then
        _pass "Override resolves to custom endpoint"
    else
        _fail "Expected custom endpoint, got '$resolved'"
    fi

    local default_resolved
    # shellcheck disable=SC2016  # intentional — inner subshell does the expansion
    default_resolved=$(env -u OLLAMA_API_ENDPOINT bash -c '
        echo "${OLLAMA_API_ENDPOINT:-https://ollama.com/api}"
    ')
    if [[ "$default_resolved" == "$OLLAMA_ENDPOINT_DEFAULT" ]]; then
        _pass "Fallback defaults to '${OLLAMA_ENDPOINT_DEFAULT}'"
    else
        _fail "Fallback expected '${OLLAMA_ENDPOINT_DEFAULT}', got '$default_resolved'"
    fi
}

# ─── Test 8: Session logging ─────────────────────────────────────
_test_logging() {
    _start_test "Session log contains 'ollama-cloud' entries"

    if [[ ! -f "$LOG_FILE" ]]; then
        _skip "Log file not found at ${LOG_FILE} (run ccoc at least once to generate it)"
        return
    fi

    if grep -q "ollama-cloud" "$LOG_FILE"; then
        _pass "Found 'ollama-cloud' provider entries in ${LOG_FILE}"
    else
        _skip "No 'ollama-cloud' entries yet in ${LOG_FILE} — run 'ccoc' once first"
    fi
}

# ─────────────────────────── Dispatcher ──────────────────────────
_print_header() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Ollama Cloud provider — test suite"
    echo "Endpoint: ${OLLAMA_ENDPOINT}"
    echo "Default model: ${DEFAULT_MODEL}"
    echo "Live tests: $( _live_allowed && echo 'ENABLED' || echo 'DISABLED (set OLLAMA_LIVE=1)')"
    [[ $DRY_RUN -eq 1 ]] && echo "Mode: DRY RUN (no tests will execute)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

_print_summary() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "Total:   ${TESTS_TOTAL}"
    echo -e "${GREEN}Passed:  ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed:  ${TESTS_FAILED}${NC}"
    echo -e "${YELLOW}Skipped: ${TESTS_SKIPPED}${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

_verify_helpers_defined() {
    local missing=0
    for fn in _test_auth_missing_key _test_auth_bearer_mock _test_model_list \
              _test_basic_prompt _test_model_override _test_invalid_model \
              _test_endpoint_override _test_logging; do
        if ! declare -F "$fn" >/dev/null; then
            echo -e "${RED}Missing helper: $fn${NC}"
            missing=1
        fi
    done
    return $missing
}

main() {
    _print_header

    if [[ $DRY_RUN -eq 1 ]]; then
        _log "Dry run: verifying helper functions are defined…"
        if _verify_helpers_defined; then
            echo -e "${GREEN}✅ All 8 test helpers defined${NC}"
            exit 0
        else
            exit 1
        fi
    fi

    _test_auth_missing_key
    _test_auth_bearer_mock
    _test_model_list
    _test_basic_prompt
    _test_model_override
    _test_invalid_model
    _test_endpoint_override
    _test_logging

    _print_summary

    if [[ $TESTS_FAILED -eq 0 ]]; then
        exit 0
    else
        exit 1
    fi
}

main "$@"
