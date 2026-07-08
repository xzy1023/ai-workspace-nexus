# Systematic Debugging & Root Cause Analysis (debugging.md)

## 📌 Overview & Objectives
This skill ensures technical issues are analyzed systematically. Quick patches mask underlying faults. You must always identify the root cause before attempting fixes, and add multi-layer validation to prevent regression.

---

## ⚖️ The Iron Law of Debugging
```
NO CODE FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.
```
If you do not understand the exact sequence that led to the fault, you are guessing. Symptom-patching is a failure of engineering discipline.

---

## 🔍 Step-by-Step Debugging Cycle

```
[ Error Occurs ]
   │
   ▼
1. Observe Symptom (Note stack traces, line numbers, file paths)
   │
   ▼
2. Reproduce Consistently (Confirm trigger sequence; gather logs)
   │
   ▼
3. Trace Call Chain Backward (Identify trigger source, not just fault point)
   │
   ▼
4. Formulate Hypothesis & Test (Edit 1 variable at a time; verify)
   │
   ▼
5. Implement Defense-in-Depth (API validation, logic, environment, logs)
```

---

## 🔬 Core Protocols

### 1. Backward Root Cause Tracing
Bugs manifest deep in call chains (e.g. database opened with invalid directory, file accessed with empty path). Tracing backward means finding the original input value trigger:
* **The Process**:
  1. Identify where the exception is thrown.
  2. Map the call stack back through caller functions.
  3. Determine the point where invalid state, null value, or empty string was introduced.
  4. Fix the bug at the **source of introduction**, not at the site of symptom.
* **Instrumentation**:
  If the call chain is dynamic or hard to trace, insert explicit stack-trace dumps before the failing call:
  * In JS/TS: `console.error('TRACE:', new Error().stack);`
  * In C#: `Console.Error.WriteLine("TRACE: " + Environment.StackTrace);`
  * In Python: `import traceback; traceback.print_stack()`

### 2. The 3-Fix Architecture Check (The 3-Fixes Rule)
This check is triggered either when Strike 3 of the local TDD loop ([tdd-workflow.md](tdd-workflow.md)) fails to resolve a test error, or when 3 consecutive fixes fail to resolve any general bug or system symptom.

If you attempt a fix and it fails to resolve the issue:
* **Attempts 1 & 2**: Perform targeted, alternate fixes (Strike 1 & Strike 2). Always change your approach, do not run the same fix twice.
* **Attempt 3**: Halt code edits. Re-read specifications and re-evaluate system design (Strike 3).
* **If 3 fixes have failed**:
  * **STOP** coding immediately. This is a signal of an **architectural misalignment**, not a minor bug.
  * Question your fundamentals: Is this pattern sound? Are we fighting the framework? Are we sticking with a flawed design due to inertia?
  * Consult the user with a diagnostic ledger before writing any more code.

### 3. Defense-in-Depth Validation
When a fix is implemented, do not restrict validation to a single location. Make the bug structurally impossible by adding checks at every layer:

| Layer | Purpose | Example |
| :--- | :--- | :--- |
| **Layer 1: Entry Point** | Reject invalid input at public API boundaries | Validate input values, types, and constraints immediately. |
| **Layer 2: Business Logic** | Ensure domain consistency and execution preconditions | Check invariants in managers, services, or repository layers. |
| **Layer 3: Environment** | Prevent context-specific dangers (e.g., test vs. production) | Guard directories (e.g., restrict file modifications to temp directory in tests). |
| **Layer 4: Instrumentation** | Log forensic context for debugging future faults | Emit trace metrics, inputs, and stack state. |

---

## 🧱 Multi-Component Diagnostic Instrumentation

In systems with multiple components (e.g., CI → build → signing, API → service → database), **do not propose fixes before you know which layer is failing**. Add boundary-logging at each component interface first, run once to collect evidence, then analyze.

```bash
# Example: 3-layer pipeline
echo "=== Layer 1 output ===" && echo "VAR: ${VAR:+SET}${VAR:-UNSET}"
echo "=== Layer 2 sees ===" && env | grep VAR || echo "VAR missing"
echo "=== Layer 3 state ===" && <layer3-inspect-command>
```

This reveals the exact boundary where data breaks — then fix that layer.

---

## 🚦 User Redirect Signals

If the user says any of the following, **stop immediately and return to root cause investigation**:

| User says | What it means |
|---|---|
| "Is that not happening?" | You assumed without verifying |
| "Will it show us...?" | You skipped diagnostic evidence gathering |
| "Stop guessing" | You're proposing fixes without understanding the cause |
| "Ultra-think this" | Question fundamentals, not just symptoms |
| "We're stuck?" (frustrated) | Your current approach isn't working |
