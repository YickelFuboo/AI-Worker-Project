# 场景继承性分析

## 功能描述

基于 `02-fwd-feature-change-gen` 生成的场景级业务变更说明，以及 02 直接返回的结构化 JSON，分析新需求对存量业务场景、业务规则和兼容性约束的影响。该步骤聚焦“新变更是否会影响已有业务场景”，生成 `feature_changes/继承性分析报告.md`，并直接返回结构化 JSON，供后续 `03-Q-fwd-scenario-impact-check` 和架构影响域分析阶段消费。

该 skill 只做业务场景继承性、存量影响和回归范围分析，不进入架构元素、接口契约、代码模块、函数或测试文件设计。

## 所属 Agent

需求分析 Agent / 场景分析 Agent

## 适用场景

- `02-fwd-feature-change-gen` 已生成或更新 `feature_changes/**` 业务变更说明文件
- 02 已直接返回结构化 JSON，且 `status` 为 `COMPLETED` 或 `COMPLETED_WITH_WARNINGS`
- 需要判断新增、修改或删除的业务场景是否影响存量子特性场景
- 需要识别兼容性风险、存量业务规则冲突和建议回归验证范围
- 需要为 `03-Q-fwd-scenario-impact-check` 和后续架构影响域分析提供业务侧存量影响输入

## 输入要求

### 必需输入

1. `requirements/{需求ID}/需求分析.md`
2. `02-fwd-feature-change-gen` 返回的 JSON 对象
3. 02 JSON 中列出的 `feature_changes/**` 文件
4. `features/**/feature.yaml` 和相关子特性场景、规则资料

### 02 JSON 要求

03 只能消费 02 的结构化 JSON 返回结果和其中声明的产物路径，不读取调度器内部状态，也不自行推断 02 是否成功。

允许执行 03 的 02 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`

不得执行 03 的 02 状态：

- `BLOCKED`
- `INCONCLUSIVE`

当 02 的 `status` 为 `BLOCKED` 或 `INCONCLUSIVE` 时，本 skill 不生成继承性分析报告，只返回 `status = BLOCKED` 或 `status = INCONCLUSIVE` 的 JSON 结果，并在 `warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取需求文档**：理解需求目标、范围、业务规则、场景列表和验收标准
2. **读取 02 JSON**：确认 02 状态允许继续；读取场景 ID、变更类型、特性映射、置信度、告警和产物路径
3. **读取业务变更说明**：读取 02 JSON 声明的 `feature_changes/**` 文件，逐场景理解变更前后业务差异
4. **读取存量特性资料**：读取相关 `features/**/feature.yaml`、子特性场景和规则资料，定位可能受影响的存量业务场景
5. **分析继承性影响**：逐 `SCENARIO_XXX` 判断是否影响存量场景、存量规则、存量验收口径或兼容性约束
6. **识别风险与回归范围**：按 `high`、`medium`、`low` 标记兼容性风险，并列出建议回归验证的存量场景或业务能力
7. **生成继承性报告**：按模板输出 `requirements/{需求ID}/feature_changes/继承性分析报告.md`
8. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出生成/更新文件、场景影响清单、风险、告警和待确认项

### 继承性影响判定规则

- `unaffected`：新变更不改变存量场景的触发条件、业务规则、可观察结果或验收口径
- `compatible_extension`：新变更扩展业务能力，但存量场景无需迁移且原验收口径保持有效
- `behavior_change`：新变更改变存量场景的业务行为、规则优先级、可观察结果或验收口径
- `potential_conflict`：无法确认是否影响存量场景，或存在多个合理解释，需要后续确认
- `deprecated`：需求明确废止存量场景、规则或能力

### 风险等级规则

- `high`：影响存量业务场景的核心路径、兼容性承诺、原验收口径，或需求明确删除既有能力
- `medium`：可能影响存量场景的观察方式、边界规则、配置组合或运维习惯，但不必然破坏核心路径
- `low`：影响范围局部、可通过补充回归验证确认，或仅为非阻断确认项
- `none`：未识别出存量影响风险

### 边界规则

- 可以引用 02 的非阻断 `warnings`，但不得把它们改写成 workflow 调度决策
- 不得输出架构元素、接口字段、代码模块、函数名、测试文件或实现方案作为继承性结论
- 如发现需要架构或接口判断才能确认风险，只能记录为待后续架构阶段确认事项
- 回归范围必须以业务场景、业务规则、子特性能力或验收口径描述，不得写成具体测试文件或测试函数

### 文件输出要求

- 输出路径：`requirements/{需求ID}/feature_changes/继承性分析报告.md`
- 严格按模板格式输出：`templates/inheritance_report_template.md`
- 报告必须覆盖 02 JSON 中每个 `feature_changes[].scenario_id`
- 报告必须包含风险矩阵、受影响存量场景、兼容性结论和建议回归范围
- 如果无法可靠生成继承性报告，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `03-fwd-inheritance-analysis` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 `需求分析.md` 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次继承性分析结果，不能为空 |
| `input_feature_change_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `scenario_impacts` | array | 是 | 场景级存量影响清单；没有影响时仍需列出每个输入场景并标记 `unaffected` |
| `compatibility_risks` | array | 是 | 兼容性风险列表；无风险时必须是空数组 `[]` |
| `regression_scope` | array | 是 | 建议回归验证范围；无建议时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`scenario_impacts` 至少 1 项，`warnings` 和 `pending_questions` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`scenario_impacts` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项或 `compatibility_risks` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files`、`scenario_impacts`、`compatibility_risks` 和 `regression_scope` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/继承性分析报告.md",
  "type": "inheritance_report",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `inheritance_report`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### scenario_impact 对象

`scenario_impacts` 中每一项必须包含：

```json
{
  "id": "SI-001",
  "scenario_id": "SCENARIO_001",
  "feature_change_id": "FC-001",
  "impact_type": "compatible_extension",
  "affected_existing_scenarios": ["现有 AUSF 启动场景"],
  "affected_business_rules": ["未配置 nfInstanceId 时自动生成实例标识"],
  "risk_level": "low",
  "compatibility_conclusion": "存量未配置场景保持原行为，新增配置场景为兼容扩展。",
  "summary": "SCENARIO_001 对存量未配置启动场景无破坏性影响。"
}
```

字段限制：
- `id` 使用 `SI-001` 递增格式
- `scenario_id` 必须对应 02 JSON 中的 `feature_changes[].scenario_id`
- `feature_change_id` 必须对应 02 JSON 中的 `feature_changes[].id`
- `impact_type` 只能是 `unaffected`、`compatible_extension`、`behavior_change`、`potential_conflict`、`deprecated`
- `risk_level` 只能是 `none`、`low`、`medium`、`high`
- `affected_existing_scenarios` 和 `affected_business_rules` 无内容时必须是空数组 `[]`
- `compatibility_conclusion`、`summary` 不能为空

### compatibility_risk 对象

`compatibility_risks` 中每一项必须包含：

```json
{
  "id": "CR-001",
  "scenario_id": "SCENARIO_003",
  "risk_level": "medium",
  "content": "非法 nfInstanceId 启动失败可能改变已有错误配置场景的启动表现。",
  "affected_scope": "AUSF 配置错误处理相关存量场景",
  "mitigation": "后续确认是否存在依赖非法配置仍可启动的存量部署假设。"
}
```

字段限制：
- `id` 使用 `CR-001` 递增格式
- `scenario_id` 必须对应输入场景 ID
- `risk_level` 只能是 `low`、`medium`、`high`
- `content`、`affected_scope`、`mitigation` 不能为空

### regression_scope 对象

`regression_scope` 中每一项必须包含：

```json
{
  "id": "RS-001",
  "scenario_id": "SCENARIO_002",
  "scope_type": "existing_scenario",
  "target": "AUSF 未配置 nfInstanceId 时自动生成 NF Instance ID 的存量启动场景",
  "reason": "确认兼容性承诺未被新增配置能力破坏。"
}
```

字段限制：
- `id` 使用 `RS-001` 递增格式
- `scope_type` 只能是 `existing_scenario`、`business_rule`、`acceptance_criteria`、`subfeature_capability`
- `target`、`reason` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "input_feature_change",
  "content": "继承 02 的特性映射置信度告警，SCENARIO_001 的子特性映射为 medium。",
  "recommendation": "03-Q 检查时继续跟踪该场景的映射一致性。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `input_feature_change`、`scenario_impact`、`compatibility`、`regression_scope`、`boundary`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

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
- `blocking` 为布尔值；阻止生成可靠继承性报告的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_03Q`
- `readiness_for_design`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `architecture_elements`
- `interfaces`
- `implementation_modules`
- `code_files`
- `test_files`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已完成 3 个业务变更场景的继承性分析，识别 1 项中风险兼容性待确认项。",
  "input_feature_change_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/继承性分析报告.md",
      "type": "inheritance_report",
      "operation": "created"
    }
  ],
  "updated_files": [],
  "scenario_impacts": [
    {
      "id": "SI-001",
      "scenario_id": "SCENARIO_001",
      "feature_change_id": "FC-001",
      "impact_type": "compatible_extension",
      "affected_existing_scenarios": ["AUSF 启动时生成 NF Instance ID 的存量场景"],
      "affected_business_rules": ["未配置 nfInstanceId 时自动生成 NF Instance ID"],
      "risk_level": "low",
      "compatibility_conclusion": "新增配置能力不破坏未配置时自动生成的存量行为。",
      "summary": "SCENARIO_001 是对存量启动场景的兼容扩展。"
    }
  ],
  "compatibility_risks": [
    {
      "id": "CR-001",
      "scenario_id": "SCENARIO_003",
      "risk_level": "medium",
      "content": "非法 nfInstanceId 启动失败可能改变已有错误配置场景的启动表现。",
      "affected_scope": "AUSF 配置错误处理相关存量场景",
      "mitigation": "后续确认是否存在依赖非法配置仍可启动的历史部署假设。"
    }
  ],
  "regression_scope": [
    {
      "id": "RS-001",
      "scenario_id": "SCENARIO_002",
      "scope_type": "existing_scenario",
      "target": "AUSF 未配置 nfInstanceId 时自动生成 NF Instance ID 的存量启动场景",
      "reason": "确认兼容性承诺未被新增配置能力破坏。"
    }
  ],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "input_feature_change",
      "content": "继承 02 的非阻断告警：外部观察入口仍待确认。",
      "recommendation": "后续阶段继续跟踪观察入口对验收口径和架构设计的影响。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未进行架构元素、接口契约、代码模块或测试文件设计。"
  ]
}
```
