# BUG-001：AMF N1 Message Notify 必填 anN2ApId 校验修正

## 原始问题 / 需求

AMF 在处理 N1 Message Notify 回调时，需要拒绝缺失或非法的 registrationCtxtContainer.anN2ApId。当前实现的判断条件写反，导致 anN2ApId 缺失或非正值时没有被正确拒绝。请修复校验逻辑，保持改动最小。

## 期望结果

当 anN2ApId 缺失、为 0 或非法时返回错误；合法正值可以继续处理。
