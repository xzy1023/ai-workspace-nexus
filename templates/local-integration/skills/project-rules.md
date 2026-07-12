---
name: project-rules
description: Use when writing or reviewing code in the core backend, api, or contract projects. Covers project-specific layer boundaries, CQRS conventions, and custom validation policies.
---

# 项目特化编码规约与架构限制 (project-rules.md)

> 全局 C# 最佳实践（如 Primary Constructors 强制用、Sealed by Default、TimeProvider 注入、EF Core N+1 避免、DI Scope 保护、PeriodicTimer 用法、FluentAssertions + NSubstitute 测试标准、TDD 三击协议）均已由全局 `csharp-guidelines.md` 覆盖。**本文件仅声明当前项目专属的架构边界与特化重写**。

## 🌿 分支前缀与提交规范
* **分支命名**：`feature/[TaskID]-[Description]` 或 `fix/[TaskID]-[BugName]`（需与项目排期/Issue Tracker 关联）。
* **提交作用域 (Commit Scope)**：Conventional Commits 必须匹配对应的底层模块/项目（如 `feat(domain): add UserEntity`）。

---

## 🏛️ 项目分层与依赖方向红线 (Dependency Boundaries)

本项目遵循 Clean Architecture / DDD 设计，严格限制层级引用流向：

```
[ Presentation (Web / API) ] ──> [ Application (业务编排) ]
             │                                │
             ▼                                ▼
[ Infrastructure (基础设施) ] ──> [ Domain (领域模型) ]
```

1. **领域层 (`Project.Domain`)**：
   * **绝对纯净**：不允许依赖 EF Core、MediatR、Redis 或任何特定外部数据库客户端。只能是纯 C# 模型与领域接口。
2. **应用层 (`Project.Application`)**：
   * **仓储隔离**：不允许直接引用 EF 的 `DbContext` 或 Redis 实例。必须通过应用层接口（如 `IUnitOfWork`、`IRepository`）进行松耦合注入。
3. **接口呈现层 (`Project.Presentation` / `Project.Api`)**：
   * **DTO 隔离**：Controller 绝不允许直接返回 Domain 实体以防止数据库 Schema 泄漏。所有对外传输数据必须使用 `Contracts` 层定义的 DTO。

---

## 📦 CQRS 与数据契约规范

如果本项目采用了 CQRS (Command Query Responsibility Segregation) 架构：
* **Requests (输入入参)**：用于 API 输入和前端 Form 绑定的模型，必须使用 **属性样式 `{ get; set; }`**，以便兼容各类反序列化器与表单双向绑定。
* **DTOs (输出出参)**：只读的数据返回对象，必须使用 **C# Positional record 语法** (`public record UserDto(Guid Id, string Name)`) 以保证传输过程中的不可变性。
* **读写分离**：Query（查询）处理器必须显式禁用追踪（如 `.AsNoTracking()`），且严禁在其内部调用 `SaveChangesAsync()` 等数据写回操作。

---

## 🛡️ 数据合法性验证 (Validation Gate)

本项目执行**双层验证隔离机制**：
1. **Stateless 第一层验证 (`Project.Validators`)**：纯内存数据格式检查（非空、长度、正则匹配等），不允许引入数据库依赖。
2. **Stateful 第二层验证 (`Project.Application`)**：通过 FluentValidation 异步管道或 Handler 内部逻辑进行，允许查询数据库（例如检查用户名是否重复、外键 ID 是否真实存在）。

---

## 🧪 项目特化测试规约

> 通用的 xUnit runner、FluentAssertions/NSubstitute 使用方法以及 AAA 测试结构均继承自全局规则。

* **数据库测试隔离**：本地集成测试**严禁使用 InMemoryDatabase**。必须使用真实的临时/测试数据库（如本地开发 SQL Server 或 Docker Testcontainers），并通过在基类 Fixture 中包裹 `TransactionScope` 实现测试后的自动 `Rollback`。
* **Mock 边界**：在单元测试中只 Mock 基础设施（如第三方短信网关、文件服务），对于本项目的 Domain 业务实体和 Domain Service 必须使用真实对象进行断言。
