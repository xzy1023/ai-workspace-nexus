---
name: database-schema
description: Use when generating database migrations, writing Entity Framework mappings, querying tables, or updating db schema definitions.
---

# 数据库结构与设计契约 (database-schema.md)

## 📌 概述
本文件用于沉淀当前项目的数据库结构，作为 AI 在编写任何 SQL 语句、Entity Framework 实体映射、Dapper 查询时的**唯一事实来源（Single Source of Truth）**。这能有效杜绝 AI 在字段名、数据类型或外键关联上产生幻觉。

---

## 🗄️ 数据库开发铁律

1. **零字段硬编码**：实体命名与表字段定义必须完全遵循下方列表。如果需要访问新字段，必须先更新此规范或由开发者确认。
2. **软删除约定**：所有业务表统一使用 `IsDeleted` 字段（`bool` 或 `bit` 类型）表示删除状态，绝不允许硬删除（`DELETE FROM`），查询时必须全局过滤 `IsDeleted = 0`。
3. **审计跟踪字段**：
   * `CreatedTime` (DateTime) - 创建时间
   * `UpdatedTime` (DateTime) - 修改时间
   * `CreatedBy` (Guid/string) - 创建人唯一标识
   * `UpdatedBy` (Guid/string) - 更新人唯一标识

---

## 🗺️ 核心数据表结构清单 (请根据项目实际修改)

### 1. 用户表 (`Users`)
* **作用**：存储系统登录账号与用户基础信息
* **字段清单**：
  | 字段名 | 类型 | 约束 | 描述 |
  | :--- | :--- | :--- | :--- |
  | `Id` | `Guid` | PK | 唯一主键 |
  | `Username` | `nvarchar(50)` | Unique, Not Null | 登录用户名 |
  | `PasswordHash` | `varchar(256)` | Not Null | 加密后的密码哈希 |
  | `Email` | `nvarchar(100)` | Nullable | 电子邮箱 |
  | `IsDeleted` | `bit` | Default 0 | 软删除状态 |

### 2. 角色表 (`Roles`)
* **作用**：定义权限角色
* **字段清单**：
  | 字段名 | 类型 | 约束 | 描述 |
  | :--- | :--- | :--- | :--- |
  | `Id` | `Guid` | PK | 主键 |
  | `Code` | `varchar(50)` | Unique, Not Null | 角色代码 (如 Admin, Operator) |
  | `Name` | `nvarchar(50)` | Not Null | 角色显示名称 |

### 3. 用户角色关联表 (`UserRoles`)
* **作用**：维护多对多映射
* **字段清单**：
  | 字段名 | 类型 | 约束 | 描述 |
  | :--- | :--- | :--- | :--- |
  | `UserId` | `Guid` | FK -> Users.Id | 用户 ID |
  | `RoleId` | `Guid` | FK -> Roles.Id | 角色 ID |

---

## ⚙️ 索引与性能规范
* **外键索引**：所有外键列（如 `UserRoles.UserId`）必须显式创建非聚集索引（Non-Clustered Index），严禁在无索引的列上进行高频 `JOIN` 操作。
* **联合索引顺序**：在编写多条件查询时，遵循最左前缀原则（Leftmost Prefixing），并与此规范中声明的联合索引保持一致。
