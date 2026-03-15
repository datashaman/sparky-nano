#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <target-repo-path>"
  echo ""
  echo "Installs Sparky workflows into a target repository."
  exit 1
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory."
  exit 1
fi

# Create workflows directory
mkdir -p "$TARGET/.github/workflows"

# Copy workflow files
for workflow in sparky-triage.yml sparky-respond.yml; do
  cp "$SCRIPT_DIR/.github/workflows/$workflow" "$TARGET/.github/workflows/$workflow"
  echo "Copied $workflow"
done

# Copy CLAUDE.md only if it doesn't already exist
if [ -f "$TARGET/CLAUDE.md" ]; then
  echo "Skipped CLAUDE.md (already exists — merge manually if needed)"
else
  cp "$SCRIPT_DIR/CLAUDE.md" "$TARGET/CLAUDE.md"
  echo "Copied CLAUDE.md"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Add ANTHROPIC_API_KEY to your repo's Actions secrets"
echo "     Settings -> Secrets and variables -> Actions -> New repository secret"
echo "  2. Create a 'sparky' label in your repo"
echo "     Issues -> Labels -> New label"
echo "  3. Customize CLAUDE.md with your project's build/test commands"
echo "  4. Commit and push the new files"
