---
name: tdd-workflow
description: Use when writing production code, compilation iteration, or test runs. Enforces the Test-Driven Development (TDD) cycle and the 3-Strike Error Protocol.
---

# Test-Driven Development & Error Recovery Guidelines

## When to use this skill
Use this skill when:
- Modifying logic in production code.
- Running unit or integration tests.
- Compiling code and diagnosing build errors.
- Encountering persistent test failures (applies the 3-Strike Error Protocol).

## How to use it
This skill ensures all production code remains highly testable, cohesive, and decoupled. It enforces the "test-first" methodology and integrates a structured "3-Strike Error Protocol" to prevent agents from falling into blind retry loops during debugging.

---

## ⚖️ The TDD Iron Law

### Core Rule
```
NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.
```

### 🔴 The Delete Punishment
* **Rule**: If implementation code is written before its corresponding failing unit test, the implementation code **must be deleted immediately** without copy-pasting or archiving.
* You must start fresh by writing the test first, then rebuilding the implementation from the failing test context.

### 🟢 Scope & Exceptions
The TDD Iron Law is mandatory for all logic edits. The only exceptions are:
1. **Configuration Files**: Non-logical setups (e.g. `.gitignore`, `tsconfig.json`, `.env.example`).
2. **Pure Types / Declarations**: Interface or type definition files containing zero logical execution block.
3. **Exploratory Spikes (Prototypes)**: Throwaway code written to explore new APIs or libraries. Once the spike is complete, the prototype code **must be deleted**, and the production feature must be built from scratch using the TDD cycle.

---

## 🔄 Red-Green-Refactor Cycle

```
[ Write Failing Test (RED) ] ──> [ Verify Test Failure (Verify RED) ]
             │
             ▼
[ Write Minimal Code (GREEN) ] ──> [ Verify Test Success (Verify GREEN) ]
             │
             ▼
[ Refactor & Clean Up (REFACTOR) ] ──> [ Verify All Tests Remain GREEN ]
```

### 1. 🔴 Write Failing Test (RED)
* **Action**: Write a single, minimal unit test describing one specific target behavior.
* **Verification (Verify RED)**: Run the test suite and watch it fail.
  * Confirm it fails for the **expected reason** (e.g., "method not defined" or "value mismatch").
  * **If the test passes immediately**: you are testing already-existing behavior. The test is invalid — rewrite it to target the missing behavior.
  * **If the test errors** (not fails): fix the error and re-run until it fails correctly.

### 2. 🟢 Write Minimal Code (GREEN)
* **Action**: Write only the simplest production code required to make the failing test pass.
* **Verification (Verify GREEN)**: Run the test suite and confirm it passes.
  * **Evidence Before Claims**: You must run the tests and record the exact success outputs (refer to [verification.md](verification.md) for verification guidelines).
  * Follow YAGNI (You Aren't Gonna Need It). Do not add features or APIs that are not covered by the current failing test.

### 3. 🔵 Refactor & Clean Up (REFACTOR)
* **Action**: With all tests passing (green), refactor both production code and test code to eliminate duplication, improve naming, and simplify design.
* **Verification**: Re-run the tests after every small refactor to guarantee the code remains green.

---

## ⚡ The 3-Strike Error Protocol

When a test failure or compilation error occurs during the TDD loop, do not repeat the failing action. Execute the following structured recovery steps (see [debugging.md](debugging.md) for root-cause tracing details):

```
[ Build/Test Failure Occurs ]
   │
   ├── Strike 1: Diagnose & Fix (Examine trace, perform targeted local edit)
   │     └── If same error persists...
   │
   ├── Strike 2: Alternative Approach (Change logic pathway, tools, or design)
   │     └── If same error persists...
   │
   ├── Strike 3: Broader Rethink (Refactor task_plan, adjust architectures)
   │     └── If same error persists...
   │
   └── [ 🚨 Escalate to User ] (Report findings, logs, and options. Block execution.)
```

* **Strike 1: Diagnose & Fix**
  * Read the traceback or error logs carefully. Perform a targeted, logical correction to address the root cause. Use **Root Cause Tracing** to locate the source of invalid values.
* **Strike 2: Alternative Approach**
  * If the exact same error persists, do not run the same fix again. **You must change your approach**. Try an alternative algorithm, select a different tool/library, or restructure the immediate logic flow.
* **Strike 3: Broader Rethink**
  * If the error is still unresolved, stop coding. Review the requirements. Restructure the plan in `task_plan.md` or decompose the task into smaller sub-tasks. Perform local spike research and log it in `findings.md`.
  * Verify your design against **Defense-in-Depth Validation** (see [debugging.md](debugging.md)) to make bugs structurally impossible.
  * **Architectural Escalation**: If the local test still fails after a broader rethink, it indicates a structural/architectural problem. Transition immediately to the **3-Fix Architecture Check** in [debugging.md](debugging.md) to question design fundamentals before attempting any more fixes.
* **🚨 Escalate to User**
  * If all three strikes fail to resolve the issue, **immediately suspend execution and ask the user for guidance**.
  * Provide the exact error log, a list of the 3 approaches attempted, and options for resolution.

---

## 🔎 When Stuck Diagnostic Table

If you cannot write or pass a test, treat the difficulty as a design signal:

| Problem | What it signals | Fix |
|---|---|---|
| Don't know how to write the test | API design is unclear | Write the wished-for API call first, then derive the assertion |
| Test is too complicated to write | Design is too complicated | Simplify the interface — hard to test = hard to use |
| Must mock everything | Code is too tightly coupled | Introduce dependency injection or inversion of control |
| Test setup is huge | Component has too many responsibilities | Extract helpers; if still complex, decompose the component |
| Test passes immediately | You're testing existing behavior, not new behavior | Rewrite the test to target the missing behavior |
