# 业务变更说明生成

## 功能描述

基于 `01-fwd-req-analysis` 生成、并已通过 `01-Q-fwd-req-quality-check` 门禁的结构化需求文档 `需求分析.md`，生成业务视角的变更说明文档。该步骤明确受影响的一级特性、子特性和需求场景，描述每个场景的业务变更内容（新增/修改/删除），并生成 `feature_changes/` 目录下的变更文件。

`01-Q-fwd-req-quality-check` 是需求质量门禁节点，由 workflow 依据其 `verdict` 决定是否调度本 skill。02 不消费 01-Q 的检查 JSON，也不依据 01-Q 的 `verdict` 自行决定是否执行；02 的输入是 01 已通过门禁的需求交付件本身。

该 skill 只做业务特性和场景级变更分析，不进入架构设计、代码模块定位或实现方案设计。完成后必须直接返回结构化 JSON，供上层 workflow 或调度程序解析本次产物路径、变更清单、告警和待确认项。

## 所属 Agent

需求分析 Agent

## 适用场景

- `01-fwd-req-analysis` 已生成或更新 `requirements/{需求ID}/需求分析.md`，且该需求交付件已通过 `01-Q-fwd-req-quality-check` 门禁（由 workflow 判定）
- 需要明确业务视角的特性和场景变更范围
- 需要确定新增、修改或删除的业务场景及其交互流程差异
- 为后续规格说明、架构影响域分析和设计文档提供业务侧输入

## 输入要求

### 必需输入

1. `requirements/{需求ID}/需求分析.md`
2. `features/**/feature.yaml` 和相关子特性资料

### 输入门禁前提

`需求分析.md` 必须是已通过 `01-Q-fwd-req-quality-check` 门禁的需求交付件。门禁判定由 workflow 依据 `01-Q` 的 `verdict` 完成：只有 `verdict` 为 `PASS` 或 `PASS_WITH_WARNINGS` 时，workflow 才调度本 skill。

02 不读取 `01-Q` 的检查 JSON、`需求质量检查.md` 或 `需求质量检查.json`，也不依据 `01-Q` 的 `verdict` 自行决定是否执行。02 的输入只有需求交付件本身和特性资料。

如果 `需求分析.md` 缺失、不可解析或内容不足以支撑场景级变更分析，本 skill 返回 `status = INCONCLUSIVE` 或 `status = BLOCKED`，并在 `notes`、`warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取需求文档**：解析 `需求分析.md` 中的需求目标、功能范围、业务规则、场景列表和验收标准
2. **读取特性资料**：加载 `features/**/feature.yaml` 和相关子特性资料，定位候选一级特性和子特性
3. **生成稳定场景 ID**：为需求文档中的场景生成稳定 ID，格式为 `SCENARIO_001`、`SCENARIO_002`，顺序按 `需求分析.md` 中出现顺序
4. **分析特性映射**：逐场景判断其最匹配的一级特性和子特性；无法唯一确定时必须记录为告警或待确认项，不得强行确定
5. **判定变更类型**：逐场景判断是 `new`、`modify` 还是 `delete`，并记录判定依据
6. **生成变更文件**：按模板输出到 `requirements/{需求ID}/feature_changes/{子特性目录}/` 下，命名格式 `SR-{序号}-{场景描述}_变更说明.md`
7. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出生成/更新文件、场景级变更、告警和待确认项

### 变更类型判定规则

- `new`：需求引入现有特性资料中不存在的新业务场景、能力或规则
- `modify`：需求改变现有特性资料中已有业务场景、业务规则、流程或可观察结果
- `delete`：需求明确要求移除或废止现有业务场景、业务规则或能力
- 无法判断 `new` 或 `modify` 时，优先记录为 `pending_questions`；不得仅凭猜测强行归类

### 特性映射规则

- 映射必须基于 `features/**/feature.yaml` 和相关子特性资料中的业务描述
- 若只有一个明显匹配项，可标记 `mapping_confidence = high`
- 若存在多个合理候选项，可标记 `mapping_confidence = medium` 并在变更文件中列出候选原因
- 若无法可靠映射，必须标记 `mapping_confidence = low`，并在 JSON 的 `warnings` 或 `pending_questions` 中说明
- 不得输出代码模块、包名、函数名或实现文件路径作为映射结论

### 注意事项

- 变更说明必须精确引用场景 ID（如 `SCENARIO_001`），确保可追溯
- 场景间如有业务依赖关系，需在变更说明中明确顺序和依赖原因
- 参考 `templates/feature_change_template.md` 的格式
- 不生成或更新继承性报告，除非后续有独立 skill 或模板明确定义该产物
- 不进入架构设计、接口设计、代码实现、测试设计或迁移方案设计

### 文件输出要求

- 输出路径：`requirements/{需求ID}/feature_changes/{子特性目录}/SR-{序号}-{描述}_变更说明.md`
- 如后续模板或流程需要生成特性影响分析汇总产物，统一输出到 `requirements/{需求ID}/feature_changes/特性影响分析报告.md`，不得在需求根目录生成英文缩写命名的报告文件
- 严格按模板格式输出：`templates/feature_change_template.md`
- 每个变更文件只描述一个需求场景对应的业务变更
- YAML 元数据头部必须包含 `requirement_id`、`feature_id`、`subfeature_id`、`scenario_id`、`change_type`、`mapping_confidence`、`created`
- 如果无法可靠生成任何变更文件，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `02-fwd-feature-change-gen` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 `需求分析.md` 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次业务变更分析结果，不能为空 |
| `input_requirement_status` | string | 是 | 上游 `01-fwd-req-analysis` 报告的状态，只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `feature_changes` | array | 是 | 场景级业务变更清单；没有变更时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 枚举语义

- `COMPLETED`：已成功生成或更新业务变更说明文件，且没有显式告警或待确认项
- `COMPLETED_WITH_WARNINGS`：已成功生成或更新业务变更说明文件，但存在非阻断告警、映射置信度不足或继承自 01-Q 的告警
- `BLOCKED`：关键特性映射缺失或关键信息不足，无法生成可靠变更文件
- `INCONCLUSIVE`：输入缺失、格式异常、特性资料不可解析或无法形成可靠业务变更结论

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`feature_changes` 至少 1 项，`warnings` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`feature_changes` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`pending_questions` 至少 1 项或 `warnings` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files` 和 `feature_changes` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/AUSF身份配置/SR-001-配置稳定nfInstanceId_变更说明.md",
  "type": "feature_change",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `feature_change`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### feature_change 对象

`feature_changes` 中每一项必须包含：

```json
{
  "id": "FC-001",
  "scenario_id": "SCENARIO_001",
  "change_type": "new",
  "feature_id": "FEATURE_XXX",
  "feature_name": "网络功能生命周期管理",
  "subfeature_id": "SUBFEATURE_XXX",
  "subfeature_name": "NF实例标识配置",
  "mapping_confidence": "medium",
  "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/NF实例标识配置/SR-001-配置稳定nfInstanceId_变更说明.md",
  "summary": "AUSF 支持通过配置文件指定稳定的 nfInstanceId。"
}
```

字段限制：
- `id` 使用 `FC-001` 递增格式
- `scenario_id` 使用 `SCENARIO_001` 递增格式，并与变更文件一致
- `change_type` 只能是 `new`、`modify`、`delete`
- `mapping_confidence` 只能是 `high`、`medium`、`low`
- `output_file` 必须对应 `output_files` 或 `updated_files` 中的一个路径
- `summary` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "feature_mapping",
  "content": "场景 SCENARIO_001 可映射到多个候选子特性，当前选择置信度为 medium。",
  "recommendation": "后续阶段确认是否需要新增子特性或复用现有子特性。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `input_quality`、`feature_mapping`、`scenario_mapping`、`change_type`、`compatibility`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "该需求应映射到现有子特性，还是需要新增 NF 实例标识配置子特性？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；阻止生成可靠业务变更文件的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_design`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `implementation_modules`
- `code_files`
- `test_files`
- `api_design`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已为 3 个需求场景生成业务变更说明，识别为 AUSF NF 实例标识配置相关变更，并保留 1 项特性映射告警。",
  "input_requirement_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/NF实例标识配置/SR-001-配置稳定nfInstanceId_变更说明.md",
      "type": "feature_change",
      "operation": "created"
    }
  ],
  "updated_files": [],
  "feature_changes": [
    {
      "id": "FC-001",
      "scenario_id": "SCENARIO_001",
      "change_type": "new",
      "feature_id": "FEATURE_XXX",
      "feature_name": "网络功能生命周期管理",
      "subfeature_id": "SUBFEATURE_XXX",
      "subfeature_name": "NF实例标识配置",
      "mapping_confidence": "medium",
      "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/feature_changes/NF实例标识配置/SR-001-配置稳定nfInstanceId_变更说明.md",
      "summary": "AUSF 支持通过配置文件指定稳定的 nfInstanceId。"
    }
  ],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "feature_mapping",
      "content": "场景 SCENARIO_001 的子特性映射置信度为 medium。",
      "recommendation": "后续阶段确认是否复用现有子特性或新增 NF 实例标识配置子特性。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未进行架构设计、代码模块定位或实现方案设计。"
  ]
}
```
