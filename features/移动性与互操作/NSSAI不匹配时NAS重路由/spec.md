---
id: mob_nssai_reroute
name: NSSAI不匹配时NAS重路由
feature_path:
  - { level: L1, id: cat_mobility_interworking, name: 移动性与互操作 }
  - { level: L2, id: mob_nssai_reroute, name: NSSAI不匹配时NAS重路由 }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: high
---

# 特性说明：NSSAI不匹配时NAS重路由

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | mob_nssai_reroute |
| 特性名 | NSSAI不匹配时NAS重路由 |
| 所属 L1 | cat_mobility_interworking — 移动性与互操作 |
| 状态 | implemented |
| 规范参考 | TS 23.502 §4.2.2.2.3 |
| 置信度 | high |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：服务 AMF 无法处理 UE 切片时 NAS 重路由到目标 AMF

**业务目标**：围绕 `NSSAI不匹配时NAS重路由` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`NSSAI不匹配时NAS重路由` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `移动性与互操作` / `NSSAI不匹配时NAS重路由` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.502 §4.2.2.2.3 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 服务 AMF 无法处理 UE 切片时 NAS 重路由到目标 AMF |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| amf | 相关架构元素 | architectures/logic_view/elements/amf/spec.md |
| nssf | 相关架构元素 | architectures/logic_view/elements/nssf/spec.md |
| nrf | 相关架构元素 | architectures/logic_view/elements/nrf/spec.md |

## 5. 实现现状（事实域）

- `repos/amf/internal/gmm/handler.go::handleRequestedNssai`：切片不匹配时 NAS 重路由入口
- `repos/amf/internal/ngap/message/build.go::BuildRerouteNasRequest`：RAN Reroute NAS Request 报文构造

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | 经N1MessageNotify重定向 | 正常流程 | [SCENARIO_001_经N1MessageNotify重定向_场景流程.md](SCENARIO_001_经N1MessageNotify重定向_场景流程.md) |
| SCENARIO_002 | 回退至RAN_Reroute_NAS | 异常流程 | [SCENARIO_002_回退至RAN_Reroute_NAS_场景流程.md](SCENARIO_002_回退至RAN_Reroute_NAS_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | 经N1MessageNotify重定向 | 重路由场景 | [SCENARIO_001_经N1MessageNotify重定向_场景流程.md](SCENARIO_001_经N1MessageNotify重定向_场景流程.md) |
| SCENARIO_002 | 回退至RAN_Reroute_NAS | 回退场景 | [SCENARIO_002_回退至RAN_Reroute_NAS_场景流程.md](SCENARIO_002_回退至RAN_Reroute_NAS_场景流程.md) |
| SCENARIO_003 | 目标AMF不可用重路由失败 | 失败场景 | [SCENARIO_003_目标AMF不可用重路由失败_场景流程.md](SCENARIO_003_目标AMF不可用重路由失败_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
