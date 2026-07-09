---
name: project-rules
description: Use when structuring project folders, managing dependency references, adding external libraries, or running build / lint gate scripts.
---

# 项目特化编码规约与架构限制 (project-rules.md)

## 📌 概述
本文件定义了本项目的分层依赖方向、第三方库引入门禁、以及 CI/CD 自动发布前的本地门禁指标。大模型在新增任何服务类、引入依赖包或重构包结构时，**必须**遵循此边界。

---

## 🏛️ 分层依赖限制 (Dependency Direction)

本项目遵循严格的**干净架构（Clean Architecture / DDD）**分层模型，依赖方向必须单向向内，严禁反向依赖：

```
[ Presentation (Web / API) ] ──> [ Application (业务编排) ]
             │                                │
             ▼                                ▼
[ Infrastructure (基础设施) ] ──> [ Domain (领域模型/接口) ]
```

1. **Domain 领域层**：
   * 必须保持绝对纯净。
   * **不允许**依赖任何第三方框架（如 EF Core、AutoMapper 或数据库驱动），只能依赖基本的 C# 系统库。
2. **Application 应用层**：
   * 包含业务用例实现，仅依赖 Domain 层。
   * 数据访问、消息队列等通过接口（Interfaces）注入，不允许直接引用基础设施层的具体实现类。
3. **Infrastructure 基础设施层**：
   * 实现 Application/Domain 定义的接口。
   * 允许引入 Entity Framework、Redis、RabbitMQ 等具体物理媒介依赖。

---

## 🚫 外部包引入限制 (Package & Dependency Gate)
* **严禁滥用外部库**：AI 在尝试通过 NuGet / npm 安装新包之前，**必须**向开发者申请许可。
* 严禁为了简写几行逻辑而引入庞大的、未经审计的第三方工具包。

---

## 🧪 本地测试与发布前校验门禁 (Pre-Flight Gate)
在向 `main` 分支提价或发起 Pull Request 前，必须在隔离沙箱中本地成功运行以下命令并达成 100% 通过率：

```bash
# 1. 确保代码格式符合 EditorConfig
dotnet format --verify-no-changes

# 2. 确保没有编译警告（TreatWarningsAsErrors 应开启）
dotnet build -c Release

# 3. 运行所有自动化测试用例，覆盖率不低于 80%
dotnet test --collect:"XPlat Code Coverage"
```
* **阻断规则**：只要上述任意一条命令报错，大模型必须无条件回滚相关修改，转入 `debugging.md` 重新修复，绝不允许带病交付。
