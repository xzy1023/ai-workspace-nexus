---
name: brainstorming
description: Use when analyzing user requirements, brainstorming design specs, or initiating a task design phase. Enforces the Design Before Code gate.
---

# Collaborative Requirement Clarification & Design

## When to use this skill
Use this skill when:
- Analyzing user requirements.
- Brainstorming design specifications for a new task.
- Initiating the requirement clarification phase.
- Breaking down a large requirement into manageable sub-projects.

## How to use it
This skill guides the transition from a user's initial high-level idea into a validated design spec before any implementation plan is created or code is written. It enforces the "Design before Code" gate, specifies decomposition criteria for large requests, and structures human-agent alignment to avoid wasted development cycles.

---

## 🔒 The Design-Before-Code Hard Gate

```
DO NOT WRITE CODE, SCAFFOLD SCRIPT, OR COMPOSE IMPLEMENTATION PLANS UNTIL A DESIGN SPEC IS VALIDATED AND APPROVED BY THE USER.
```
This rule applies to all tasks. Even for seemingly simple modifications, config updates, or small scripts, you must align on a design first. For trivial tasks, the design may be a single sentence; for complex tasks, it must be a comprehensive document.

---

## 🔄 The Clarification & Specification Lifecycle

Follow these steps sequentially to convert an idea into an approved design:

```
[ Assess Scope & Decompose ] ──> [ Ask Clarifying Questions (One at a time) ]
                                                    │
                                                    ▼
[ Self-Review Spec File ]    <── [ Propose 2-3 Alternative Approaches ]
           │
           ▼
[ User Review Spec Gate ]   ──> [ Invoke planning.md for Implementation Plan ]
```

### 1. Scope Assessment & Decomposition
* Before asking detailed questions, evaluate the task scale.
* If the request describes multiple independent subsystems (e.g., "build database, add authentication, and write frontend UI"), **stop**. Do not refine individual details.
* Guide the user to decompose the request into distinct sub-projects. Spec, plan, and implement the first sub-project completely before starting the next.

### 2. Incremental Clarification
* Ask clarifying questions to resolve ambiguities in requirements, constraints, and success criteria.
* **The Rule**: Ask **exactly one question per message**. Damping a list of 4-5 questions at once overwhelms the user and leads to ignored inputs.
* Prefer providing multiple-choice options (e.g., "Would you prefer A, B, or C?") to streamline responses.

### 3. Alternative Proposals & Trade-offs
* Propose 2-3 alternative approaches for the design.
* Clearly document the pros and cons of each approach.
* Provide your recommendation and explain the technical reasoning behind it.

### 3b. Design for Isolation & Clarity
When designing components or modules, apply these boundaries:
* **One purpose per unit**: Each component, file, or module should have one clear responsibility.
* **Well-defined interfaces**: You should be able to answer for any unit: what does it do, how do you call it, what does it depend on?
* **Independent testability**: Each unit should be understandable and testable without reading other units' internals. If changing the internals requires updating consumers, the boundary needs work.
* **Size as a signal**: When a file or component grows large, that often means it's doing too much. Prefer smaller, focused units you can hold in context at once — your edits are more reliable that way.

### 3c. Working in Existing Codebases
When proposing changes to an existing codebase:
* **Explore before proposing.** Understand the current structure and patterns first.
* **Follow established conventions.** If the codebase uses a certain pattern, continue it unless there is a specific reason to change it.
* **Targeted improvements are acceptable.** If a file you're working in has grown too large or has tangled responsibilities, including a focused cleanup in the design is reasonable — the way a good developer improves code they're already touching.
* **No unrelated refactoring.** Do not propose restructuring code outside the scope of the current goal.

### 4. Design Spec Documentation & Self-Review
* Write the validated design to a local file: `.planning/design.md` (or a project-specific documentation path).
* Run a self-check on the written specification before presenting it for review:
  1. **Placeholder Scan**: Verify there are no "TODOs", "TBDs", or empty sections in the spec.
  2. **Internal Consistency**: Ensure API boundaries and component designs do not contradict each other.
  3. **Scope Check**: Confirm the spec is narrow enough for a single implementation plan. If it covers multiple independent subsystems, stop — decompose before proceeding.
  4. **Ambiguity Check**: Could any requirement be interpreted two different ways? If yes, pick one and make it explicit. Vague requirements produce unexpected implementations.

### 5. User Review Gate
* Commit the spec and request final human verification:
  > `"Spec written and committed to .planning/design.md. Please review the design and let me know if it looks correct before we write the implementation plan."`
* Wait for approval. If changes are requested, update and re-run the self-review checklist. Only proceed once approved.
