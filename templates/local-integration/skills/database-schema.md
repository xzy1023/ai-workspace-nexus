---
name: database-schema
description: Use when generating EF database migrations, writing Entity Framework entity mappings, or designing raw SQL queries.
---

# 数据库核心契约与开发约定 (database-schema.md)

> [!WARNING]
> **Token 管理警告：**
> 如果您的项目数据库包含大量数据表（超过 10 张表），**请不要在此文件中罗列具体的字段明细**。大模型加载该 skill 会耗费大量 Token。
> 推荐的做法是：将详细的表结构存放在 `docs/database/SCHEMA_*.md` 中，作为 AI 仅在需要时通过 `view_file` 自主查阅的参考知识；
> 而在当前文件中，只沉淀**核心实体关系与全局开发铁律**。

## 🗄️ 数据库开发红线

1. **统一软删除**：
   * 所有业务表必须继承或包含 `IsDeleted` 字段（`bit`/`bool`）。
   * 严禁在应用层代码中编写物理删除逻辑（`DELETE` / `dbContext.Remove` 需配合 EF Interceptor 自动转化为软删除）。
2. **自动化审计时间戳**：
   * 写入时自动填充：`CreatedTime` (DateTime), `CreatedBy` (Guid/string)。
   * 修改时自动填充：`UpdatedTime` (DateTime), `UpdatedBy` (Guid/string)。
3. **数据类型契约**：
   * 所有涉及主键/外键的物理 ID 必须统一使用 `Guid` 类型，且由客户端或业务层生成（而非数据库自增），以支持离线生成与断网重连。
   * 所有表示系统状态、配置或规则关联的软连接（如 DowntimeReason、UserRole），必须使用自然键 `string Code`（如 `varchar(50)`）进行弱关联，禁止使用 `Guid`，以便于跨环境同步配置。

---

## 🗺️ 核心表链接指引 (请根据项目实际修改)

详细的数据字典由大模型根据具体任务，通过 `view_file` 工具按需读取以下参考路径：
* [MES 业务数据库设计字典](file:///docs/database/SCHEMA_MES.md) — 包含 Pallets, Orders, Users 表字段细节。
* [ERP 暂存区隔离设计字典](file:///docs/database/SCHEMA_IMPORTDATA.md) — 包含 ImportData 表结构。
