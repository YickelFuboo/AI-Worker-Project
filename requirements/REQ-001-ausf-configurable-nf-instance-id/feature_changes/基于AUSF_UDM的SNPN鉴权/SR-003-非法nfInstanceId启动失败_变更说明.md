---
requirement_id: REQ-001-ausf-configurable-nf-instance-id
feature_id: cat_authentication_security
feature_name: 鉴权与安全特性
subfeature_id: sec_snpn_ausf_udm
subfeature_name: 基于AUSF_UDM的SNPN鉴权
scenario_id: SCENARIO_003
change_type: new
mapping_confidence: medium
created: 2026-06-26
---

# 业务变更说明：配置的 nfInstanceId 不是合法 UUID v4

## 1. 变更概述

| 项目 | 内容 |
|------|------|
| 关联需求 | REQ-001-ausf-configurable-nf-instance-id |
| 一级特性 | cat_authentication_security 鉴权与安全特性 |
| 子特性 | sec_snpn_ausf_udm 基于AUSF_UDM的SNPN鉴权 |
| 需求场景 | SCENARIO_003 配置的 nfInstanceId 不是合法 UUID v4 |
| 变更类型 | 新增 |
| 映射置信度 | medium |
| 变更原因 | 需要避免 AUSF 使用非法格式或非 UUID v4 的 NF Instance ID，保证配置错误能在启动阶段被发现并反馈给运维人员。 |

## 2. 场景来源

- 需求文档：`requirements/REQ-001-ausf-configurable-nf-instance-id/requirement.md`
- 来源场景：SCENARIO_003 配置的 nfInstanceId 不是合法 UUID v4
- 来源验收标准：
  - Given AUSF 配置文件中声明了非法格式或非 UUID v4 的 `nfInstanceId`，When AUSF 启动并读取配置，Then AUSF 启动失败并提示 `nfInstanceId` 配置错误。

## 3. 特性映射说明

| 项 | 内容 |
|----|------|
| 映射到该一级特性的依据 | `鉴权与安全特性` 涵盖 AUSF 相关身份、安全和鉴权上下文能力；本场景约束 AUSF 自身 NF Instance ID 的合法性。 |
| 映射到该子特性的依据 | `基于AUSF_UDM的SNPN鉴权` 是当前资料中明确关联 AUSF 架构元素的子特性，可作为 AUSF 身份相关配置校验场景的候选承载位置。 |
| 其它候选特性/子特性 | 现有特性树未发现直接对应 “AUSF NF Instance ID 配置校验” 的子特性。 |
| 映射风险 | 本场景是配置合法性和启动失败反馈，不改变鉴权失败的业务语义或运行期鉴权接口契约，因此映射置信度为 medium。 |

## 4. 变更前描述

### 4.1 原业务场景

无现有对应业务场景。

### 4.2 原业务规则

| 规则ID | 描述 |
|--------|------|
| 无 | 现有特性资料未描述 AUSF 配置文件中 `nfInstanceId` 非法格式或非 UUID v4 时的启动失败规则。 |

## 5. 变更后描述

### 5.1 新业务场景

运维人员在 AUSF 配置文件中声明 `nfInstanceId`，但该值不是合法 UUID v4。AUSF 启动读取配置后，不使用该非法值继续启动，而是启动失败并提示 `nfInstanceId` 配置错误，避免系统对外暴露不符合约束的 NF Instance ID。

### 5.2 新业务流程

| 步骤 | 参与方 | 业务动作 | 可观察结果 | 备注 |
|------|--------|----------|------------|------|
| 1 | 运维人员 | 在 AUSF 配置文件中填写非法格式或非 UUID v4 的 `nfInstanceId` | 配置文件包含不合法配置值 | 可能是格式错误或 UUID 版本错误 |
| 2 | AUSF | 启动时读取该配置项 | 识别为配置错误 | 不进入使用该值标识自身的业务结果 |
| 3 | AUSF | 停止启动并提示配置错误 | 运维人员可观察到 `nfInstanceId` 配置错误 | 具体错误文案或错误码由后续阶段确定 |

### 5.3 新业务规则

| 规则ID | 描述 |
|--------|------|
| BR-004 | `nfInstanceId` 的合法配置值必须满足 UUID v4 格式。 |
| BR-005 | 当 `nfInstanceId` 已配置但格式非法或不是 UUID v4 时，AUSF 必须启动失败并提示配置错误。 |

## 6. 差异说明

| 项 | 变更前 | 变更后 | 说明 |
|----|--------|--------|------|
| 业务能力 | 无现有对应业务场景 | 支持识别非法 `nfInstanceId` 配置并阻止启动 | 新增配置合法性保护场景 |
| 触发条件 | 无 | AUSF 配置文件声明非法格式或非 UUID v4 的 `nfInstanceId` | 新增错误配置触发条件 |
| 用户或运维侧可观察结果 | 无明确配置错误反馈要求 | AUSF 启动失败并提示 `nfInstanceId` 配置错误 | 提升配置错误可诊断性 |
| 业务规则 | 未定义 `nfInstanceId` 合法性约束 | 合法值必须是 UUID v4，非法值导致启动失败 | 新增合法性和失败规则 |
| 验收口径 | 无对应验收口径 | 非法配置启动时必须失败并提示配置错误 | 新增失败路径验收口径 |

## 7. 兼容性影响

- 是否影响存量场景：否
- 受影响存量场景清单：仅影响主动声明非法 `nfInstanceId` 的配置场景；未声明该配置项的存量部署不受影响。
- 兼容性策略：向后兼容

## 8. 后续交接说明

- 本文档只描述业务变更，不固化架构设计、接口设计、代码模块或测试文件。
- 候选架构元素：AUSF；具体架构影响留待后续架构影响域分析确认。
- 待后续确认事项：
  - [ ] 配置错误提示是否需要固定文案、错误码或日志级别？
  - [ ] 是否需要对配置来源或日志暴露做额外安全约束？
