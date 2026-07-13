---
name: condition-based-waiting
description: Use when writing async tests, encountering flaky test suites, dealing with timing dependencies, or handling asynchronous event streams.
---

# Condition-Based Waiting (condition-based-waiting.md)

## 📌 Overview & Core Principle
Flaky tests are often caused by arbitrary timing guesses (e.g. `sleep(50)` or `setTimeout`). These arbitrary delays cause race conditions where tests pass on local dev machines but fail under high load, CPU throttling, or during concurrent execution in CI.

**Core Principle**: Wait for the *actual state condition* you care about, never guess how long it takes to settle.

---

## ⚡ Core Patterns

### 1. Polling for State vs Arbitrary Sleeping
* **❌ BAD: Guessing at settling duration**
```typescript
await new Promise(r => setTimeout(r, 50)); // Guessed duration
const result = getResult();
expect(result).toBeDefined();
```
* **✅ GOOD: Polling until target condition is met**
```typescript
await waitFor(() => getResult() !== undefined, 'waiting for result definition');
const result = getResult();
expect(result).toBeDefined();
```

---

## 📋 Common Wait Scenarios

| Target State | Polling Condition Pattern |
| :--- | :--- |
| **Event Received** | `waitFor(() => events.some(e => e.type === 'SUCCESS'), 'event success')` |
| **Lifecycle State** | `waitFor(() => service.status === 'ready', 'service initialization')` |
| **Item Count** | `waitFor(() => list.length >= 5, 'items loading')` |
| **File Creation** | `waitFor(() => fs.existsSync(tempFilePath), 'file generation')` |

---

## 🛠️ Reference Polling Implementation

Use a generic polling pattern with a safety timeout and loop backoff:

```typescript
async function waitFor<T>(
  condition: () => T | undefined | null | false,
  description: string,
  timeoutMs = 5000,
  pollIntervalMs = 10
): Promise<T> {
  const startTime = Date.now();

  while (true) {
    const result = condition();
    if (result) return result; // Condition met!

    if (Date.now() - startTime > timeoutMs) {
      throw new Error(`Timeout waiting for [${description}] after ${timeoutMs}ms`);
    }

    // Yield execution context and wait for backoff interval
    await new Promise(resolve => setTimeout(resolve, pollIntervalMs));
  }
}
```

---

## 🚫 Common Pitfalls & Correctives

* **❌ Polling too fast**: Using `setTimeout(check, 1)` or spinning hot in a loop, consuming 100% CPU.
  * **✅ Corrective**: Always introduce a 10ms–50ms backoff interval between poll iterations.
* **❌ Missing timeout**: Infinite loops if the system locks or crashes.
  * **✅ Corrective**: Always enforce an upper bound timeout (default 5000ms) with a descriptive error message.
* **❌ Stale state cache**: Reading a local variable that is cached outside the evaluation function loop.
  * **✅ Corrective**: Always invoke fresh getters or functions inside the polling closure to ensure live data is checked.

---

## ⚖️ When Arbitrary Timeout IS Justified
Arbitrary delays are acceptable **only** when asserting timed behavior (like debouncing or throttling intervals). In such cases:
1. **Always** wait for the initial trigger condition first (ensure the action has started).
2. Use a commented, justified timeout duration.
3. Add a code comment explaining why the exact millisecond duration was selected.
```typescript
await waitForEvent(manager, 'TOOL_STARTED'); // 1. Wait for start condition first
await new Promise(r => setTimeout(r, 200));   // 2. Wait for timed debounce behavior (2 ticks @ 100ms)
```
