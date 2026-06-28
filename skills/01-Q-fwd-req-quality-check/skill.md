# 需求质量门禁检查

## 功能描述

在 `01-fwd-req-analysis` 完成后，对 `requirements/{需求ID}/需求分析.md` 执行需求质量门禁检查，判断需求澄清结果是否清楚、完整、可验证，并且是否足够进入后续特性变更分析。

该 skill 只判断 01 的结构化需求质量，不替代 01 重写需求，也不进入现有特性库做变更落点分析。检查结果必须直接返回结构化 JSON，供上层 workflow 或调度程序解析；本 skill 不负责决定下一步调度动作。

## 所属 Agent

需求分析 Agent / 质量质检 Agent

## 适用场景

- `01-fwd-req-analysis` 已生成 `requirements/{需求ID}/需求分析.md`
- 需要判断需求是否清楚、完整、可验证
- 需要识别 5W2H、范围、业务场景、验收标准或非功能要求中的缺口
- 需要向上层 workflow 返回机器可解析的质量检查结果

## 工作方式

### 执行步骤

1. **读取需求文档**：读取 `requirements/{需求ID}/需求分析.md`，只以 01 的结构化需求结果作为主要输入
2. **检查 5W2H 完整性**：逐项判断 Who、When、Where、What、Why、How、How much 是否存在、是否具体、是否标注待确认
3. **检查需求目标**：判断核心目标、业务价值和量化指标是否清楚，是否混入技术实现细节替代业务目标
4. **检查范围边界**：判断范围内、范围外和待确认项是否清楚，是否存在无法约束的泛化表达
5. **检查业务场景**：判断场景是否是具体用户/业务场景，是否包含触发角色、触发条件、业务过程、业务结果和验收标准
6. **检查验收可判定性**：判断 Given-When-Then 是否完整，Then 是否是用户或业务侧可观察、可验证的结果
7. **检查非功能缺口**：按需求性质判断性能、可靠性、安全、兼容性、可观测性等是否存在明显缺失或待确认项
8. **检查边界越界**：判断 01 输出是否包含确定性的现有业务能力映射、代码模块定位或影响结论；如存在，作为阻断问题
9. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，不写入 `需求质量检查.md` 或其它检查结果文件

### 判定规则

- **PASS**：需求质量通过，没有阻断问题，也没有需要显式跟踪的非阻断告警
- **PASS_WITH_WARNINGS**：需求质量通过，没有阻断问题，但存在非阻断风险、待确认项或后续阶段需要注意的内容
- **REWORK**：需求质量不通过，存在阻断问题，需要回到需求澄清补充或修正后重新检查
- **INCONCLUSIVE**：本次检查无法形成有效质量结论，例如需求文档缺失、格式损坏、输入不是 01 产物或检查所需信息不可解析

### 阻断与告警判断

- 关键 5W2H 缺失、目标无法理解、范围不可控、业务场景不可执行、验收标准不可判定、关键量化约束缺失或越界输出变更落点结论，必须判为 `REWORK`
- 不影响后续特性变更分析的待确认项，可判为 `PASS_WITH_WARNINGS`
- 不要求所有非功能分类都有内容，但需求明显涉及的质量属性必须覆盖或标注待确认
- 不把“待确认”一概判为失败；只有影响后续特性变更分析的关键缺口才阻断
- 不得因为能猜出业务含义就放行；缺失的信息必须在 JSON 中显式标注

### 注意事项

- 不读取或分析现有特性库来判断变更落点
- 不替代 01 改写 `需求分析.md`，只输出质量判断和返工建议
- 不生成 `需求质量检查.md`、`需求质量检查.json` 或其它检查结果文件
- 不输出 Markdown 报告作为检查结果；最终回答必须是一个 JSON 对象
- 不包含 workflow 调度字段，例如 `next_action`、`next_step`、`readiness_for_02`、`canProceedToNext`
- 返工建议必须能指导 01 重新澄清问题，避免只写“补充完善需求”这类泛化描述

## 输出 JSON 契约

最终输出必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自需求文档 frontmatter 或目录名 |
| `verdict` | string | 是 | 只能是 `PASS`、`PASS_WITH_WARNINGS`、`REWORK`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括质量结论，不能为空 |
| `blockers` | array | 是 | 阻断问题列表；无阻断问题时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `follow_up_questions` | array | 是 | 建议补问的问题列表；无问题时必须是空数组 `[]` |
| `quality_dimensions` | object | 是 | 固定包含下方 7 个质量维度 |

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
  "dimension": "acceptance_criteria",
  "content": "非法 nfInstanceId 的期望处理结果缺失，导致验收标准不可判定。",
  "impact": "后续阶段可能自行假设非法配置行为，造成业务规则和验收口径漂移。",
  "recommendation": "回到 01 明确非法 nfInstanceId 时是启动失败、提示配置错误，还是回退自动生成。"
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
  "dimension": "observability",
  "content": "外部检查或运维追踪读取 AUSF NF Instance ID 的观察入口仍待确认。",
  "recommendation": "后续阶段明确主要观察入口，例如 NRF 注册信息、日志或健康检查输出。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 必须对应 `quality_dimensions` 中的一个键，或使用具体主题名如 `configuration`、`observability`
- `content`、`recommendation` 不能为空

### follow_up_questions 对象

`follow_up_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "外部检查或运维追踪应主要通过哪个入口观察 AUSF 的 NF Instance ID？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或 01 的问题
- `blocking` 为布尔值；对应 blocker 的问题为 `true`，对应 warning 的问题为 `false`

### quality_dimensions 对象

`quality_dimensions` 必须固定包含以下键：

- `five_w_two_h`
- `goal_clarity`
- `scope_boundary`
- `business_scenarios`
- `acceptance_criteria`
- `non_functional_requirements`
- `boundary_violation`

每个维度对象必须包含：

```json
{
  "status": "PASS",
  "summary": "Who、When、Where、What、Why、How 和 How much 均已覆盖核心需求。"
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
- `readiness_for_02`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "verdict": "PASS_WITH_WARNINGS",
  "summary": "关键业务规则、范围和验收标准已可判定；仍存在配置项层级、观察入口和性能阈值等非阻断待确认项。",
  "blockers": [],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "observability",
      "content": "外部检查或运维追踪读取 AUSF NF Instance ID 的观察入口仍待确认。",
      "recommendation": "后续阶段明确主要观察入口，例如 NRF 注册信息、日志或健康检查输出。"
    }
  ],
  "follow_up_questions": [
    {
      "id": "Q-001",
      "content": "外部检查或运维追踪应主要通过哪个入口观察 AUSF 的 NF Instance ID？",
      "blocking": false
    }
  ],
  "quality_dimensions": {
    "five_w_two_h": {
      "status": "PASS",
      "summary": "Who、When、Where、What、Why、How 和 How much 均已覆盖核心需求。"
    },
    "goal_clarity": {
      "status": "PASS",
      "summary": "目标清楚，业务价值明确，未用技术实现替代业务目标。"
    },
    "scope_boundary": {
      "status": "PASS",
      "summary": "范围内、范围外和剩余待确认项边界清楚。"
    },
    "business_scenarios": {
      "status": "PASS",
      "summary": "核心业务场景具备触发角色、触发条件、业务过程和业务结果。"
    },
    "acceptance_criteria": {
      "status": "PASS",
      "summary": "核心 Given-When-Then 均可判定。"
    },
    "non_functional_requirements": {
      "status": "WARNINGS",
      "summary": "部分非功能要求仍有非阻断待确认项。"
    },
    "boundary_violation": {
      "status": "PASS",
      "summary": "未提前分析现有特性库、代码模块或具体变更落点。"
    }
  }
}
```
