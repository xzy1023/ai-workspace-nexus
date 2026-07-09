# [功能名称] 项目特化执行计划

**目标**：[描述本功能的业务价值与端到端交付状态]

---

## 🏗️ 架构契约与逻辑流 (C consumes / P produces)

在各分层开发前，先对齐依赖签名：

| 开发层次 | 核心改动类 / 文件路径 | 消耗输入 (Consumes) | 产出契约 (Produces) |
| :--- | :--- | :--- | :--- |
| **Domain 领域层** | `Domain/Entities/...` | 无 | 领域模型实体、领域事件定义 |
| **Infrastructure 基础设施层** | `Infrastructure/Repositories/...` | Database Schema | 仓储库具体实现类 |
| **Application 应用层** | `Application/Commands/...` | 领域接口与 DTO | 命令处理逻辑、领域事件分发 |
| **Presentation 接口层** | `Presentation/Controllers/...` | HTTP DTO payload | 标准封包 JSON (REST API) |

---

## 🧪 自动化测试与验证清单

每一个 Task 执行时必须伴随以下测试门禁验证：

- [ ] **Task 1: 领域层逻辑与单元测试**
  * **测试文件**：`Tests/DomainTests/...`
  * **断言设计**：[写出核心 Assert 逻辑代码块]
  * **执行指令**：`dotnet test --filter Category=Unit`
- [ ] **Task 2: 基础设施访问与集成测试**
  * **测试文件**：`Tests/IntegrationTests/...`
  * **断言设计**：[写出验证真实 DB 读写的 Assert 代码块]
  * **执行指令**：`dotnet test --filter Category=Integration`
- [ ] **Task 3: REST API 控制器端到端测试**
  * **测试文件**：`Tests/APITests/...`
  * **断言设计**：[写出验证 HTTP Status Code 200/201/400 响应结构的 Assert 代码块]
  * **执行指令**：`dotnet test --filter Category=API`
