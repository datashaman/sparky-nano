# sparky-nano

A minimal GitHub Actions harness that turns [Claude](https://claude.ai) into an autonomous development agent for any repository.

sparky-nano installs two workflow files into your repo. Once set up, you can label an issue to trigger a triage plan, approve the plan to kick off implementation, and get automated responses to PR review comments — all driven by Claude.

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
┌─────────────┐    needs info    ┌──────────────────────┐
│   TRIAGE    │ ───────────────► │  Ask clarifying Qs   │
│ (read-only) │                  └──────────────────────┘
└──────┬──────┘
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
| **Triage** | Add `sparky` label to an issue | Explores the codebase, proposes a plan, posts it as a comment |
| **Implement** | Comment `@sparky implement` on the issue | Creates a `sparky/` branch, implements the plan, opens a PR |
| **Review** | Comment `@sparky` on a PR, or add a PR review comment | Addresses feedback with fixup commits |

You can also ask questions at any point by commenting `@sparky <your question>` on an issue (without "implement") and Claude will respond without modifying any files.

---

### Setup

**Prerequisites**: You need a local clone of `sparky-nano` and a target repository where you want to install the workflows.

```bash
git clone https://github.com/datashaman/sparky-nano.git
cd sparky-nano
./setup.sh /path/to/your-target-repo
```

`setup.sh` copies two workflow files and `CLAUDE.md` into your target repo:

```
your-target-repo/
├── .github/
│   └── workflows/
│       ├── sparky-analyze.yml   ← triage workflow
│       └── sparky-respond.yml  ← implement + review workflow
└── CLAUDE.md                   ← agent instructions (customize this)
```

> **Note**: If a `CLAUDE.md` already exists in your target repo, `setup.sh` will skip it and remind you to merge manually.

Then, in your target repo:

```bash
cd /path/to/your-target-repo
git add .github/workflows/sparky-analyze.yml \
        .github/workflows/sparky-respond.yml \
        CLAUDE.md
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

3. **Customize `CLAUDE.md`** (optional but recommended)
   Open `CLAUDE.md` and fill in the **Target Repo Instructions** section at the bottom with project-specific context — see [Customizing CLAUDE.md](#customizing-claudemd) below.

---

### Usage

#### Trigger a triage

1. Open or find an issue in your target repo.
2. Add the `sparky` label.
3. Claude will analyze the issue and post a detailed plan as a comment.

#### Approve implementation

Once you're happy with the triage plan, comment on the issue:

```
@sparky implement
```

Claude will create a `sparky/`-prefixed branch, implement the plan, and open a pull request.

#### Ask a question

At any point, comment on an issue (without "implement"):

```
@sparky what files would be affected by this change?
```

Claude will explore the codebase and reply — without touching any files.

#### Respond to PR review feedback

On an open PR, either add a pull request review comment or comment:

```
@sparky please address this feedback
```

Claude will push fixup commits to the PR branch.

---

### Customizing CLAUDE.md

The `CLAUDE.md` file controls how Claude behaves as an agent. The **Target Repo Instructions** section at the bottom is the right place to add project-specific context:

```markdown
## Target Repo Instructions

- Build command: `npm run build`
- Test command: `npm test`
- Lint command: `npm run lint`
- Always run tests before opening a PR
- Key architecture decisions or constraints
```

The rest of `CLAUDE.md` contains Sparky's core principles and stage-specific rules. You can adjust these too, but the defaults are designed to be conservative and safe.

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
