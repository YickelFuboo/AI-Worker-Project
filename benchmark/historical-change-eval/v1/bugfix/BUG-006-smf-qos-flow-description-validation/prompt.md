# BUG-006：SMF QoS flow description 校验与触发器设置顺序

## 原始问题 / 需求

SMF 根据 PCF 策略构造 NAS QoS 规则时，CreateNewQoSRule 和 ModifyExistingQoSRuleWithoutModifyingPacketFilters 必须有 QoS flow description。请在需要时校验 flowDesc，并确保 RES_MO_RE trigger 只在校验成功后设置。

## 期望结果

需要 flowDesc 的操作缺失时返回错误；trigger 设置移动到校验通过之后。
