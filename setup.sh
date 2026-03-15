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
for workflow in sparky-analyze.yml sparky-respond.yml; do
  cp "$SCRIPT_DIR/.github/workflows/$workflow" "$TARGET/.github/workflows/$workflow"
  echo "Copied $workflow"
done

# Copy SPARKY.md only if it doesn't already exist
if [ -f "$TARGET/SPARKY.md" ]; then
  echo "Skipped SPARKY.md (already exists — merge manually if needed)"
else
  cp "$SCRIPT_DIR/SPARKY.md" "$TARGET/SPARKY.md"
  echo "Copied SPARKY.md"
fi

echo ""
echo "Done! Next steps:"
echo "  1. Add ANTHROPIC_API_KEY to your repo's Actions secrets"
echo "     Settings -> Secrets and variables -> Actions -> New repository secret"
echo "  2. Create a 'sparky' label in your repo"
echo "     Issues -> Labels -> New label"
echo "  3. Customize SPARKY.md with your project's build/test commands"
echo "  4. Commit and push the new files"
echo ""
echo "How to interact with Sparky:"
echo "  5. Label an issue 'sparky' -> Sparky analyzes it and posts a triage plan"
echo "  6. Comment '@sparky <question>' on an issue -> Ask questions or request plan revisions"
echo "  7. Comment '@sparky implement' on an issue -> Approve the plan and trigger implementation"
echo "  8. Comment '@sparky' on a PR -> Sparky addresses review feedback and pushes fixes"
