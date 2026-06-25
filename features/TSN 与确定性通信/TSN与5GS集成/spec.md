---
id: tsn_integration
name: TSN与5GS集成
feature_path:
  - { level: L1, id: cat_tsn_deterministic, name: TSN 与确定性通信 }
  - { level: L2, id: tsn_integration, name: TSN与5GS集成 }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 特性说明：TSN与5GS集成

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | tsn_integration |
| 特性名 | TSN与5GS集成 |
| 所属 L1 | cat_tsn_deterministic — TSN 与确定性通信 |
| 状态 | planned |
| 规范参考 | TS 23.501 §5.27, TS 23.502 §4.4.8 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：5GS 作为 TSN 网桥接入 IEEE 802.1 TSN 网络

**业务目标**：围绕 `TSN与5GS集成` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`TSN与5GS集成` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `TSN 与确定性通信` / `TSN与5GS集成` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.501 §5.27, TS 23.502 §4.4.8 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 5GS 作为 TSN 网桥接入 IEEE 802.1 TSN 网络 |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| upf | 相关架构元素 | architectures/logic_view/elements/upf/spec.md |

## 5. 实现现状（事实域）

- 当前特性暂无可确认代码锚点；后续由事实源增量补充。

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | TSN与5GS集成主场景 | 主场景 | [SCENARIO_001_TSN_Integration_with_5GS主场景_场景流程.md](SCENARIO_001_TSN_Integration_with_5GS主场景_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | TSN与5GS集成业务成功 | 成功场景 | [SCENARIO_001_TSN与5GS集成业务成功_场景流程.md](SCENARIO_001_TSN与5GS集成业务成功_场景流程.md) |
| SCENARIO_002 | TSN与5GS集成业务失败 | 失败场景 | [SCENARIO_002_TSN与5GS集成业务失败_场景流程.md](SCENARIO_002_TSN与5GS集成业务失败_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
