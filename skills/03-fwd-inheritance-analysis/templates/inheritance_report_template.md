---
requirement_id: {REQ-XXX}
source_feature_change_status: COMPLETED | COMPLETED_WITH_WARNINGS
created: {YYYY-MM-DD}
---

# 场景继承性分析报告：{需求主题}

## 1. 分析概述

| 项目 | 内容 |
|------|------|
| 关联需求 | {REQ-XXX} |
| 业务变更来源 | `requirements/{需求ID}/feature_changes/**` |
| 场景数量 | {N} |
| 存量影响结论 | 无影响 / 兼容扩展 / 存在行为变化 / 存在潜在冲突 / 废止存量能力 |
| 最高兼容性风险 | none / low / medium / high |

## 2. 输入场景清单

| 场景ID | 业务变更ID | 变更类型 | 一级特性 | 子特性 | 变更摘要 |
|--------|------------|----------|----------|--------|----------|
| SCENARIO_001 | FC-001 | new / modify / delete | | | |

## 3. 存量场景影响分析

### 3.1 {SCENARIO_001 场景名}

| 项 | 内容 |
|----|------|
| 业务变更ID | FC-001 |
| 影响类型 | unaffected / compatible_extension / behavior_change / potential_conflict / deprecated |
| 风险等级 | none / low / medium / high |
| 受影响存量场景 | {如无则填“无”} |
| 受影响业务规则 | {如无则填“无”} |
| 兼容性结论 | {结论} |

#### 影响说明

{说明该新/改/删场景如何影响存量业务场景、业务规则、可观察结果或验收口径。}

#### 继承性判断依据

- 来源业务变更：`requirements/{需求ID}/feature_changes/{子特性目录}/SR-XXX-..._变更说明.md`
- 存量特性资料：`features/...`
- 判断依据：{引用存量特性资料中的业务场景、规则或验收描述}

## 4. 兼容性风险矩阵

| 风险ID | 关联场景 | 风险等级 | 风险内容 | 影响范围 | 缓解建议 |
|--------|----------|----------|----------|----------|----------|
| CR-001 | SCENARIO_XXX | low / medium / high | | | |

> 如无兼容性风险，填写“无”。

## 5. 建议回归验证范围

| 回归范围ID | 关联场景 | 范围类型 | 验证目标 | 建议原因 |
|------------|----------|----------|----------|----------|
| RS-001 | SCENARIO_XXX | existing_scenario / business_rule / acceptance_criteria / subfeature_capability | | |

## 6. 待后续确认事项

- [ ] {问题 1；如无则填写“无”。}

## 7. 后续交接说明

- 本文档只描述业务场景继承性、存量影响、兼容性风险和业务回归范围。
- 本文档不固化架构元素、接口字段、代码模块、函数名、测试文件或实现方案。
- 需要架构或接口判断的问题，留待后续架构影响域分析和接口契约分析确认。
