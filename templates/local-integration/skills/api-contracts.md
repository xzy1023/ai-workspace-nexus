---
name: api-contracts
description: Use when creating REST API controllers, designing payload DTOs, configuring authentication policies, or documenting client-server communication contracts.
---

# API 接口契约与通信规约 (api-contracts.md)

## 📌 概述
本文件定义了本项目中所有 REST API 的路由规范、身份鉴权机制、输入验证规则及标准 JSON 响应结构。AI 在编写控制器（Controller）或路由分发器时，**必须**严格遵循此契约。

---

## 🔒 身份鉴权与安全
1. **Bearer Token 验证**：所有受保护的 API 必须在 HTTP 请求头中携带 `Authorization: Bearer <token>`。
2. **鉴权注解**：对于非公开接口，控制器类或方法上必须挂载 `[Authorize]`（C#）或相对应的权限中间件拦截器，严禁裸露敏感接口。

---

## 🌐 路由与版本控制

* **路由命名规约**：统一采用小驼峰（camelCase）或小写蛇形（kebab-case）命名，且必须包含 API 版本号前缀。
  * ❌ *错误*：`/api/GetUserInfo?id=123`
  * ✅ *正确*：`/api/v1/users/{id}`
* **HTTP 动词选择规范**：
  * `GET`：安全且幂等的查询操作，不允许修改任何系统状态。
  * `POST`：创建新资源，响应应返回 201 Created 及资源主键。
  * `PUT`：全量更新已存在的资源。
  * `DELETE`：软删除指定资源。

---

## 📦 统一响应数据结构

所有 API 响应统一封包为以下 JSON 格式。不允许返回裸原始数据或非结构化文本：

### 1. 成功响应结构 (200 OK / 201 Created)
```json
{
  "success": true,
  "code": "SUCCESS",
  "message": "操作成功",
  "data": {
    "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
    "username": "admin"
  }
}
```

### 2. 失败与异常响应结构 (400 Bad Request / 500 Error)
* 在返回错误时，必须提供可读的业务代码（Code）与友好提示（Message）：
```json
{
  "success": false,
  "code": "USER_NOT_FOUND",
  "message": "指定的用户账号不存在，请检查后重试",
  "data": null
}
```

---

## 🛡️ 数据合法性验证 (Validation Gate)
* AI 编写的 DTO / Model 必须包含声明式属性验证。
* 任何业务逻辑处理前，必须进行 `ModelState.IsValid` 校验。如果不合法，立即返回 400 Bad Request 伴随相应的验证错误明细。
