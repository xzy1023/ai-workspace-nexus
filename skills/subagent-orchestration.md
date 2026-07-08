# Context-Isolated Subagent Orchestration (subagent-orchestration.md)

## 📌 Overview & Objectives
This skill guides the orchestration and execution of multi-step task checklists via subagent dispatch. To conserve context window tokens and prevent agent confusion, you must isolate execution context by dispatching clean-slate subagents, communicating via files, and tracking durable progress outside conversational memory.

---

## 🔒 Context Separation & Modularity

* **Context Isolation**: When dispatching an implementer or reviewer subagent, **never** pass your active chat history, previous conversational summaries, or user dialogue.
* **Artifact Handoff via Files**:
  * Write task briefs, code diffs, and execution reports to temporary files or the `.planning/` directory.
  * Pass only the **file paths** to the subagent (e.g., `"Read requirements from .planning/task-1-brief.md and write progress to .planning/task-1-report.md"`). This reduces token overhead by 50-100x and avoids memory contamination.

---

## 🎯 Model Selection Tiers
To optimize costs and execution speed, select models based on task complexity. Omitted models inherit the session's default (which is often the most capable and expensive). Always specify the model tier **explicitly**.

**Turn count beats token price.** Cheap models routinely take 2-3× more turns on multi-step work — costing more overall. Use mid-tier as the floor for reviewers and for implementers working from prose descriptions. Reserve the cheapest tier only when the plan contains the complete code to write (transcription tasks) or single-file mechanical fixes.

| Task Complexity | Recommended Model Tier | Trigger Cases |
| :--- | :--- | :--- |
| **Mechanical Transcription / Simple Edits** | Lowest Tier / Fast Model | Touches 1-2 files, instructions fully detailed in brief, zero design judgment needed. |
| **Integration / Complex Debugging** | Mid-Tier / Standard Model | Cross-file coordination, error tracing, test fixes, pattern comparison. Also the minimum floor for most reviewers. |
| **Architectural / Critical Review** | Highest Tier / Most Capable Model | Overall system design, final whole-branch review, security checks, major refactoring. |

---

## ⚡ Parallel Subagent Dispatching

* **Trigger**: Use when facing 2+ independent failures (e.g. failing tests in different files or different broken subsystems) that do not share state or sequential dependencies.
* **Execution**: Issue multiple subagent dispatches concurrently **within a single turn**. Multiple dispatch calls in one response = parallel execution. One dispatch per response = sequential execution.
* **Integration Verification**: Once ALL agents return:
  1. Read each agent's summary and confirm no overlapping file edits
  2. If edits conflict, resolve them manually before running tests
  3. Run the **full** project test suite to verify all fixes integrate cleanly
  4. Spot-check: parallel agents can make systematic errors — do not assume correctness from passing tests alone

---

## ⚡ Continuous Execution Mandate

Do **not** pause to check in with the user between tasks. Execute all tasks from the plan without stopping. The only valid reasons to stop are:
- A **BLOCKED** status the orchestrator cannot resolve
- Genuine ambiguity that prevents progress
- All tasks are complete

"Should I continue?" prompts and mid-run progress summaries waste the user's time. They asked you to execute the plan — execute it.

---

## 🔭 Pre-Flight Plan Conflict Scan

Before dispatching Task 1, scan the plan once for conflicts:
- Tasks that contradict each other or the plan's Global Constraints
- Anything the plan explicitly mandates that the review rubric treats as a defect (e.g., a test block that asserts nothing)

Present everything found as **one batched question** — each conflict beside the plan text that mandates it, asking which governs — before execution begins. If the scan is clean, proceed without comment.

---

## 🔄 The Subagent-Driven Development (SDD) Loop

For each task in the plan, perform the following verification cycle sequentially:

```
[ Extract Task Brief to File ] ──> [ Dispatch Implementer Subagent ]
                                                │
                                                ▼
[ Generate Git Diff Package ] ──> [ Dispatch Reviewer Subagent (Read-only) ]
                                                │
                                                ▼
     ┌────────────────────── [ Review Spec & Code Quality Approved? ]
     │                                     │
     ▼ Yes                                 ▼ No
[ Append to Progress Ledger ]      [ Dispatch Fix Subagent with ALL Findings ]
```

1. **Task Brief**: Write the exact task details, interface imports/exports, and test cases to `.planning/task-N-brief.md`. Pass only the file path to the subagent — never paste plan content inline.
2. **Implementer**: Dispatch a subagent with access to the brief path. The implementer writes its report to `.planning/task-N-report.md` and returns status (`DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, or `BLOCKED`).
3. **Reviewer**: Generate the git diff of the task commits. Dispatch a read-only reviewer with the brief, report, and diff files. The diff must be a **file**, not pasted text.
4. **Fix Cycle**: If the reviewer reports `Critical` or `Important` defects, dispatch **one** fix subagent with the **complete findings list** — never one fixer per finding. Log `Minor` findings in the progress ledger for the final review.
5. **Ledger Update**: Once clean, record completion in the progress ledger (see Durable Progress).

---

## 🚫 Reviewer Dispatch Rules

When constructing reviewer prompts:
- **Do not pre-judge findings.** Never tell a reviewer to ignore an issue, cap its severity ("treat this as Minor at most"), or exclude a concern because the plan chose it. If you believe something is a false positive, let the reviewer raise it and adjudicate in the review loop.
- **Do not ask the reviewer to re-run tests** the implementer already ran on the same code — the implementer's report carries the test evidence.
- **Copy Global Constraints verbatim** from the plan into the reviewer's context. The reviewer's attention is for THIS project's specific requirements, not general process rules.
- **Resolve `⚠️ Cannot verify from diff` items yourself.** These are requirements in unchanged code or spanning tasks that the reviewer cannot see. If a gap is real, treat it as a failed spec review.

---

## 📝 Durable Progress Ledger
AI conversation history does not survive context compaction or resets. To prevent redundant execution of completed tasks (which is the most expensive failure mode for agent loops):

1. **Check Ledger on Startup**: Before dispatching any subagent, read the ledger at `.planning/ledger.jsonl` (or the `task_plan.md` statuses). If a task is marked `completed` and has associated git commits in the log, **do not re-dispatch it**.
2. **Atomic Ledger Logging**: Immediately upon successful task verification, append a single progress line to `.planning/ledger.jsonl`:
   ```json
   {"timestamp": "2026-07-08T16:00:00Z", "task": 1, "status": "complete", "base_sha": "a1b2c3d", "head_sha": "e5f6g7h"}
   ```
3. **Recovery**: If context is lost, read the ledger and run `git log` to reconstruct the exact state of the project.
