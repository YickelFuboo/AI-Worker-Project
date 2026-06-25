---
id: voice_eps_fallback
name: 语音EPS Fallback
feature_path:
  - { level: L1, id: cat_voice_ims, name: 语音与 IMS }
  - { level: L2, id: voice_eps_fallback, name: 语音EPS Fallback }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 特性说明：语音EPS Fallback

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | voice_eps_fallback |
| 特性名 | 语音EPS Fallback |
| 所属 L1 | cat_voice_ims — 语音与 IMS |
| 状态 | planned |
| 规范参考 | TS 23.502 §4.13 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：5G NR 不支持 VoNR 时回退到 EPS 做语音

**业务目标**：围绕 `语音EPS Fallback` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`语音EPS Fallback` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `语音与 IMS` / `语音EPS Fallback` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 23.502 §4.13 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 5G NR 不支持 VoNR 时回退到 EPS 做语音 |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| amf | 相关架构元素 | architectures/logic_view/elements/amf/spec.md |

## 5. 实现现状（事实域）

- 当前特性暂无可确认代码锚点；后续由事实源增量补充。

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | 语音EPS Fallback主场景 | 主场景 | [SCENARIO_001_EPS_Fallback_for_Voice主场景_场景流程.md](SCENARIO_001_EPS_Fallback_for_Voice主场景_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | EPS Fallback成功建立语音 | 回退场景 | [SCENARIO_001_EPS_Fallback成功建立语音_场景流程.md](SCENARIO_001_EPS_Fallback成功建立语音_场景流程.md) |
| SCENARIO_002 | EPS Fallback回退失败 | 失败场景 | [SCENARIO_002_EPS_Fallback回退失败_场景流程.md](SCENARIO_002_EPS_Fallback回退失败_场景流程.md) |
| SCENARIO_003 | 回退后返回5GS | 迁移场景 | [SCENARIO_003_回退后返回5GS_场景流程.md](SCENARIO_003_回退后返回5GS_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
