# BUG-007：UDM purgeFlag JSON Patch 操作类型修正

## 原始问题 / 需求

UDM 更新 UE context purgeFlag 时，目标字段可能不存在。JSON Patch 应使用 ADD 而不是 REPLACE，以便字段不存在时也能创建。请修正 3GPP 和 non-3GPP 两条路径。

## 期望结果

两条路径都使用 ADD 操作，保持 path 和 value 不变。
