# BUG-005：NSSF NSSelection registration 嵌套参数校验

## 原始问题 / 需求

NSSF 处理 NSSelection registration 请求时，需要校验 subscribedNssai[].subscribedSnssai 是否存在，以及 mappingOfNssai 每个元素是否同时包含 servingSnssai 和 homeSnssai。缺失时返回 400 ProblemDetails。

## 期望结果

缺失 subscribedSnssai 时返回带 InvalidParams 的 400；mappingOfNssai 元素不完整时返回 400。
