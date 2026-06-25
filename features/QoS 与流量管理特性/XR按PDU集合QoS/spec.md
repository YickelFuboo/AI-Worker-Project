---
id: qos_xr_per_pdu_set
name: XR按PDU集合QoS
feature_path:
  - { level: L1, id: cat_qos_traffic, name: QoS 与流量管理特性 }
  - { level: L2, id: qos_xr_per_pdu_set, name: XR按PDU集合QoS }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 特性说明：XR按PDU集合QoS

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | qos_xr_per_pdu_set |
| 特性名 | XR按PDU集合QoS |
| 所属 L1 | cat_qos_traffic — QoS 与流量管理特性 |
| 状态 | planned |
| 规范参考 | TS 23.501 §5.33 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：针对扩展现实流量的 per-PDU-set 处理，拥塞时优先关键包

**业务目标**：围绕 `XR按PDU集合QoS` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`XR按PDU集合QoS` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `QoS 与流量管理特性` / `XR按PDU集合QoS` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.501 §5.33 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 针对扩展现实流量的 per-PDU-set 处理，拥塞时优先关键包 |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| smf | 相关架构元素 | architectures/logic_view/elements/smf/spec.md |
| pcf | 相关架构元素 | architectures/logic_view/elements/pcf/spec.md |

## 5. 实现现状（事实域）

- 当前特性暂无可确认代码锚点；后续由事实源增量补充。

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | XR按PDU集合QoS主场景 | 主场景 | [SCENARIO_001_XR_Per-PDU-Set_QoS主场景_场景流程.md](SCENARIO_001_XR_Per-PDU-Set_QoS主场景_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | XR按PDU集合QoS策略生效 | 成功场景 | [SCENARIO_001_XR按PDU集合QoS策略生效_场景流程.md](SCENARIO_001_XR按PDU集合QoS策略生效_场景流程.md) |
| SCENARIO_002 | XR按PDU集合QoS策略调整 | 迁移场景 | [SCENARIO_002_XR按PDU集合QoS策略调整_场景流程.md](SCENARIO_002_XR按PDU集合QoS策略调整_场景流程.md) |
| SCENARIO_003 | XR按PDU集合QoS保障失败 | 失败场景 | [SCENARIO_003_XR按PDU集合QoS保障失败_场景流程.md](SCENARIO_003_XR按PDU集合QoS保障失败_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
