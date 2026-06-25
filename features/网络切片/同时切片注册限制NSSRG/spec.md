---
id: ns_nssrg
name: 同时切片注册限制NSSRG
feature_path:
  - { level: L1, id: cat_network_slicing, name: 网络切片 }
  - { level: L2, id: ns_nssrg, name: 同时切片注册限制NSSRG }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 特性说明：同时切片注册限制NSSRG

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | ns_nssrg |
| 特性名 | 同时切片注册限制NSSRG |
| 所属 L1 | cat_network_slicing — 网络切片 |
| 状态 | planned |
| 规范参考 | TS 23.501 §5.15.15 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：UDM 存 NSSRG 数据，AMF 阻止不允许的并发切片访问

**业务目标**：围绕 `同时切片注册限制NSSRG` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`同时切片注册限制NSSRG` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `网络切片` / `同时切片注册限制NSSRG` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.501 §5.15.15 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | UDM 存 NSSRG 数据，AMF 阻止不允许的并发切片访问 |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| amf | 相关架构元素 | architectures/logic_view/elements/amf/spec.md |
| nssf | 相关架构元素 | architectures/logic_view/elements/nssf/spec.md |
| udm | 相关架构元素 | architectures/logic_view/elements/udm/spec.md |

## 5. 实现现状（事实域）

- 当前特性暂无可确认代码锚点；后续由事实源增量补充。

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | 同时切片注册限制NSSRG主场景 | 主场景 | [SCENARIO_001_Simultaneous_Slice_Registration_Restrictions_(NSSRG)主场景_场景流程.md](SCENARIO_001_Simultaneous_Slice_Registration_Restrictions_(NSSRG)主场景_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | 同时切片注册限制NSSRG准入成功 | 准入场景 | [SCENARIO_001_同时切片注册限制NSSRG准入成功_场景流程.md](SCENARIO_001_同时切片注册限制NSSRG准入成功_场景流程.md) |
| SCENARIO_002 | 同时切片注册限制NSSRG使用受限 | 失败场景 | [SCENARIO_002_同时切片注册限制NSSRG使用受限_场景流程.md](SCENARIO_002_同时切片注册限制NSSRG使用受限_场景流程.md) |
| SCENARIO_003 | 同时切片注册限制NSSRG状态更新 | 迁移场景 | [SCENARIO_003_同时切片注册限制NSSRG状态更新_场景流程.md](SCENARIO_003_同时切片注册限制NSSRG状态更新_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
