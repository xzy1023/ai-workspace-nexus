# Code Review & Acknowledgment Guidelines (code-review.md)

## 📌 Overview & Objectives
This skill establishes a clean separation between the implementation phase and the verification phase. It mandates the use of isolated reviewer subagents to review changes before merging, and outlines strict rules for handling review comments objectively without performative compliance.

---

## 🕐 When to Request Code Review

**Mandatory:**
- After completing a major feature or task
- Before merging any branch to main
- After each task in a subagent-driven development loop

**Optional but high-value:**
- **When stuck**: a fresh reviewer sees what the implementer's blind spots hide
- **Before refactoring**: establishes a clean baseline to compare against
- **After fixing a complex bug**: confirms the fix is correct and hasn't introduced regressions

---

## 🔒 Reviewer Context Isolation (Requesting Review)

To ensure an unbiased review, the code reviewer subagent must not have access to your active session history, chat transcripts, or implementer thoughts. They must evaluate the work product purely from the files and git changes.

### Action Plan:
1. **Locate Git Range**:
   * Identify the base commit SHA (e.g. before the current task started, `origin/main`) and the head commit SHA (current work).
2. **Dispatch Subagent**:
   * Spawn a new, clean-slate `reviewer` subagent (using prompt template in [reviewer.md](../agents/reviewer.md)).
   * Provide only the target requirements (from `task_plan.md`) and the Git range to review.
3. **Read-Only Enforce**:
   * The reviewer subagent must run in **read-only** mode on the codebase. They must never commit, amend, or modify files.

---

## 🚫 No Performative Agreement (Receiving Review)

When receiving code review feedback from either the reviewer subagent or your human partner, follow these behavioral guidelines:

### The Rule
```
NO PERFORMATIVE AGREEMENT. TECHNICAL RIGOR OVER SOCIAL COMFORT.
```

### 1. Forbidden Responses
Never write the following performative or sycophantic replies:
* "You are absolutely right!"
* "Excellent point, thank you!"
* "Thanks for catching that bug!"
* "Sorry about that, let me fix it."
* Any expressions of gratitude, apologies, or personal agreement.

### 2. Required Response Pattern
* **Direct Fix**: If the feedback is valid, simply fix it in the code, verify via tests, and state:
  * `"Fixed [File Path:Line]. Refactored [method] to [change]."`
* **Technical Pushback**: If the feedback is incorrect or contradicts architectural decisions, push back using objective technical data:
  * `"Declining. [File Path:Line] requires this implementation because [technical constraint/test output]."`
* **YAGNI Check (grep first)**:
  * If a reviewer suggests implementing abstractions, endpoints, or features: `grep` the codebase for actual callers.
  * If zero callers: `"Nothing calls this. Removing (YAGNI). Let me know if there's usage I'm missing."`
  * If callers exist: implement properly.
* **Unclear Comments**: If **any** review item is vague, **stop before touching any of them**. Ask for clarification on all unclear items in one message before starting. Items may be related; partial understanding means wrong implementation.

**Example of correct handling when some items are unclear:**
```
You understand items 1, 2, 3, 6. Items 4 and 5 are unclear.
❌ WRONG: Implement 1, 2, 3, 6 now; ask about 4 and 5 later.
✅ RIGHT: "I understand items 1, 2, 3, 6. Need clarification on 4 and 5 before proceeding."
```

### 3. Graceful Correction
If you pushed back and were wrong, state it factually and move on:
* `"You were right — verified [X] and it does [Y]. Implementing now."`
* No long apologies, no defending why you pushed back, no over-explaining.

---

## 📐 Review Resolution Workflow

For multi-item review feedback, prioritize and execute fixes in the following order:
1. **Critical issues**: Security flaws, memory leaks, compilation breaks, data corruption bugs.
2. **Important issues**: Test coverage gaps, lack of error handling, poor separation of concerns.
3. **Minor issues**: Style consistency, code readability, comments, documentation.

Run unit tests after every individual fix to verify no regressions have occurred.
