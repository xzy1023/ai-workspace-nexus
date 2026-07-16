---
name: git-isolation
description: Use when initiating a new coding task, setting up a branch environment, or preparing git workspaces. Enforces worktree isolation and mandatory user consent.
---

# Git Worktree & Workspace Isolation Guidelines

## When to use this skill
Use this skill when:
- Starting a new coding task.
- Proposing changes to the codebase and checking out feature branches.
- Creating an isolated git worktree environment.

## How to use it
This skill ensures development task isolation, protecting your main working branch from unverified code changes during subagent tasks or parallel features. It outlines how to set up, verify, and dismantle isolated workspaces using git worktrees.

---

## 🔒 Main Branch Protection

```
NEVER start implementation directly on main or master without explicit user consent.
```

All feature work, bug fixes, and experiments must happen on an isolated branch (ideally in a worktree). The only exception is a user who has explicitly said "work directly on main." An assumption is not consent.

---

## 🔍 Execution Workflow

### Step 0: Detect Existing Isolation
Before creating a new worktree, verify if you are already operating in an isolated environment:
1. Run directory checks:
   ```bash
   GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
   GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
   ```
2. **Submodule Check**: Ensure you are not in a submodule (where `GIT_DIR != GIT_COMMON` naturally occurs):
   ```bash
   git rev-parse --show-superproject-working-tree 2>/dev/null
   ```
3. **Evaluation**:
   * If `GIT_DIR != GIT_COMMON` and it is not a submodule, you are **already in a linked worktree**. Proceed with coding. Do not create another nested worktree.
   * If `GIT_DIR == GIT_COMMON`, you are in a normal repository checkout. Proceed to Step 1.

---

### Step 1: Create Isolated Workspace
1. **Native Tools First**: Before using `git worktree add`, check if your platform or harness provides a native workspace creation tool (e.g. a built-in worktree command, `/worktree` slash command, or `EnterWorktree`-style tool). If it exists, **use it instead of raw git commands**. Native tools manage directory placement, branch creation, and cleanup automatically. Using `git worktree add` when a native tool exists creates phantom state the host cannot see or manage.
2. **Mandatory Interactive Consent (No Bypasses)**: Before modifying any files or running build/test commands, you MUST explicitly ask the user to choose the development mode. You are strictly forbidden from assuming, bypassing, or choosing a mode yourself under any circumstances. Present exactly this query to the user and wait for their choice:
   > "The implementation plan is approved. Before I start modifying code, please select the development mode:
   > 1. **Isolated Branch Mode**: I will set up an isolated git worktree for safe development and testing. (Recommended)
   > 2. **Direct Master Mode**: I will directly edit files on the current master/main branch."
3. **Select Directory** (priority order):
   * Explicit user/instructions preference → use that path
   * `.worktrees/` exists in project root → use it
   * `worktrees/` exists in project root → use it
   * Neither exists → default to `.worktrees/` at project root
4. **Safety Verification**:
   * **Mandatory**: Verify that the worktree folder is ignored by git:
     ```bash
     git check-ignore -q .worktrees 2>/dev/null
     ```
   * If the directory is **not ignored**, append `.worktrees/` to `.gitignore` and commit this update first. This prevents committing worktree dependencies or lock files into the main tree.
5. **Add Worktree**:
   ```bash
   git worktree add .worktrees/feature-branch-name -b feature-branch-name
   cd .worktrees/feature-branch-name
   ```
6. **Sandbox Fallback**:
   * If `git worktree` fails due to sandbox security permissions, inform the user and proceed with inline code editing in the current directory.

---

### Step 2: Workspace Setup & Dependency Installation
Upon entering the worktree, run project-specific dependency discovery:
* **Node.js**: Check for `package.json` -> Run `npm install`
* **Python**: Check for `requirements.txt` / `pyproject.toml` -> Run `pip install` / `poetry install`
* **Go**: Check for `go.mod` -> Run `go mod download`
* **.NET/C#**: Check for `.csproj` / `.sln` -> Run `dotnet restore`

---

### Step 3: Establish Clean Baseline
Before making any changes, run the test runner to establish a baseline:
* Run unit tests (e.g. `npm test`, `pytest`, `dotnet test`).
* **If baseline tests fail**: Report these failures immediately to the user. Do not make edits until you align on whether to fix pre-existing errors or skip them.
* **If baseline tests pass**: Record a clean baseline in `progress.md` and begin development.
