# REQ-004：PCF 集成 BSF Binding 生命周期管理

## 原始问题 / 需求

PCF 需要按照 3GPP TS 29.521 集成 BSF 客户端，在 SM Policy 生命周期中创建和删除 PCF binding。请增加 BSF service consumer，保存 binding ID，并在策略建立/删除流程中完成绑定创建和清理。

## 期望结果

新增 BSF consumer；UE context 记录 binding ID；SM policy 建立时创建 binding，策略删除时清理 binding。
