---
name: project-conventions
description: Use when writing logic within this specific project, implementing controller methods, creating database entity migrations, or performing local integration tests.
---

# 项目专属开发规约 (project-conventions.md)

## 📌 项目基本信息 & 技术栈
* **服务名称**：[服务名]
* **语言与框架**：[如 C# .NET 8 / EF Core]
* **主要存储介质**：[如 SQL Server / PostgreSQL / Redis]

---

## 🗄️ 数据库开发规约 (Database Schema & Conventions)

### 1. 核心表结构映射
* [表名 A] -> [描述核心作用]
* [表名 B] -> [描述核心作用]

### 2. 字段命名与通用字段
* 所有表必须包含以下审计字段：
  * `CreatedTime` (DateTime) - 创建时间
  * `UpdatedTime` (DateTime) - 修改时间
  * `IsDeleted` (bool) - 软删除标记
* 实体主键统一命名为 `Id` (GUID / long)。

---

## 🔌 API 契约与路由规则 (API Contracts)

* **前缀路由**：所有控制器路由统一为 `[Route("api/v1/[controller]")]`
* **标准 HTTP 动词**：
  * 获取数据 -> `GET`
  * 创建数据 -> `POST`
  * 更新数据 -> `PUT`
  * 删除数据 -> `DELETE`
* **全局异常返回结构**：
```json
{
  "success": false,
  "code": "ERROR_CODE",
  "message": "友好提示错误信息"
}
```

---

## 🏗️ 代码分层与架构限制
* **Domain 领域层**：只包含纯领域模型与核心业务规则，不允许依赖任何外部仓储库（Infrastructure）。
* **Application 应用程序层**：通过 Command/Query 实现用例编排，使用 DTO 进行数据传输。
* **Infrastructure 基础设施层**：具体数据库访问层实现（EF DbContext, Dapper Mapper, Redis Client）。

---

## 🧪 本地测试启动指令
在开始测试前，请确保运行以下基础环境依赖：
```bash
# 启动本地 Redis / DB 镜像
docker-compose up -d

# 运行所有本地测试单元
dotnet test
```
