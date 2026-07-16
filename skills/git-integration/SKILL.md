---
name: git-integration
description: Use when completing a task, merging git branches, cleaning up worktrees, or presenting the delivery menu.
---

# Secure Branch Integration & Cleanup

## When to use this skill
Use this skill when:
- Finishing a development branch.
- Merging feature changes back to the base branch.
- Dismantling isolated git worktrees.
- Presenting the delivery menu for code release.

## How to use it
This skill defines the protocol for completing development branches, integrating code back to the main branch, and cleaning up sandbox directories created during task isolation. It prevents merging untested code, avoids directory lock issues in Git worktrees, and protects against accidental data deletion.

---

## 🔒 Pre-Integration Double Verification

Before initiating any merge or integration workflow, you must verify code stability at both stages:

1. **Feature Branch Gate**:
   * Run the project test command (e.g., `dotnet test`, `npm test`) on the active feature branch.
   * If any test fails, **stop**. Do not propose merging or pushing until tests pass.
   * **Evidence Requirement**: Verification of passing tests must adhere strictly to the evidence criteria defined in [verification.md](verification.md) (i.e. output logs showing `0 failures` run in the current turn).
2. **Post-Merge Integration Gate**:
   * Immediately after performing a local merge back to the base branch, run the test suite again on the merged branch.
   * This guards against silent semantic breakages caused by changes on the base branch.
   * **Evidence Requirement**: Must also run the test runner on the merged codebase and record clean verification output.

---

## 🧭 Environment Detection

Identify the active Git structure before proceeding:

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
```

| State | Menu | Cleanup |
|---|---|---|
| `GIT_DIR == GIT_COMMON` (normal repo) | Standard 4 options | No worktree to clean up |
| `GIT_DIR != GIT_COMMON`, named branch | Standard 4 options | Provenance-based (see Worktree Removal Safety) |
| `GIT_DIR != GIT_COMMON`, **detached HEAD** | Reduced **3 options** (no local merge) | No cleanup — externally managed |

Resolve the target base branch (defaulting to `main` or `master`) via:
```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

---

## 📋 The Delivery Menu

**Normal repo or named-branch worktree — present exactly 4 options:**

```
Implementation complete. What would you like to do?

1. Merge back to <base-branch> locally
2. Push and create a Pull Request
3. Keep the branch as-is (I will handle it later)
4. Discard this work

Which option?
```

**Detached HEAD — present exactly 3 options:**

```
Implementation complete. You're on a detached HEAD (externally managed workspace).

1. Push as new branch and create a Pull Request
2. Keep as-is (I'll handle it later)
3. Discard this work

Which option?
```

Keep explanations minimal. Let the user choose the number.

---

## 🛠️ Execution & Safe Cleanup Procedures

### Option 1: Local Merge
1. Switch to the main repository root.
2. Check out the `<base-branch>` and pull the latest changes:
   ```bash
   git checkout <base-branch>
   git pull
   ```
3. Merge the feature branch:
   ```bash
   git merge <feature-branch>
   ```
4. Run integration tests.
5. If successful, remove the worktree safely (see Worktree Removal Safety below), and delete the branch:
   ```bash
   git branch -d <feature-branch>
   ```

### Option 2: Push & PR
* Push the branch to remote origin:
   ```bash
   git push -u origin <feature-branch>
   ```
* **Do NOT delete the worktree or branch**. Keep it active so the user can address review feedback.

### Option 3: Keep As-Is
* Inform the user that the branch and worktree are preserved, and exit.

### Option 4: Discard (Safety Lock)
* Before deleting any commits or directory paths, present a summary of what will be lost and request confirmation:
  ```
  This will permanently delete branch <branch-name> and worktree <path>.
  Type 'discard' to confirm.
  ```
* Wait for the exact text `"discard"`. If confirmed, delete the worktree and run:
  ```bash
  git branch -D <feature-branch>
  ```

---

## 🛠️ Worktree Removal Safety

If the development environment is an isolated worktree, follow these rules to avoid filesystem locks and metadata pollution:

1. **Provenance Gate**: Only remove worktrees that YOU created. If the worktree path is under `.worktrees/` or `worktrees/`, the agent created it and owns cleanup. If the path is elsewhere, the host environment (IDE/harness) owns it — do **not** remove it.
2. **Merge Before Remove**: For Option 1 (local merge), always complete the merge successfully **before** running `git worktree remove`. Deleting a worktree before confirming the merge creates unrecoverable loss.
3. **Remove Before Branch Delete**: Remove the worktree **before** deleting the feature branch. Running `git branch -d` while the worktree still references it will fail.
4. **Change Directory First**:
   * **Never** run `git worktree remove` from inside that worktree. Doing so causes file locks.
   * Always switch to the main repository root first:
     ```bash
     MAIN_ROOT=$(git -C "$(git rev-parse --git-common-dir)/.." rev-parse --show-toplevel)
     cd "$MAIN_ROOT"
     ```
5. **Execute Clean-up**:
   ```bash
   git worktree remove <worktree-path>
   git worktree prune  # Self-healing: clears any stale registrations
   ```

**Options 2 and 3 always preserve the worktree.** The user needs it alive for PR iteration or future work.
