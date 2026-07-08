# C# & .NET Engineering Guidelines (csharp-guidelines.md)

---
name: csharp-guidelines
description: Enforce C# / .NET specific code quality, memory management, async programming, and testing standards. Load this skill when working on C# code (.cs, .csproj, .sln).
---

## 📌 Overview
This document outlines the standard coding guidelines, patterns, and optimization practices for C# and .NET core projects. Adhere to these principles whenever writing, refactoring, or reviewing C# codebase.

---

## 💾 Memory & Resource Management (IDisposable)

1. **Proper Disposal**:
   * Always dispose of types implementing `IDisposable` or `IAsyncDisposable`.
   * Prefer **using declarations** (introduced in C# 8.0) for cleaner nesting:
     ```csharp
     // Good (using declaration)
     using var stream = new FileStream(path, FileMode.Open);
     // process stream
     ```
     Instead of legacy block styles, unless scope limiting is explicitly required:
     ```csharp
     // Use only if scope control is needed
     using (var client = new HttpClient())
     {
         // process client
     }
     ```
2. **Factory-created Disposables**:
   * If a factory method returns an `IDisposable`, the caller assumes ownership of the disposal lifecycle. Document ownership transitions clearly.

---

## ⚡ Asynchronous Programming (Async/Await)

1. **Avoid Async Void**:
   * Always return `Task` or `ValueTask` from asynchronous methods.
   * `async void` is **strictly prohibited**, except for UI event handlers. It bypasses exception handling and causes unhandled process crashes.
2. **ValueTask vs Task**:
   * Use `ValueTask` or `ValueTask<T>` for high-throughput hot paths where synchronous completion is common, minimizing garbage collection allocations.
3. **Async Naming Convention**:
   * Append the `Async` suffix to all methods returning `Task`, `ValueTask`, `IAsyncEnumerable<T>`, etc. (e.g. `DownloadFileAsync`).
4. **No Sync-Over-Async**:
   * Never block asynchronous calls using `.Result`, `.GetAwaiter().GetResult()`, or `.Wait()`. This causes thread pool starvation and deadlocks. Always propagate `await` upwards.
5. **CancellationToken Propagation**:
   * Always accept and propagate `CancellationToken` in async APIs to support request cancellation and graceful shutdowns.

---

## 📊 LINQ & Collection Optimizations

1. **Deferred Execution (Deffered vs Materialized)**:
   * Keep in mind that LINQ queries use deferred execution. They are not evaluated until they are iterated over (e.g., via `foreach`, `.ToList()`, or `.Any()`).
   * **Avoid Double Evaluation**: If a LINQ query is evaluated multiple times, materialize it to a list/array first to prevent repeated execution of the query logic:
     ```csharp
     // Bad: executes query twice
     var query = items.Where(x => x.IsActive);
     if (query.Any())
     {
         foreach (var item in query) { ... }
     }

     // Good: materialized first
     var activeItems = items.Where(x => x.IsActive).ToList();
     if (activeItems.Any())
     {
         foreach (var item in activeItems) { ... }
     }
     ```
2. **Allocation Overhead**:
   * Avoid calling `.ToList()` or `.ToArray()` prematurely on hot execution paths where raw loops or indexers (`Span<T>`, `ReadOnlySpan<T>`) could avoid allocations.

---

## 🧪 Testing Standards (.NET Core)

1. **Test Framework**:
   * Standardize on **xUnit** as the primary test runner. Use standard project layouts (`dotnet new xunit`).
2. **Naming Convention**:
   * Name test projects `[ProjectName].Tests`.
   * Unit test methods must follow a clean naming pattern: `[MethodUnderTest]_[StateUnderTest]_[ExpectedBehavior]`.
     * Example: `Withdraw_AmountExceedsBalance_ThrowsInvalidOperationException`.
3. **Mocking Boundaries**:
   * Mock dependencies using interfaces, not concrete classes.
   * Verify mock invocations (e.g., using Moq or NSubstitute) only for behavior/command verification, not for state checks.
