# BUG-004：NEF Traffic Influence trafficRoutes 校验

## 原始问题 / 需求

NEF Traffic Influence subscription 必须拒绝空 trafficRoutes，以及 trafficRoutes 数组中的 null route 元素。请在请求校验阶段返回 malformed request，并补充测试。

## 期望结果

空 trafficRoutes 返回 Missing trafficRoutes；null 元素返回包含索引的 Illegal null route element 错误。
