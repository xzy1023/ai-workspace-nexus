# 项目级本地化特化脚手架 (Project Integration Scaffold)

本目录提供了一套标准的脚手架模板。当您在具体业务项目（例如 `MpMES`）中与 Antigravity 2.0 协作时，可以将本配置放入该业务项目的根目录下，用以注入当前项目的专有业务知识。

---

## 📂 推荐的本地集成结构

在业务项目（如 `MpMES`）根目录下创建 `.gemini/`（或业务指定的本地配置目录），结构如下：

```
业务项目根目录/
  ├── .gemini/
  │     ├── plugin.json                # 本地特化插件声明，继承自全局 ai-workspace-nexus
  │     ├── skills/
  │     │     ├── database-schema.md   # 数据库表结构、核心关联与视图定义
  │     │     ├── api-contracts.md     # 内部与外部 API 签名及调用约定
  │     │     └── project-rules.md     # 当前项目的专属编码规范、依赖约束与发布门禁
  │     └── templates/
  │           └── local_task_plan.md   # 本地特化的简化执行计划模板
```

---

## 📝 核心文件编写模板指引

### 1. [数据表规约] `skills/database-schema.md`
大模型在没有确切数据库结构定义的情况下，很容易写出幻觉字段。您应该在此文件中列出：
* **核心表结构**：表名、字段名、主外键关系、数据类型。
* **开发规约**：是否使用 ORM（如 EF Core/Dapper）、软删除字段名（如 `IsDeleted`）、创建/修改审计时间戳。
* **避坑警告**：例如“切勿在未加索引的列上进行高频关联查询”。

### 2. [接口契约] `skills/api-contracts.md`
定义前后端交互、或微服务之间的契约：
* **路由约定**：控制器命名规则、版本控制（如 `/api/v1/...`）。
* **通用响应结构**：标准返回 JSON 格式（如 `{ code: 200, message: "ok", data: {} }`）。
* **特殊组件**：第三方网关调用（如 ERP 接口、MES 专有硬件通讯）。

### 3. [项目专属规范] `skills/project-rules.md`
全局 `ai-workspace-nexus` 提供了通用的架构原则，而在本项目中：
* **代码目录结构**：业务逻辑写在 Application 层，数据访问写在 Infrastructure 层等。
* **特定编译指令**：本地测试如何启动，是否需要依赖 Docker Compose 运行外部组件。

### 4. [本地任务计划模板] `templates/local_task_plan.md`
定义项目特化的任务执行规约与 TDD 自动化测试断言设计：
* **架构契约表**：明确 Domain、Infrastructure、Application、Presentation 四层的输入消耗与输出产出关系。
* **分层测试指令**：定义各层单元测试、集成测试与端到端控制器测试的具体运行命令和期望断言。

---

## 🚀 如何在业务项目中激活本地特化

1. 将本 `local-integration/` 文件夹复制到您的业务项目根目录下，并重命名为 `.gemini/`。
2. 根据项目的实际业务情况，编写 `skills/` 下的各类业务知识 Markdown。
3. 开启新会话时，Antigravity 会自动合并全局 `ai-workspace-nexus` 的工程规约（TDD、3-Strike、验证证据链）与本项目本地的专有知识，从而产出高度贴合业务的高质量代码。
