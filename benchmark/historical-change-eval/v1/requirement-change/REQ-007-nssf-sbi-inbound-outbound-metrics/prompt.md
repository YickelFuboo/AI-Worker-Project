# REQ-007：NSSF 增加 SBI 入站/出站指标采集

## 原始问题 / 需求

NSSF 需要增加 SBI 入站和出站请求指标，以便观测 NSSelection、NSSAI Availability 等服务接口的请求量、响应状态和外部调用情况。请在 server/API/consumer/processor 的关键路径接入指标，不改变接口业务行为。

## 期望结果

NSSF 服务启动和 SBI 请求路径接入 metrics，入站 API 和出站 consumer 调用能够被统计。
