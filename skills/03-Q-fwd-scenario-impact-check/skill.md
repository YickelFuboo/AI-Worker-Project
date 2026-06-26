# 场景分析结果检查

## 功能描述

在 `02-fwd-feature-change-gen` 和 `03-fwd-inheritance-analysis` 完成后，对场景级业务变更分析和继承性分析结果执行质量门禁检查，判断需求场景是否被完整覆盖、特性映射是否一致、存量影响分析是否充分、兼容性风险和回归范围是否可追溯，并确认分析边界没有提前进入架构、接口或代码实现。

该 skill 只检查 02 和 03 的结果质量，不改写业务变更说明或继承性报告，不生成检查文件。检查结果必须直接返回结构化 JSON，供上层 workflow 或调度程序解析；本 skill 不负责决定下一步调度动作。

## 所属 Agent

需求分析 Agent / 质量质检 Agent

## 适用场景

- `02-fwd-feature-change-gen` 已返回结构化 JSON
- `03-fwd-inheritance-analysis` 已返回结构化 JSON
- 需要判断场景分析段是否足够进入架构影响域分析
- 需要识别场景覆盖、特性映射、继承性分析、兼容性风险或边界纪律中的缺口
- 需要向上层 workflow 返回机器可解析的质量检查结果

## 输入要求

### 必需输入

1. `requirements/{需求ID}/requirement.md`
2. `02-fwd-feature-change-gen` 返回的 JSON 对象
3. 02 JSON 中声明的 `feature_changes/**` 文件
4. `03-fwd-inheritance-analysis` 返回的 JSON 对象
5. 03 JSON 中声明的 `inheritance_report.md`

### 输入状态要求

允许检查的 02 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`
- `BLOCKED`
- `INCONCLUSIVE`

允许检查的 03 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`
- `BLOCKED`
- `INCONCLUSIVE`

当 02 或 03 为 `BLOCKED` 或 `INCONCLUSIVE` 时，本 skill 仍可执行检查，但通常应输出 `REWORK` 或 `INCONCLUSIVE`，并在 `blockers` 中说明哪个输入阶段无法支撑后续分析。

## 工作方式

### 执行步骤

1. **读取需求文档**：读取 `requirements/{需求ID}/requirement.md`，识别需求场景和验收标准
2. **检查 02 JSON**：确认业务变更清单、场景 ID、特性映射、变更类型、置信度和产物路径一致
3. **检查 02 文件**：读取 02 JSON 声明的 `feature_changes/**` 文件，确认每个变更文件只描述一个需求场景，且与 JSON 对齐
4. **检查 03 JSON**：确认 `scenario_impacts` 覆盖 02 中每个 `feature_changes[].scenario_id`，风险、回归范围和待确认项可追溯
5. **检查 03 文件**：读取 03 JSON 声明的 `inheritance_report.md`，确认报告内容与 JSON 对齐
6. **检查场景覆盖**：判断需求文档中的每个业务场景是否在 02 和 03 中都有稳定追踪
7. **检查边界越界**：判断 02/03 是否输出架构元素、接口字段、代码模块、函数名、测试文件或实现方案；如存在，作为阻断问题
8. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，不写入任何检查结果文件

### 判定规则

- **PASS**：02 和 03 结果质量通过，没有阻断问题，也没有需要显式跟踪的非阻断告警
- **PASS_WITH_WARNINGS**：02 和 03 结果质量通过，没有阻断问题，但存在非阻断风险、低置信度映射、待确认项或后续阶段需要注意的内容
- **REWORK**：场景覆盖缺失、映射不一致、继承性分析缺失、兼容性风险不可追溯、输入产物缺失或边界越界，需要回到 02 或 03 修正
- **INCONCLUSIVE**：输入缺失、JSON 格式异常、文件不可读、产物与 JSON 无法对应，导致无法形成有效检查结论

### 阻断与告警判断

- 需求场景没有对应 `SCENARIO_XXX`，必须判为 `REWORK`
- 02 JSON 中的 `feature_changes[].output_file` 缺失或与文件内容不一致，必须判为 `REWORK` 或 `INCONCLUSIVE`
- 03 未覆盖 02 中任一 `scenario_id`，必须判为 `REWORK`
- 03 的高/中风险没有影响范围、缓解建议或回归范围，必须判为 `REWORK`
- 02/03 输出架构元素、接口契约、代码模块、函数名、测试文件或实现方案，必须判为 `REWORK`
- 02 或 03 的非阻断告警可继承为 `PASS_WITH_WARNINGS`，但不得转换成 workflow 调度决策

### 注意事项

- 不读取或分析架构资料来替代 04 的职责
- 不替代 02 或 03 改写文件，只输出质量判断和返工建议
- 不生成 `scenario_quality.md`、`scenario_quality.json` 或其它检查结果文件
- 不输出 Markdown 报告作为检查结果；最终回答必须是一个 JSON 对象
- 不包含 workflow 调度字段，例如 `next_action`、`next_step`、`readiness_for_architecture`、`canProceedToNext`
- 返工建议必须指向 02 或 03 可执行的修正方向，避免只写“补充完善分析”这类泛化描述

## 输出 JSON 契约

最终输出必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自需求文档 frontmatter 或目录名 |
| `verdict` | string | 是 | 只能是 `PASS`、`PASS_WITH_WARNINGS`、`REWORK`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括质量结论，不能为空 |
| `input_02_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `input_03_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `blockers` | array | 是 | 阻断问题列表；无阻断问题时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `follow_up_questions` | array | 是 | 建议补问的问题列表；无问题时必须是空数组 `[]` |
| `quality_dimensions` | object | 是 | 固定包含下方 5 个质量维度 |

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
  "dimension": "scenario_coverage",
  "content": "需求场景 3 未在 03 的 scenario_impacts 中出现。",
  "impact": "后续架构影响域分析可能遗漏该场景对应的业务影响。",
  "recommendation": "回到 03，为 SCENARIO_003 补充存量影响、兼容性风险和回归范围分析。"
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
  "dimension": "feature_mapping_consistency",
  "content": "SCENARIO_001 的特性映射置信度为 medium，但不影响继续检查。",
  "recommendation": "后续架构影响域分析中保留候选特性映射风险。"
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
  "content": "是否存在依赖非法 nfInstanceId 仍可启动的历史部署或验收口径？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；对应 blocker 的问题为 `true`，对应 warning 的问题为 `false`

### quality_dimensions 对象

`quality_dimensions` 必须固定包含以下键：

- `scenario_coverage`
- `feature_mapping_consistency`
- `inheritance_coverage`
- `compatibility_risk_traceability`
- `boundary_violation`

每个维度对象必须包含：

```json
{
  "status": "PASS",
  "summary": "需求场景、02 feature_changes 和 03 scenario_impacts 已逐一对应。"
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
- `readiness_for_04`
- `readiness_for_architecture`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "verdict": "PASS_WITH_WARNINGS",
  "summary": "02 和 03 已覆盖全部需求场景，继承性分析可追溯；仍有 1 项兼容性风险需后续关注。",
  "input_02_status": "COMPLETED_WITH_WARNINGS",
  "input_03_status": "COMPLETED_WITH_WARNINGS",
  "blockers": [],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "compatibility_risk_traceability",
      "content": "SCENARIO_003 保留非法配置历史行为的兼容性待确认风险。",
      "recommendation": "后续架构阶段处理配置错误策略时继续跟踪该风险。"
    }
  ],
  "follow_up_questions": [
    {
      "id": "Q-001",
      "content": "是否存在依赖非法 nfInstanceId 仍可启动的历史部署或验收口径？",
      "blocking": false
    }
  ],
  "quality_dimensions": {
    "scenario_coverage": {
      "status": "PASS",
      "summary": "需求场景、02 feature_changes 和 03 scenario_impacts 已逐一对应。"
    },
    "feature_mapping_consistency": {
      "status": "PASS",
      "summary": "02 JSON 与业务变更说明中的特性、子特性和场景 ID 一致。"
    },
    "inheritance_coverage": {
      "status": "PASS",
      "summary": "03 已覆盖每个业务变更场景的存量影响分析。"
    },
    "compatibility_risk_traceability": {
      "status": "WARNINGS",
      "summary": "兼容性风险均有关联场景、影响范围和缓解建议，但仍有非阻断待确认项。"
    },
    "boundary_violation": {
      "status": "PASS",
      "summary": "02 和 03 未提前输出架构元素、接口契约、代码模块或测试文件。"
    }
  }
}
```
