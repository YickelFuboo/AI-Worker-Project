---
requirement_id: REQ-001-ausf-configurable-nf-instance-id
feature_id: cat_authentication_security
feature_name: 鉴权与安全特性
subfeature_id: sec_snpn_ausf_udm
subfeature_name: 基于AUSF_UDM的SNPN鉴权
scenario_id: SCENARIO_001
change_type: new
mapping_confidence: medium
created: 2026-06-26
---

# 业务变更说明：运维人员为 AUSF 配置稳定 nfInstanceId 后启动

## 1. 变更概述

| 项目 | 内容 |
|------|------|
| 关联需求 | REQ-001-ausf-configurable-nf-instance-id |
| 一级特性 | cat_authentication_security 鉴权与安全特性 |
| 子特性 | sec_snpn_ausf_udm 基于AUSF_UDM的SNPN鉴权 |
| 需求场景 | SCENARIO_001 运维人员为 AUSF 配置稳定 nfInstanceId 后启动 |
| 变更类型 | 新增 |
| 映射置信度 | medium |
| 变更原因 | 当前 AUSF 每次启动生成新的 NF Instance ID，导致 Kubernetes 部署、外部检查、监控和运维追踪难以稳定识别同一个 AUSF 实例。 |

## 2. 场景来源

- 需求文档：`requirements/REQ-001-ausf-configurable-nf-instance-id/requirement.md`
- 来源场景：SCENARIO_001 运维人员为 AUSF 配置稳定 nfInstanceId 后启动
- 来源验收标准：
  - Given AUSF 配置文件中声明了合法 UUID v4 的 `nfInstanceId`，When AUSF 启动并完成自身上下文初始化，Then AUSF 的 NF Instance ID 等于配置文件中的 `nfInstanceId`。
  - Given AUSF 使用配置的 `nfInstanceId` 启动，When 运维人员或外部检查系统读取 AUSF 对外可观察的 NF Instance ID，Then 观察到的 ID 与配置值一致。

## 3. 特性映射说明

| 项 | 内容 |
|----|------|
| 映射到该一级特性的依据 | `鉴权与安全特性` 描述为 5GC 鉴权与安全相关特性，且当前需求明确影响 AUSF 自身 NF Instance ID 的配置和对外可观察身份。 |
| 映射到该子特性的依据 | `基于AUSF_UDM的SNPN鉴权` 是现有资料中明确关联 AUSF 架构元素的子特性之一，可作为 AUSF 相关身份与鉴权上下文能力的候选承载位置。 |
| 其它候选特性/子特性 | 现有特性树未发现直接对应 “AUSF NF Instance ID 配置” 或 “NF 实例标识配置” 的子特性。 |
| 映射风险 | 当前需求不改变 AUSF 鉴权业务流程或 Nausf 服务语义，映射到鉴权子特性只是基于 AUSF 归属和身份相关性，置信度为 medium。 |

## 4. 变更前描述

### 4.1 原业务场景

无现有对应业务场景。

### 4.2 原业务规则

| 规则ID | 描述 |
|--------|------|
| 无 | 现有特性资料未描述通过配置文件为 AUSF 指定稳定 NF Instance ID 的业务规则。 |

## 5. 变更后描述

### 5.1 新业务场景

运维人员或 Kubernetes 部署维护人员可以在 AUSF 配置文件中声明合法 UUID v4 格式的 `nfInstanceId`。AUSF 启动并初始化自身 NF 上下文后，对外使用该配置值作为自身 NF Instance ID，使外部检查、监控和运维追踪能够稳定识别该 AUSF 实例。

### 5.2 新业务流程

| 步骤 | 参与方 | 业务动作 | 可观察结果 | 备注 |
|------|--------|----------|------------|------|
| 1 | 运维人员或部署维护人员 | 在 AUSF 配置文件中填写合法 UUID v4 格式的 `nfInstanceId` | 配置文件包含稳定 NF Instance ID | 配置项为可选项 |
| 2 | AUSF | 启动并初始化自身 NF 上下文 | AUSF 使用配置值作为自身 NF Instance ID | 不改变鉴权业务语义 |
| 3 | 外部检查、监控或运维追踪系统 | 读取 AUSF 对外可观察的 NF Instance ID | 观察到的 ID 与配置值一致 | 具体观察入口待后续阶段确认 |

### 5.3 新业务规则

| 规则ID | 描述 |
|--------|------|
| BR-001 | `nfInstanceId` 是 AUSF 配置文件中的可选配置项。 |
| BR-002 | 当 `nfInstanceId` 已配置且为合法 UUID v4 时，AUSF 必须使用该配置值作为自身 NF Instance ID。 |

## 6. 差异说明

| 项 | 变更前 | 变更后 | 说明 |
|----|--------|--------|------|
| 业务能力 | 无现有对应业务场景 | 支持通过配置文件声明稳定 `nfInstanceId` | 新增 AUSF 身份稳定性配置能力 |
| 触发条件 | AUSF 启动时自动确定自身 NF Instance ID | AUSF 配置文件声明合法 UUID v4 的 `nfInstanceId` 后启动 | 增加配置触发条件 |
| 用户或运维侧可观察结果 | AUSF 重启后 NF Instance ID 可能变化 | AUSF 重启后可观察 NF Instance ID 与配置值一致 | 提升部署可观测性和追踪稳定性 |
| 业务规则 | 未定义配置值优先规则 | 合法配置值优先成为 AUSF NF Instance ID | 对配置值增加业务规则 |
| 验收口径 | 无对应验收口径 | 启动完成后 NF Instance ID 等于配置文件中的 `nfInstanceId` | 新增明确验收口径 |

## 7. 兼容性影响

- 是否影响存量场景：否
- 受影响存量场景清单：未配置 `nfInstanceId` 的存量部署不需要变更配置。
- 兼容性策略：向后兼容

## 8. 后续交接说明

- 本文档只描述业务变更，不固化架构设计、接口设计、代码模块或测试文件。
- 候选架构元素：AUSF；具体架构影响留待后续架构影响域分析确认。
- 待后续确认事项：
  - [ ] `nfInstanceId` 在 AUSF 配置文件中的准确层级位置是否已有约束？
  - [ ] 外部检查或运维追踪读取 AUSF NF Instance ID 的具体观察入口是什么？
