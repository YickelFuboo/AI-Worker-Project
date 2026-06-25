---
id: chg_fbc
name: 基于流的计费FBC
feature_path:
  - { level: L1, id: cat_charging, name: 计费特性 }
  - { level: L2, id: chg_fbc, name: 基于流的计费FBC }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: high
---

# 特性说明：基于流的计费FBC

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | chg_fbc |
| 特性名 | 基于流的计费FBC |
| 所属 L1 | cat_charging — 计费特性 |
| 状态 | implemented |
| 规范参考 | TS 32.255 |
| 置信度 | high |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：基于业务流的计费 (Rating Group + Service ID)

**业务目标**：围绕 `基于流的计费FBC` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`基于流的计费FBC` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `计费特性` / `基于流的计费FBC` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 32.255 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 基于业务流的计费 (Rating Group + Service ID) |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| chf | 相关架构元素 | architectures/logic_view/elements/chf/spec.md |
| smf | 相关架构元素 | architectures/logic_view/elements/smf/spec.md |
| upf | 相关架构元素 | architectures/logic_view/elements/upf/spec.md |

## 5. 实现现状（事实域）

- `repos/smf/internal/sbi/processor/charging_trigger.go::UpdateChargingSession`：业务流用量上报与计费会话更新

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | 按Rating_Group和Service_ID上报业务流用量 | 正常流程 | [SCENARIO_001_按Rating_Group和Service_ID上报业务流用量_场景流程.md](SCENARIO_001_按Rating_Group和Service_ID上报业务流用量_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | 业务流计费成功 | 计费场景 | [SCENARIO_001_业务流计费成功_场景流程.md](SCENARIO_001_业务流计费成功_场景流程.md) |
| SCENARIO_002 | 计费规则更新 | 计费场景 | [SCENARIO_002_计费规则更新_场景流程.md](SCENARIO_002_计费规则更新_场景流程.md) |
| SCENARIO_003 | 计费上报失败 | 失败场景 | [SCENARIO_003_计费上报失败_场景流程.md](SCENARIO_003_计费上报失败_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
