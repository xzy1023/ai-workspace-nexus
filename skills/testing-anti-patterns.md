---
name: testing-anti-patterns
description: Use when writing or refactoring test suites, design-reviewing unit tests, introducing mocks, or checking for test-only code in production files.
---

# Testing Anti-Patterns (testing-anti-patterns.md)

## 📌 Overview & Core Principle
Tests must verify real logical behavior, not mock behavior. Mocks should only be used to isolate external, non-deterministic boundaries, not as the primary target of assertion.

---

## ⚖️ The Iron Laws of Testing
1. **NEVER assert on mock behavior** (verify real outcomes, not the presence of mock instrumentation).
2. **NEVER add test-only methods to production classes** (keep production models clean of test lifecycles).
3. **NEVER mock without fully understanding downstream dependencies**.

---

## ⚠️ Core Anti-Patterns & Refactoring Fixes

### 1. Asserting on Mock Behavior
* **The Violation**: Asserting that a mock component, mock element, or mock function was called/rendered, rather than verifying the actual state transition or side effects.
```typescript
// ❌ BAD: Verifying that a mock test ID exists in the DOM
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByTestId('sidebar-mock')).toBeInTheDocument();
});
```
* **The Fix**: Assert on the actual DOM roles and real page behavior, or don't mock the component if it is local.
```typescript
// ✅ GOOD: Verify real accessibility roles and content transitions
test('renders sidebar', () => {
  render(<Page />);
  expect(screen.getByRole('navigation')).toBeInTheDocument();
});
```

> **Gate Function (Self-Check)**:
> BEFORE asserting on any mock structure, ask:
> *"Am I asserting that the mock system worked, or that the application produced the right output?"*
> If you are asserting mock existence, rewrite the test to assert on the end-user observable state.

---

### 2. Test-Only Methods in Production Code
* **The Violation**: Adding lifecycle methods (like cleanup, resets, or internal state dumpers) directly into production classes just to facilitate test cleanup.
```typescript
// ❌ BAD: destroy() polluted in production Session model
class Session {
  async destroy() { // Only called by afterEach in tests
    await this.workspaceManager.destroyWorkspace(this.id);
  }
}
```
* **The Fix**: Keep production classes stateless or encapsulated. Move cleanups to external test-specific utility helpers.
```typescript
// ✅ GOOD: Cleanup handled in external test helpers
// In test-utils/cleanup.ts:
export async function cleanupSession(session: Session) {
  const workspace = session.getWorkspaceInfo();
  if (workspace) {
    await workspaceManager.destroyWorkspace(workspace.id);
  }
}

// In test file:
afterEach(async () => {
  await cleanupSession(session);
});
```

---

### 3. Mocking Without Dependency Comprehension
* **The Violation**: Mocking high-level modules blindly (e.g. "to make it run faster" or "just to be safe"), breaking implicit side effects that subsequent test steps depend on (such as disk writes or database states).
```typescript
// ❌ BAD: High-level mock breaks duplicate detection that relies on real file cache
vi.mock('ToolCatalog', () => ({
  discoverAndCacheTools: vi.fn().mockResolvedValue(undefined)
}));
```
* **The Fix**: Mock only the lowest-level, slowest, or non-deterministic IO layers (e.g., raw API requests or shell commands), leaving the local coordination and state cache intact.
```typescript
// ✅ GOOD: Mock only the slow startup layer, letting catalog logic execute
vi.mock('MCPServerManager'); // Mock the network/process runner only
```

---

### 4. Incomplete/Partial Mocks
* **The Violation**: Mocking only a subset of property fields that the immediate method reads. When downstream code changes or reads unmocked fields, the test fails silently or crashes in CI.
* **The Fix**: Always mirror the complete, real data structure as defined by interfaces/schemas.
```typescript
// ❌ BAD: Partial mock response
const mockResponse = {
  status: 'success',
  data: { userId: '123' } // Missing metadata used downstream
};

// ✅ GOOD: Complete structural mock response matching schema
const mockResponse = {
  status: 'success',
  data: { userId: '123', name: 'Alice' },
  metadata: { requestId: 'req-999', timestamp: 1234567890 }
};
```

---

## 🚫 Anti-Patterns Quick Reference

| Anti-Pattern | Symptom / Red Flag | Remediation |
| :--- | :--- | :--- |
| **Mock Assertions** | `expect(*mock*).toHaveBeenCalled()` / `getByTestId('*-mock')` | Test real DOM role, visual string, or state change. |
| **Production Pollution** | Methods named `destroy()`, `resetForTest()`, or properties with `forTest` | Move lifecycles to test fixture helpers. |
| **Blind Mocking** | Mock setup is >50% of the entire test file content. | Consider integration tests with real dependencies. |
| **Fragile Mocks** | Minor implementation refactoring breaks mock mappings. | Standardize mocks against official TS Interfaces. |
