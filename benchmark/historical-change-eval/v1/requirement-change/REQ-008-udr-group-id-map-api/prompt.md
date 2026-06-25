# REQ-008：UDR 构建 GroupIdMap API

## 原始问题 / 需求

UDR 需要支持 GroupIdMap 相关 SBI API 路由，使外部 NF 能访问 group id mapping 数据。请新增 GroupIdMap API handler 文件，将路由注册到 SBI server，并在配置中补充对应服务能力。

## 期望结果

新增 GroupIdMap API 文件；server 注册对应路由；配置服务列表包含该 API 能力。
