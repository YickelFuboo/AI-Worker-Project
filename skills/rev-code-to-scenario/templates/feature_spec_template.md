---
id: {feature_id}
name: {特性中文名}
feature_path:
  - { level: L1, id: {cat_xxx}, name: {一级特性中文名} }
  - { level: L2, id: {sec_xxx | mob_xxx | ...}, name: {二级特性中文名} }
last_modified: "YYYY-MM-DDTHH:MM:SS+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: high | medium | low
---

# 特性说明：{特性中文名}

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | {feature_id} |
| 特性名 | {特性中文名} |
| 所属 L1 | {cat_xxx} — {一级特性中文名} |
| 状态 | implemented / partial / planned |
| 规范参考 | {TS/协议章节} |
| 置信度 | high / medium / low |
| 意图源覆盖 | 已采纳 / 部分采纳 / - |

## 2. 业务定义与目标（意图域）

**业务定义**：{这个特性是什么，面向什么业务能力。}

**业务目标**：{这个特性解决什么业务问题，为什么需要它。}

**范围边界**：

- 包含：{纳入本特性的能力范围}
- 不包含：{不属于本特性的能力范围}

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | {3GPP TS / RFC / 接口规范} |
| 触发条件 | {触发该特性参与业务流程的条件} |
| 重试退避 | {当前实现中的重试、退避、超时、失败处理策略} |
| 关键约束 | {配置、订阅、拓扑、协议约束} |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 |
|---------|------|----------|
| {element_id} | {role} | {if_id / protocol} |

## 5. 实现现状（事实域）

- **主要入口**：`{repo/path::symbol}`
- **关键调用链**：`{funcA}` → `{funcB}` → `{funcC}`
- **状态/数据模型**：`{state/model}`
- **已知限制**：{如适用}

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | {主场景名} | 主场景 | [SCENARIO_001](SCENARIO_001_{name}_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
