---
name: api-contracts
description: Use when designing REST API endpoints, writing controllers, configuring authentication scopes, or debugging integration payloads.
---

# API 接口契约与通信规约 (api-contracts.md)

> [!WARNING]
> **Token 管理警告：**
> 如果您的项目包含大量 API 接口，**请不要在 skill 中罗列具体的接口字段定义**（如全量 Swagger/JSON 报文样例）。这会导致上下文膨胀。
> 应该将详细的 Payload 细节及硬件通信协议存放在 `docs/reference/` 下作为静态参考；
> 在本文件中只保留**全局路由规范、异常错误码分流机制以及通用安全机制**。

---

## 🔒 安全鉴权机制

1. **统一 Bearer JWT**：非公开接口必须在请求头中携带 `Authorization: Bearer <JWT_TOKEN>`。
2. **多 Scheme 隔离（如适用）**：
   * `Operator` 终端客户端使用设备密钥或 JWT 进行 API 访问，具有受限的角色范围。
   * `Admin` 网页端在局域网内可启用 SSO / Windows Negotiate 身份认证。

---

## 🌐 路由与版本规约

* **API 前缀**：所有外部暴露的路由必须统一使用小写，并显式包含版本号前缀：
  * ❌ *错误*：`/api/GetUserInfo?id=123`
  * ✅ *正确*：`/api/v1/users/{id}`
* **HTTP 语义约定**：
  * `GET`：查询操作，必须保证幂等和只读。
  * `POST`：创建资源，成功响应应返回 `201 Created` 状态码。
  * `PUT` / `PATCH`：更新资源。
  * `DELETE`：软删除资源。

---

## 📦 统一错误码与异常分流机制

为了统一客户端对异常的处理流程，所有的接口错误必须统一封包。严禁直接抛出裸 500 HTML 页面。

### 1. 业务逻辑层校验失败 (400 Bad Request)
在应用层规则校验未通过时（如余额不足、库存短缺），使用统一的 Result 包装并返回业务错误码：
```json
{
  "success": false,
  "code": "ORDER_ALREADY_CLOSED",
  "message": "当前生产工单已被关闭，无法创建新的托盘 record",
  "data": null
}
```

### 2. 身份/授权校验失败 (401 Unauthorized / 403 Forbidden)
* **401**: 凭证无效或过期。
* **403**: 当前用户无相应功能操作权限（例如缺少 `Supervisor` 角色）。

### 3. 未捕获的系统异常 (500 Internal Server Error)
系统最外层拦截器自动捕获异常并记录 TraceId，向客户端返回脱敏的友好提示：
```json
{
  "success": false,
  "code": "SYSTEM_ERROR",
  "message": "系统出现未预期的错误，请联系系统管理员。TraceId: 8f9a2b...",
  "data": null
}
```
