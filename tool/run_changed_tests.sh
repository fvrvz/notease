#!/usr/bin/env bash
# ==============================================================================
# Smart Test Runner for NoteEase CI/CD
#
# Runs only the Flutter tests affected by changed files to optimize CI speed.
# Fallbacks to running all tests if:
# 1. Base ref is not supplied or diff is empty (e.g. branch push).
# 2. Core project configuration files changed (pubspec.yaml, analysis_options.yaml).
# 3. Core architectural directories changed (lib/core/, lib/domain/, lib/data/).
# Skips tests completely if only documentation or non-Dart files changed.
# ==============================================================================

set -euo pipefail

BASE_REF="${1:-}"

if [ -z "$BASE_REF" ]; then
  echo "ℹ️ No base ref provided. Running full test suite..."
  flutter test
  exit 0
fi

echo "🔍 Detecting changed files compared to $BASE_REF..."
CHANGED_FILES=$(git diff --name-only "$BASE_REF" 2>/dev/null || git diff --name-only "$BASE_REF"...HEAD 2>/dev/null || echo "")

if [ -z "$CHANGED_FILES" ]; then
  echo "ℹ️ No changed files detected against $BASE_REF. Running full test suite as fallback..."
  flutter test
  exit 0
fi

echo "📄 Changed files:"
echo "$CHANGED_FILES" | sed 's/^/  - /'

# Check if core config files changed
if echo "$CHANGED_FILES" | grep -qE "^(pubspec\.yaml|pubspec\.lock|analysis_options\.yaml|\.github/workflows/flutter_ci\.yml)"; then
  echo "⚙️ Core configuration changed. Running full test suite..."
  flutter test
  exit 0
fi

# Check if core architecture layers changed
if echo "$CHANGED_FILES" | grep -qE "^lib/(core|domain|data)/"; then
  echo "🧱 Core architecture layers (core/domain/data) changed. Running full test suite..."
  flutter test
  exit 0
fi

# Check if any Dart files changed at all
DART_CHANGES=$(echo "$CHANGED_FILES" | grep -E "\.dart$" || true)
if [ -z "$DART_CHANGES" ]; then
  echo "✅ No Dart source or test files changed (only docs/assets/config). Skipping tests to save CI time!"
  exit 0
fi

TESTS_TO_RUN=()

# 1. Directly changed test files
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [[ "$file" =~ ^test/.*_test\.dart$ ]] && [ -f "$file" ]; then
    TESTS_TO_RUN+=("$file")
  fi
done <<< "$DART_CHANGES"

# 2. For each changed lib file, find tests importing or referencing it
while IFS= read -r file; do
  [ -z "$file" ] && continue
  if [[ "$file" =~ ^lib/.*\.dart$ ]]; then
    BASENAME=$(basename "$file")
    # Search all test files for imports or references to this filename
    MATCHED=$(grep -rl --include="*_test.dart" "$BASENAME" test/ 2>/dev/null || true)
    if [ -n "$MATCHED" ]; then
      while IFS= read -r test_file; do
        [ -z "$test_file" ] && continue
        TESTS_TO_RUN+=("$test_file")
      done <<< "$MATCHED"
    fi
  fi
done <<< "$DART_CHANGES"

# Deduplicate test list
UNIQUE_TESTS=()
if [ ${#TESTS_TO_RUN[@]} -gt 0 ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && UNIQUE_TESTS+=("$line")
  done < <(printf "%s\n" "${TESTS_TO_RUN[@]}" | sort -u)
fi

if [ ${#UNIQUE_TESTS[@]} -eq 0 ]; then
  echo "ℹ️ Changed Dart files have no direct importing test files. Running full test suite..."
  flutter test
else
  echo "⚡ Running only affected test suite (${#UNIQUE_TESTS[@]} test file(s)):"
  for t in "${UNIQUE_TESTS[@]}"; do
    echo "  ▶ $t"
  done
  flutter test "${UNIQUE_TESTS[@]}"
fi

