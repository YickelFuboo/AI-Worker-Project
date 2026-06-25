# REQ-002：SMF 创建 SM Policy Association 时携带 UE Location

## 原始问题 / 需求

SMF 在通过 N7 接口向 PCF 创建 SM Policy Association 时，应在 SmPolicyContextData 中包含 UE 的 UserLocationInfo，使 PCF 能在会话建立阶段应用基于位置的策略。

## 期望结果

SMF 从 SM context 取出 UE location，并填入发送给 PCF 的 SmPolicyContextData。
