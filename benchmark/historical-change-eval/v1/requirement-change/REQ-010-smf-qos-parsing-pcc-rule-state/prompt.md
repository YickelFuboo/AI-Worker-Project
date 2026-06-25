# REQ-010：SMF 校验 QoS 解析并维护 PCC Rule 状态

## 原始问题 / 需求

SMF 在处理 UE 发起或策略驱动的 QoS 相关消息时，需要校验 QoS rule 解析结果，并正确维护 PCC rule 状态，避免解析失败或状态不同步导致后续策略更新异常。请在 GSM handler 的相关路径中补充解析校验和 PCC rule 状态管理。

## 期望结果

SMF 对 QoS 解析结果做校验，并在相关流程中更新/维护 PCC rule 状态。
