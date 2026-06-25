# REQ-011：SMF 支持可选 UE-initiated QoS triggers

## 原始问题 / 需求

SMF 在和 PCF 交互进行策略控制时，需要支持可选的 UE-initiated QoS triggers。请调整 PCF service 中 QoS rule / policy update 构造逻辑，让 UE 触发的 QoS 更新在有对应条件时被正确表达，同时不影响不携带该触发条件的旧流程。

## 期望结果

PCF service 能根据输入条件处理可选 UE-initiated QoS triggers，并保持旧路径兼容。
