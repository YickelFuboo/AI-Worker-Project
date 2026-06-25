# REQ-005：UPF Session Handler 返回 PFCP 错误响应能力

## 原始问题 / 需求

UPF 的 PFCP Session Handler 在会话建立、修改或删除处理失败时，应向对端返回符合 PFCP 语义的错误响应，而不是仅记录错误或静默失败。请为 session handler 增加错误响应构造和返回路径。

## 期望结果

session handler 在失败路径构造并发送错误响应，node/session 处理逻辑能表达失败 cause。
