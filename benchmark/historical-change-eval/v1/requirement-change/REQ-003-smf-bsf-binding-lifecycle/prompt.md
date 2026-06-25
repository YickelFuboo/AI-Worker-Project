# REQ-003：SMF 集成 BSF Binding 生命周期管理

## 原始问题 / 需求

SMF 需要按照 3GPP TS 29.521 集成 BSF 客户端，在 PDU Session 生命周期中创建和删除 PCF binding。请增加 BSF service consumer，保存 binding ID，并在会话建立/释放流程中完成绑定创建和清理。

## 期望结果

新增 BSF consumer；SM context 记录 binding ID；PDU session 建立时创建 binding，释放时删除 binding。
