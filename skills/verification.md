# Verification Before Completion Guidelines (verification.md)

## 📌 Overview & Objectives
Declaring work is complete without fresh evidence is an engineering failure. This skill mandates that any success, completion, or readiness claim is backed by fresh, unaltered execution outputs.

---

## ⚖️ The Iron Law of Verification
```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
```
1. If you have not run the verification command in the current turn, you cannot claim the feature works, tests pass, or builds succeed.
2. **Mandatory Progress Sync**: Before committing any code (Git Commit) or declaring a task complete, you MUST update all project-specific progress tracking files (e.g. `PROGRESS_TRACKER.md` or other planning trackers in the repo), marking completed tasks as `[x]`. You are strictly forbidden from concluding a session without syncing the project tracker.

---

## 🚧 The Verification Gate

Before stating task status or declaring a phase complete, execute this sequential verification loop:

```
[ Phase Complete / Fix Applied ]
               │
               ▼
1. Identify (Select the terminal command that proves verification)
               │
               ▼
2. Run (Execute the full command fresh in the shell)
               │
               ▼
3. Read & Analyze (Review complete output, check exit codes, check failure counts)
               │
               ▼
4. Verify (Confirm the output matches expected success states)
               │
               ▼
5. Output Evidence (Log execution results in progress.md and output them to the user)
```

---

## 📋 Evidence Definition Checklist

Use this definition table to evaluate what constitutes valid evidence for different claims:

| Target Claim | Required Evidence | Prohibited (Insufficient) Claims |
| :--- | :--- | :--- |
| **"Tests Pass"** | Copy of unit test command output showing `0 failures`, `X passed`. | "Tests should pass", "Tests passed on my last run". |
| **"Build Succeeds"** | Copy of build command output returning `Exit Code 0` with zero warnings/errors. | "Linter passes so it should build", "Logs look clean". |
| **"Bug is Fixed"** | Output showing the failing regression test case is now passing. | "I edited the file, the bug should be resolved". |
| **"Linter is Clean"** | Copy of linter output showing `0 errors` or warning count. | "I fixed formatting, it looks clean". |
| **"Requirements Met"** | Line-by-line mapping of implementation plan items verified against code and test cases. | "Tests pass, therefore all requirements are met". |
| **"Agent completed task"** | Check VCS diff (`git diff` / `git show`) to confirm actual file changes exist. | Accepting the subagent's own success report without auditing. |

---

## 🚨 Verification Red Flags
Stop and re-run your verification commands if you are about to output:
* Vague language: "should", "probably", "seems to", "looks like".
* Expressions of victory before running tests: "Perfect!", "Done!", "Success!".
* Assertions of regression fixes without verifying the red-green transition (failing state first, then passing state).
* Delegating verification by simply accepting subagent completion reports without auditing their file differences.
