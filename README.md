# sparky-nano

A minimal GitHub Actions harness that turns [Claude](https://claude.ai) into an autonomous development agent for any repository.

sparky-nano installs two workflow files into your repo. Once set up, you can label an issue to trigger an analysis and plan, approve the plan to kick off implementation, and get automated responses to PR review comments — all driven by Claude.

---

### How it works

sparky-nano runs Claude through three stages, each triggered by a simple GitHub action:

```
Issue opened
     │
     ▼
Label: sparky
     │
     ▼
┌─────────────┐    needs info    ┌──────────────────────────────────┐
│   ANALYZE   │ ───────────────► │  GitHub Discussion (refinement)  │
│ (read-only) │                  │  @sparky <question> on issue     │
└──────┬──────┘                  │  @sparky finalize → posts plan   │
       │                         └──────────────────────────────────┘
       │ plan posted as comment
       ▼
Comment: @sparky implement
       │
       ▼
┌─────────────┐
│  IMPLEMENT  │ ── creates branch, writes code, opens PR
└──────┬──────┘
       │
       ▼
  PR review comments
       │
       ▼
┌─────────────┐
│   REVIEW    │ ── responds to feedback, pushes fixup commits
└─────────────┘
```

| Stage | Trigger | What Claude does |
|-------|---------|-----------------|
| **Analyze** | Add `sparky` label to an issue | Explores the codebase, proposes a plan, posts it as a comment. If clarification is needed, opens a GitHub Discussion and links to it. |
| **Discuss** | Comment `@sparky <question>` on an issue, or use `@sparky` in a linked Discussion | Moves Q&A to a GitHub Discussion, keeping the issue thread clean. `@sparky finalize` in the discussion posts the approved plan back to the issue. |
| **Implement** | Comment `@sparky implement` on the issue | Creates a `sparky/` branch, implements the plan, opens a PR |
| **Review** | Comment `@sparky` on a PR, or add a PR review comment | Addresses feedback with fixup commits |

Refinement Q&A happens in a GitHub Discussion (titled `Sparky Refinement: Issue #N — <title>`) rather than cluttering the issue thread. When you're happy with the plan, comment `@sparky finalize` in the discussion to post it back to the issue, then `@sparky implement` on the issue to kick off implementation.

---

### Setup

**Prerequisites**: You need a local clone of `sparky-nano` and a target repository where you want to install the workflows.

```bash
git clone https://github.com/datashaman/sparky-nano.git
cd sparky-nano
./setup.sh /path/to/your-target-repo
```

`setup.sh` copies three workflow files and `SPARKY.md` into your target repo:

```
your-target-repo/
├── .github/
│   └── workflows/
│       ├── sparky-analyze.yml   ← analyze workflow
│       ├── sparky-respond.yml  ← implement + review workflow
│       └── sparky-discuss.yml  ← discussion refinement workflow
└── SPARKY.md                   ← agent instructions (customize this)
```

> **Note**: If a `SPARKY.md` already exists in your target repo, `setup.sh` will skip it and remind you to merge manually.

Then, in your target repo:

```bash
cd /path/to/your-target-repo
git add .github/workflows/sparky-analyze.yml \
        .github/workflows/sparky-respond.yml \
        .github/workflows/sparky-discuss.yml \
        SPARKY.md
git commit -m "Add Sparky autonomous agent workflows"
git push
```

---

### Target repo requirements

After running `setup.sh`, complete these one-time steps in your target repository:

1. **Add `ANTHROPIC_API_KEY` secret**
   Go to **Settings → Secrets and variables → Actions → New repository secret** and add your Anthropic API key.

2. **Create a `sparky` label**
   Go to **Issues → Labels → New label** and create a label named exactly `sparky`.

3. **Enable GitHub Discussions** (optional, but recommended for refinement Q&A)
   Go to **Settings → Features → Discussions** and enable it. If Discussions are not enabled, Sparky falls back to answering questions directly in issue comments.

4. **Customize `SPARKY.md`** (optional but recommended)
   Open `SPARKY.md` and fill in the **Target Repo Instructions** section at the bottom with project-specific context — see [Customizing SPARKY.md](#customizing-sparkymd) below.

---

### Usage

#### Trigger analysis

1. Open or find an issue in your target repo.
2. Add the `sparky` label.
3. Claude will analyze the issue and post a detailed plan as a comment.

#### Approve implementation

Once you're happy with the plan, comment on the issue:

```
@sparky implement
```

Claude will create a `sparky/`-prefixed branch, implement the plan, and open a pull request.

#### Ask a question or refine a plan

At any point, comment on an issue (without "implement"):

```
@sparky what files would be affected by this change?
```

Claude will move the conversation to a GitHub Discussion (titled `Sparky Refinement: Issue #N — <title>`) and post a link on the issue. Q&A and plan revisions happen there, keeping the issue thread clean.

When you're happy with the plan, comment in the discussion:

```
@sparky finalize
```

This posts the final approved plan back to the issue. Then comment `@sparky implement` on the issue to start implementation.

#### Respond to PR review feedback

On an open PR, either add a pull request review comment or comment:

```
@sparky please address this feedback
```

Claude will push fixup commits to the PR branch.

---

### Customizing SPARKY.md

The `SPARKY.md` file controls how Claude behaves as an agent. The **Target Repo Instructions** section at the bottom is the right place to add project-specific context:

```markdown
## Target Repo Instructions

- Build command: `npm run build`
- Test command: `npm test`
- Lint command: `npm run lint`
- Always run tests before opening a PR
- Key architecture decisions or constraints
```

The rest of `SPARKY.md` contains Sparky's core principles and stage-specific rules. You can adjust these too, but the defaults are designed to be conservative and safe.

---

### Boundaries

By default, Sparky will never:

- Merge pull requests (a human must approve and merge)
- Modify CI/CD pipelines or GitHub Actions workflows
- Commit secrets or credentials
- Make changes exceeding ~500 lines without splitting into smaller PRs

---

*label the issue —*
*a branch blooms in the silence,*
*PR opens wide*
