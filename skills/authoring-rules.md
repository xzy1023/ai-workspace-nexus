# Guideline & Skill Authoring Standards (authoring-rules.md)

## 📌 Overview & Objectives
This skill defines the standards for writing new rules, developer guidelines, and modular skill files under the `skills/` directory of the workspace. Treating documentation with the same engineering rigor as code ensures that future AI agents working in this repository understand, discover, and obey the guidelines without skipping steps or negotiating instructions.

---

## ⚠️ When NOT to Create a Skill

Create skills only for patterns that are reusable across projects and non-obvious. Do **not** create a skill for:

| Situation | Why |
|---|---|
| One-off solutions specific to a single session | Not reusable — document in `findings.md` or `progress.md` instead |
| Standard practices well-documented elsewhere | Redundant — link to existing documentation |
| Project-specific conventions or team norms | Belongs in the project's own `AGENTS.md` or README, not a global skill |
| Constraints enforceable by tooling | If a linter, type checker, or CI rule can catch it automatically, automate it — save skills for judgment calls that tools can't make |

---

## ⚖️ The Documentation TDD Rule
```
NO SKILL OR RULE SHOULD BE ADDED OR MODIFIED WITHOUT VERIFYING AGENT COMPLIANCE FIRST.
```
Before committing a rule, verify that agents violate the desired behavior in its absence (RED state), apply the minimal rule text (GREEN state), and refine to close loopholes (REFACTOR state).

---

## 📐 Skill Discovery Optimization (SDO)

To ensure that the execution engine and other agents discover the correct guidelines dynamically, adhere to these structural metadata rules:

### 1. Frontmatter Trigger Description
Every skill file must start with a YAML frontmatter block containing a `name` and a `description`:
```yaml
---
name: target-skill-name
description: Use when [specific triggering conditions, symptoms, and context]
---
```
* **Triggering Only**: The description **must only** contain the triggering conditions (e.g., "Use when tests have race conditions orTiming dependencies").
* **No Workflow Summaries**: **Never** summarize the process or checklist in the description (e.g., do not write "Use when executing plans by writing tests first, implementing minimal code, and then committing").
* **Why**: Summarizing the workflow in the description prompts the agent to follow the short description instead of reading the complete guideline document, leading to skipped instructions.

### 2. File Naming Convention
* Use **gerunds** (active verb-first, lowercase with hyphens) for naming files:
  * ✅ `writing-plans.md` instead of `plan-creation.md`
  * ✅ `systematic-debugging.md` instead of `debugging-techniques.md`

### 3. Token Efficiency
* Frequently loaded general skills must be concise and under **200 words** where possible.
* Standard technique or pattern skills must be under **500 words**.
* Move verbose API references, long logs, or helper scripts to separate files or folders to prevent context bloating.

---

## 🔒 Bulletproofing Against Negotiation

When writing discipline-enforcing rules (like TDD, verification, or debugging), close all loopholes to prevent agents from negotiating or rationalizing exceptions under pressure:

1. **No Nuance Clauses**:
   * Forbid soft guidelines. Avoid words like "prefer...", "consider...", "should...".
   * Never append nuance clauses like "unless it matters" or "if necessary". These reopen negotiations. Define exceptions explicitly using observable predicates (e.g., "This rule does not apply to `.env` or configuration files").
2. **Rationalization Table**:
   * Predict the excuses that agents will use to skip the rule (e.g. "Too simple to need tests", "I will write tests after checking the fix") and add an explicit table refuting each excuse.
3. **Red Flags List**:
   * List common bad habits (e.g., "adding features not covered by the failing test", "claiming success without fresh logs") under a "Red Flags" heading, directing the agent to stop and restart the process.

---

## 📐 Match Wording Form to Failure Type

Before writing a rule, classify the type of agent failure to select the correct grammatical form:

* **Discipline Failures** (Agent knows the rule but skips it under stress/sunk cost):
  * **Correct Form**: Prohibitions ("Never..."), Rationalization Tables, and Red Flags.
* **Shape / Formatting Failures** (Agent does the task, but output format is wrong):
  * **Correct Form**: Positive Recipes/Contracts (define exactly what the output IS, its components, and their order).
  * **Why**: Prohibitions on formatting issues backfire; agents spend tokens negotiating the boundaries of "don't". A positive recipe leaves no room for interpretation.
* **Omission Failures** (Agent forgets to include a required element):
  * **Correct Form**: Structural templates with explicitly marked, mandatory fields/placeholders.
* **Conditional Behavior Failures** (Agent should do X only when condition Y is true):
  * **Correct Form**: Conditional keyed to a directly **observable predicate** (e.g., "If the brief file exists, reference it"). A rule that carries exemption clauses ("unless it matters", "if necessary") reopens negotiation — write the exception as its own observable branch instead.
