---
id: ns_nsacf
name: 网络切片准入控制NSACF
feature_path:
  - { level: L1, id: cat_network_slicing, name: 网络切片 }
  - { level: L2, id: ns_nsacf, name: 网络切片准入控制NSACF }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 特性说明：网络切片准入控制NSACF

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | ns_nsacf |
| 特性名 | 网络切片准入控制NSACF |
| 所属 L1 | cat_network_slicing — 网络切片 |
| 状态 | planned |
| 规范参考 | TS 23.501 §6.2.18, TS 29.536 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：监控并限制每切片 UE 数与 PDU 会话数

**业务目标**：围绕 `网络切片准入控制NSACF` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`网络切片准入控制NSACF` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `网络切片` / `网络切片准入控制NSACF` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.501 §6.2.18, TS 29.536 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 监控并限制每切片 UE 数与 PDU 会话数 |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| smf | 相关架构元素 | architectures/logic_view/elements/smf/spec.md |
| nssf | 相关架构元素 | architectures/logic_view/elements/nssf/spec.md |

## 5. 实现现状（事实域）

- 当前特性暂无可确认代码锚点；后续由事实源增量补充。

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | 网络切片准入控制NSACF主场景 | 主场景 | [SCENARIO_001_Network_Slice_Admission_Control_(NSACF)主场景_场景流程.md](SCENARIO_001_Network_Slice_Admission_Control_(NSACF)主场景_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | 切片配额准入成功 | 准入场景 | [SCENARIO_001_切片配额准入成功_场景流程.md](SCENARIO_001_切片配额准入成功_场景流程.md) |
| SCENARIO_002 | 切片配额不足拒绝 | 失败场景 | [SCENARIO_002_切片配额不足拒绝_场景流程.md](SCENARIO_002_切片配额不足拒绝_场景流程.md) |
| SCENARIO_003 | 配额状态释放 | 释放场景 | [SCENARIO_003_配额状态释放_场景流程.md](SCENARIO_003_配额状态释放_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
