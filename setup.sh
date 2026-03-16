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
for workflow in sparky-analyze.yml sparky-respond.yml sparky-discuss.yml; do
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
echo "  3. Enable GitHub Discussions on your repo (optional, but recommended)"
echo "     Settings -> Features -> Discussions"
echo "  4. Customize SPARKY.md with your project's build/test commands"
echo "  5. Commit and push the new files"
echo ""
echo "How to interact with Sparky:"
echo "  6. Label an issue 'sparky' -> Sparky analyzes it and posts a plan"
echo "     (If clarification is needed, Sparky opens a GitHub Discussion)"
echo "  7. Comment '@sparky <question>' on an issue -> Sparky moves Q&A to a Discussion"
echo "  8. Comment '@sparky finalize' in the Discussion -> Posts the approved plan to the issue"
echo "  9. Comment '@sparky implement' on an issue -> Approve the plan and trigger implementation"
echo " 10. Comment '@sparky' on a PR -> Sparky addresses review feedback and pushes fixes"
