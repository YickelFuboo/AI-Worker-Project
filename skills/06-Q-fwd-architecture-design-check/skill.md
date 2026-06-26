# 架构分析综合检查

## 功能描述

在 `04-fwd-arch-impact-analysis`、`05-fwd-interface-contract-analysis` 和 `06-fwd-logic-flow-design` 完成后，对架构分析段结果执行综合质量门禁检查，判断架构影响、接口契约和逻辑流设计是否完整覆盖上游场景分析结果，三阶段结果是否互相一致，兼容性处理是否可追溯，并确认分析边界没有提前进入代码文件、函数级变更或实现任务。

该 skill 只检查 04、05、06 的结果质量，不改写架构变更、接口契约或逻辑设计文件，不生成检查文件。检查结果必须直接返回结构化 JSON，供上层 workflow 或调度程序解析；本 skill 不负责决定下一步调度动作。

## 所属 Agent

架构设计 Agent / 质量质检 Agent

## 适用场景

- `04-fwd-arch-impact-analysis` 已返回结构化 JSON
- `05-fwd-interface-contract-analysis` 已返回结构化 JSON
- `06-fwd-logic-flow-design` 已返回结构化 JSON
- 需要判断架构分析段是否足够进入 `07-fwd-change-scope-refinement`
- 需要识别架构覆盖、接口契约覆盖、逻辑流覆盖、一致性、兼容性或边界纪律中的缺口
- 需要向上层 workflow 返回机器可解析的质量检查结果

## 输入要求

### 必需输入

1. `02-fwd-feature-change-gen` 和 `03-fwd-inheritance-analysis` 的已通过门禁交付件（`feature_changes/**`、`inheritance_report.md` 及其 JSON），用于建立场景和兼容性风险基线
2. `04-fwd-arch-impact-analysis` 返回的 JSON 对象和其声明的 `architecture_changes/**` 文件
3. `05-fwd-interface-contract-analysis` 返回的 JSON 对象和其声明的更新文件或接口契约文件
4. `06-fwd-logic-flow-design` 返回的 JSON 对象和其声明的 `repo_changes/**/implementation_design.md` 文件

本 skill 不消费 `03-Q` 的检查 JSON。场景和兼容性风险基线来自 02、03 的 WORK 交付件本身，而不是上一个门禁节点的 `verdict`。

### 输入状态要求

允许检查的 04、05、06 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`
- `BLOCKED`
- `INCONCLUSIVE`

当 04、05 或 06 为 `BLOCKED` 或 `INCONCLUSIVE` 时，本 skill 仍可执行检查，但通常应输出 `REWORK` 或 `INCONCLUSIVE`，并在 `blockers` 中说明哪个输入阶段无法支撑后续分析。

## 工作方式

### 执行步骤

1. **读取场景基线**：读取 02、03 的已通过门禁交付件，建立 `SCENARIO_XXX` 和兼容性风险基线，用于判断 04/05/06 的覆盖完整性
2. **检查 04 JSON 和文件**：确认每个需要架构处理的场景或兼容性风险都有架构影响结论和产物路径
3. **检查 05 JSON 和文件**：确认 04 的每个候选接口影响都有接口契约结论，或有可追溯的不适用/未知说明
4. **检查 06 JSON 和文件**：确认每个关键架构影响和接口契约变化都有逻辑流、数据流或状态机覆盖
5. **检查跨文档一致性**：确认 `AI-XXX`、`CII-XXX`、`IC-XXX`、`LF-XXX`、`SCENARIO_XXX` 的引用链一致
6. **检查兼容性处理**：确认 03/04/05 中的兼容性风险在 06 中没有被遗漏或隐式假设解决
7. **检查边界越界**：判断 04/05/06 是否输出代码文件、函数级变更、测试文件、实现任务或提交计划；如存在，作为阻断问题
8. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，不写入任何检查结果文件

### 判定规则

- **PASS**：04、05、06 结果质量通过，没有阻断问题，也没有需要显式跟踪的非阻断告警
- **PASS_WITH_WARNINGS**：04、05、06 结果质量通过，没有阻断问题，但存在非阻断风险、未知接口影响、待确认项或后续阶段需要注意的内容
- **REWORK**：架构覆盖缺失、接口契约缺失、逻辑流缺失、跨阶段引用不一致、兼容性风险不可追溯或边界越界，需要回到 04、05 或 06 修正
- **INCONCLUSIVE**：输入缺失、JSON 格式异常、文件不可读、产物与 JSON 无法对应，导致无法形成有效检查结论

### 阻断与告警判断

- 02/03 基线中的场景或兼容性风险没有对应架构影响，必须判为 `REWORK`
- 04 的 `candidate_interface_impacts` 没有被 05 覆盖，必须判为 `REWORK`
- 05 的 `impact_type = new|modify|delete` 没有被 06 的逻辑流覆盖，必须判为 `REWORK`
- 04、05、06 的文件路径与 JSON `output_files` / `updated_files` 不一致，必须判为 `REWORK` 或 `INCONCLUSIVE`
- 04、05、06 输出代码文件、函数级变更、测试文件、实现任务或提交计划，必须判为 `REWORK`
- `unknown` 接口影响或非阻断待确认项可以判为 `PASS_WITH_WARNINGS`，前提是它们被显式保留并可追溯

### 注意事项

- 不替代 04、05、06 改写文件，只输出质量判断和返工建议
- 不生成 `architecture_quality.md`、`architecture_quality.json` 或其它检查结果文件
- 不输出 Markdown 报告作为检查结果；最终回答必须是一个 JSON 对象
- 不包含 workflow 调度字段，例如 `next_action`、`next_step`、`readiness_for_07`、`canProceedToNext`
- 返工建议必须指向 04、05 或 06 可执行的修正方向，避免只写“补充完善设计”这类泛化描述

## 输出 JSON 契约

最终输出必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 04/05/06 JSON 或输入目录名 |
| `verdict` | string | 是 | 只能是 `PASS`、`PASS_WITH_WARNINGS`、`REWORK`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括质量结论，不能为空 |
| `input_04_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `input_05_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `input_06_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `blockers` | array | 是 | 阻断问题列表；无阻断问题时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `follow_up_questions` | array | 是 | 建议补问的问题列表；无问题时必须是空数组 `[]` |
| `quality_dimensions` | object | 是 | 固定包含下方 6 个质量维度 |

### verdict 与列表一致性

- `verdict = PASS` 时：`blockers` 必须为空，`warnings` 必须为空
- `verdict = PASS_WITH_WARNINGS` 时：`blockers` 必须为空，`warnings` 必须至少 1 项
- `verdict = REWORK` 时：`blockers` 必须至少 1 项
- `verdict = INCONCLUSIVE` 时：`blockers` 必须至少 1 项，且 blocker 说明无法检查的输入或解析问题

### blocker 对象

`blockers` 中每一项必须包含：

```json
{
  "id": "B-001",
  "dimension": "logic_flow_coverage",
  "content": "05 中 IC-001 标记为 modify，但 06 的 logic_flows 未引用该接口契约变化。",
  "impact": "后续 07 可能无法从接口契约变化追溯到模块级设计。",
  "recommendation": "回到 06，为 IC-001 补充逻辑流或说明该接口变化无需逻辑流的依据。"
}
```

字段限制：
- `id` 使用 `B-001` 递增格式
- `dimension` 必须对应 `quality_dimensions` 中的一个键，或使用 `input_validity`
- `content`、`impact`、`recommendation` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "interface_contract_coverage",
  "content": "IC-001 的接口影响仍为 unknown，但 06 已显式保留该不确定性。",
  "recommendation": "07 细化代码范围时不得把 unknown 接口影响隐式实现为确定接口变更。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 必须对应 `quality_dimensions` 中的一个键，或使用具体主题名如 `compatibility`
- `content`、`recommendation` 不能为空

### follow_up_questions 对象

`follow_up_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "外部观察 NF Instance ID 的接口入口是否需要在 05 和 06 中重新确认？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；对应 blocker 的问题为 `true`，对应 warning 的问题为 `false`

### quality_dimensions 对象

`quality_dimensions` 必须固定包含以下键：

- `architecture_coverage`
- `interface_contract_coverage`
- `logic_flow_coverage`
- `cross_document_consistency`
- `compatibility_handling`
- `boundary_violation`

每个维度对象必须包含：

```json
{
  "status": "PASS",
  "summary": "04 的架构影响、05 的接口契约和 06 的逻辑流形成一致追溯链。"
}
```

`status` 只能是：

- `PASS`：该维度通过
- `WARNINGS`：该维度有非阻断问题
- `FAIL`：该维度存在阻断问题
- `NOT_APPLICABLE`：该维度对当前需求不适用
- `INCONCLUSIVE`：该维度无法判断

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_07`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "verdict": "PASS_WITH_WARNINGS",
  "summary": "04、05、06 已形成可追溯的架构分析链路，但仍保留外部观察入口未确认告警。",
  "input_04_status": "COMPLETED_WITH_WARNINGS",
  "input_05_status": "COMPLETED_WITH_WARNINGS",
  "input_06_status": "COMPLETED_WITH_WARNINGS",
  "blockers": [],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "interface_contract_coverage",
      "content": "IC-001 的接口影响仍为 unknown，但 06 已显式保留该不确定性。",
      "recommendation": "07 细化代码范围时不得把 unknown 接口影响隐式实现为确定接口变更。"
    }
  ],
  "follow_up_questions": [],
  "quality_dimensions": {
    "architecture_coverage": {
      "status": "PASS",
      "summary": "04 已覆盖 03-Q 通过的业务场景和兼容性风险。"
    },
    "interface_contract_coverage": {
      "status": "WARNINGS",
      "summary": "05 已覆盖 04 的候选接口影响，但保留一个 unknown 结论。"
    },
    "logic_flow_coverage": {
      "status": "PASS",
      "summary": "06 已为关键架构影响和接口契约变化提供模块级逻辑流设计。"
    },
    "cross_document_consistency": {
      "status": "PASS",
      "summary": "AI、CII、IC、LF 和 SCENARIO 引用链一致。"
    },
    "compatibility_handling": {
      "status": "PASS",
      "summary": "兼容性风险在 04、05、06 中均被保留或处理。"
    },
    "boundary_violation": {
      "status": "PASS",
      "summary": "04、05、06 未输出代码文件、函数级变更、测试文件或实现任务。"
    }
  }
}
```
