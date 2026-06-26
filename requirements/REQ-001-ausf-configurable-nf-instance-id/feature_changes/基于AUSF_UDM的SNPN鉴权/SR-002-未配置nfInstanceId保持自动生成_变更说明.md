---
requirement_id: REQ-001-ausf-configurable-nf-instance-id
feature_id: cat_authentication_security
feature_name: 鉴权与安全特性
subfeature_id: sec_snpn_ausf_udm
subfeature_name: 基于AUSF_UDM的SNPN鉴权
scenario_id: SCENARIO_002
change_type: modify
mapping_confidence: medium
created: 2026-06-26
---

# 业务变更说明：未配置 nfInstanceId 时 AUSF 保持自动生成行为

## 1. 变更概述

| 项目 | 内容 |
|------|------|
| 关联需求 | REQ-001-ausf-configurable-nf-instance-id |
| 一级特性 | cat_authentication_security 鉴权与安全特性 |
| 子特性 | sec_snpn_ausf_udm 基于AUSF_UDM的SNPN鉴权 |
| 需求场景 | SCENARIO_002 未配置 nfInstanceId 时 AUSF 保持自动生成行为 |
| 变更类型 | 修改 |
| 映射置信度 | medium |
| 变更原因 | 新增可选配置项后，必须明确未配置该项的存量部署仍保持原有自动生成 NF Instance ID 的业务表现。 |

## 2. 场景来源

- 需求文档：`requirements/REQ-001-ausf-configurable-nf-instance-id/requirement.md`
- 来源场景：SCENARIO_002 未配置 nfInstanceId 时 AUSF 保持自动生成行为
- 来源验收标准：
  - Given AUSF 配置文件中未声明 `nfInstanceId`，When AUSF 启动并完成自身上下文初始化，Then AUSF 自动生成 NF Instance ID。
  - Given 现有部署未使用 `nfInstanceId` 配置项，When 升级到支持该配置项的版本后启动 AUSF，Then 不需要额外配置即可保持原有启动行为。

## 3. 特性映射说明

| 项 | 内容 |
|----|------|
| 映射到该一级特性的依据 | `鉴权与安全特性` 覆盖 AUSF 相关安全和身份上下文能力；本场景约束 AUSF 自身 NF Instance ID 的默认行为。 |
| 映射到该子特性的依据 | `基于AUSF_UDM的SNPN鉴权` 的特性资料关联 AUSF 架构元素，可作为 AUSF 相关身份稳定性变更的候选承载位置。 |
| 其它候选特性/子特性 | 现有特性树未发现直接对应 “AUSF 默认 NF Instance ID 生成行为” 的子特性。 |
| 映射风险 | 本场景主要是兼容性保留，不改变鉴权授权成功、失败或安全上下文更新流程，因此映射置信度为 medium。 |

## 4. 变更前描述

### 4.1 原业务场景

AUSF 配置文件未提供 `nfInstanceId` 配置项时，AUSF 启动并初始化自身 NF 上下文后自动生成 NF Instance ID。

### 4.2 原业务规则

| 规则ID | 描述 |
|--------|------|
| BR-OLD-001 | AUSF 启动时自动生成自身 NF Instance ID。 |

## 5. 变更后描述

### 5.1 新业务场景

未启用 `nfInstanceId` 配置项的现有部署方继续沿用原有 AUSF 配置文件。AUSF 启动并初始化自身 NF 上下文时，在未发现 `nfInstanceId` 配置值的情况下继续自动生成 NF Instance ID，保证现有部署无需修改配置即可启动。

### 5.2 新业务流程

| 步骤 | 参与方 | 业务动作 | 可观察结果 | 备注 |
|------|--------|----------|------------|------|
| 1 | 现有部署方 | 沿用未声明 `nfInstanceId` 的 AUSF 配置文件 | 配置文件无需新增字段 | 存量配置继续可用 |
| 2 | AUSF | 启动并初始化自身 NF 上下文 | AUSF 自动生成 NF Instance ID | 保持原有行为 |
| 3 | 运维或外部检查系统 | 观察 AUSF 的 NF Instance ID | 可观察到系统自动生成的 ID | 不保证重启后稳定 |

### 5.3 新业务规则

| 规则ID | 描述 |
|--------|------|
| BR-001 | `nfInstanceId` 是 AUSF 配置文件中的可选配置项。 |
| BR-003 | 当 `nfInstanceId` 未配置时，AUSF 必须保持原有每次启动自动生成 UUID 的行为。 |

## 6. 差异说明

| 项 | 变更前 | 变更后 | 说明 |
|----|--------|--------|------|
| 业务能力 | AUSF 自动生成 NF Instance ID | AUSF 在未配置 `nfInstanceId` 时仍自动生成 NF Instance ID | 明确可选配置项不会破坏默认行为 |
| 触发条件 | AUSF 启动 | AUSF 启动且配置文件未声明 `nfInstanceId` | 默认路径被显式约束 |
| 用户或运维侧可观察结果 | 可观察到自动生成的 NF Instance ID | 可观察到自动生成的 NF Instance ID | 存量可观察结果保持一致 |
| 业务规则 | 自动生成行为为默认行为 | 未配置时自动生成行为被定义为兼容性规则 | 强化向后兼容要求 |
| 验收口径 | 未显式定义升级后兼容验收 | 升级后无需额外配置即可保持原有启动行为 | 新增兼容性验收口径 |

## 7. 兼容性影响

- 是否影响存量场景：否
- 受影响存量场景清单：所有未声明 `nfInstanceId` 的现有 AUSF 部署。
- 兼容性策略：向后兼容

## 8. 后续交接说明

- 本文档只描述业务变更，不固化架构设计、接口设计、代码模块或测试文件。
- 候选架构元素：AUSF；具体架构影响留待后续架构影响域分析确认。
- 待后续确认事项：
  - [ ] 未配置场景下自动生成 UUID 的版本要求是否也必须限定为 UUID v4？
