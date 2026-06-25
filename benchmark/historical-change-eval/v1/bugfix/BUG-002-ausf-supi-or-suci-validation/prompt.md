# BUG-002：AUSF UE Authentication SUPI/SUCI 格式校验

## 原始问题 / 需求

AUSF 处理 UE Authentication 请求时，应先校验 supiOrSuci 是否为合法 SUPI 或 SUCI。非法标识应返回 400 ProblemDetails，并停止后续认证流程。

## 期望结果

入口处复用 SUPI/SUCI validator；非法值返回 MALFORMED_SUPI_OR_SUCI 的 400 响应并立即 return。
