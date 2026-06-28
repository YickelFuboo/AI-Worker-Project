# 架构影响域分析

## 功能描述

基于 `02-fwd-feature-change-gen` 生成的业务变更说明和 `03-fwd-inheritance-analysis` 生成的继承性报告（两者均已通过 `03-Q-fwd-scenario-impact-check` 门禁），分析业务变更和存量影响在架构层面的影响范围，确定受影响的架构元素、元素职责、依赖关系和候选接口影响，并生成 `architecture_changes/` 目录下的架构元素变更说明文件。

`03-Q-fwd-scenario-impact-check` 是场景分析质量门禁节点，由 workflow 依据其 `verdict` 决定是否调度本 skill。04 不消费 03-Q 的检查 JSON，也不依据 03-Q 的 `verdict` 自行决定是否执行；04 的输入是 02 和 03 已通过门禁的交付件本身。

该 skill 只做架构元素级影响域分析，不细化接口字段契约，不设计模块内部逻辑流，不定位代码文件或函数。完成后必须直接返回结构化 JSON，供后续接口契约变更分析和调度程序解析。

## 所属 Agent

架构设计 Agent

## 适用场景

- `02-fwd-feature-change-gen` 已生成业务变更说明并返回结构化 JSON，且该交付件已通过 `03-Q-fwd-scenario-impact-check` 门禁（由 workflow 判定）
- `03-fwd-inheritance-analysis` 已生成继承性报告并返回结构化 JSON，且该交付件已通过 `03-Q-fwd-scenario-impact-check` 门禁（由 workflow 判定）
- 需要把场景级业务变更和存量影响映射到架构元素、职责和依赖关系
- 需要为后续 `05-fwd-interface-contract-analysis` 和 `06-fwd-logic-flow-design` 提供架构侧输入

## 输入要求

### 必需输入

1. `requirements/{需求ID}/需求分析.md`
2. `02-fwd-feature-change-gen` 返回的 JSON 对象和其声明的 `feature_changes/**` 文件
3. `03-fwd-inheritance-analysis` 返回的 JSON 对象和其声明的 `feature_changes/继承性分析报告.md`
4. `architectures/**` 架构元素资料，例如 `architectures/logic_view/elements_tree.yaml`、元素 `spec.md`、`interfaces.yaml`
5. 相关子特性的 `arch_ref.yaml` 或等价架构关联资料

### 输入门禁前提

02 的业务变更说明和 03 的继承性报告必须是已通过 `03-Q-fwd-scenario-impact-check` 门禁的交付件。门禁判定由 workflow 依据 `03-Q` 的 `verdict` 完成：只有 `verdict` 为 `PASS` 或 `PASS_WITH_WARNINGS` 时，workflow 才调度本 skill。

04 不读取 `03-Q` 的检查 JSON，也不依据 `03-Q` 的 `verdict` 自行决定是否执行。04 的输入只有 02、03 的交付件（JSON 和文件）和架构资料。

如果 02 或 03 的交付件缺失、不可解析或内容不足以支撑架构影响分析，本 skill 返回 `status = INCONCLUSIVE` 或 `status = BLOCKED`，并在 `notes`、`warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取上游 JSON**：读取 02、03 JSON，确认场景变更、继承性影响和风险
2. **读取上游产物**：读取 02/03 JSON 声明的业务变更说明和继承性报告，确保架构影响能追溯到业务场景
3. **读取架构资料**：加载 `architectures/**`、元素规格和相关 `arch_ref.yaml`，识别候选架构元素
4. **建立场景到架构元素映射**：逐 `SCENARIO_XXX` 判断涉及的架构元素、元素职责和依赖关系变化
5. **判断架构变更类型**：逐架构元素判断是 `new`、`modify` 还是 `delete`
6. **识别候选接口影响**：只在接口级别识别可能新增、修改或删除的接口，不展开字段、参数、错误码等契约细节
7. **生成架构变更文件**：按模板输出到 `requirements/{需求ID}/architecture_changes/{元素名}/AR-{序号}-{元素名}_变更说明.md`
8. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出生成/更新文件、架构影响清单、候选接口影响、告警和待确认项

### 架构影响判定规则

- `new`：需求引入现有架构资料中不存在的新架构元素、职责或跨元素依赖
- `modify`：需求改变现有架构元素职责、依赖关系、对外协作方式或候选接口行为
- `delete`：需求明确废止现有架构元素、职责或依赖关系
- 无法判断是否影响某个架构元素时，记录为 `pending_questions`；不得强行映射

### 候选接口影响边界

04 可以说明：

- 哪个架构元素的哪个接口可能受影响
- 影响类型是 `new`、`modify`、`delete`、`none` 还是 `unknown`
- 该候选接口影响源自哪个业务场景或兼容性风险

04 不得说明：

- 字段级请求/响应结构
- 参数类型、错误码、枚举值
- API 版本策略或迁移细节
- 代码文件、函数签名或测试文件

这些内容属于 05、06 或 07 的职责。

### 注意事项

- 架构影响必须可追溯到 `SCENARIO_XXX`、`FC-XXX` 或 `SI-XXX`
- 可以继承 02、03 交付件中的非阻断告警上下文，但不得把它们改写成 workflow 调度决策
- 不进入接口契约详细设计、逻辑流设计、代码实现或测试设计
- 若发现接口契约需要细化，只记录为 `candidate_interface_impacts`，交给 05 处理

### 文件输出要求

- 输出路径：`requirements/{需求ID}/architecture_changes/{元素名}/AR-{序号}-{元素名}_变更说明.md`
- 严格按模板格式输出：`templates/arch_change_template.md`
- 每个架构变更文件描述一个主要架构元素的影响
- YAML 元数据头部必须包含 `requirement_id`、`element_id`、`element_name`、`change_type`、`created`
- 如果无法可靠生成任何架构变更文件，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `04-fwd-arch-impact-analysis` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 `需求分析.md` 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次架构影响域分析结果，不能为空 |
| `input_feature_change_status` | string | 是 | 上游 `02-fwd-feature-change-gen` 报告的状态，只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `input_inheritance_status` | string | 是 | 上游 `03-fwd-inheritance-analysis` 报告的状态，只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `architecture_impacts` | array | 是 | 架构元素级影响清单；没有影响时必须是空数组 `[]` |
| `candidate_interface_impacts` | array | 是 | 候选接口影响清单；没有接口影响时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`architecture_impacts` 至少 1 项，`warnings` 和 `pending_questions` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`architecture_impacts` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files`、`architecture_impacts` 和 `candidate_interface_impacts` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
  "type": "architecture_change",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `architecture_change`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### architecture_impact 对象

`architecture_impacts` 中每一项必须包含：

```json
{
  "id": "AI-001",
  "element_id": "ARCH_ELEMENT_AUSF",
  "element_name": "AUSF",
  "change_type": "modify",
  "source_scenarios": ["SCENARIO_001", "SCENARIO_002"],
  "source_impacts": ["SI-001"],
  "responsibility_change": "AUSF 启动阶段需要支持稳定 NF Instance ID 的配置来源。",
  "dependency_change": "无新增外部依赖。",
  "risk_level": "low",
  "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
  "summary": "AUSF 架构职责扩展为支持可配置 NF Instance ID。"
}
```

字段限制：
- `id` 使用 `AI-001` 递增格式
- `change_type` 只能是 `new`、`modify`、`delete`
- `source_scenarios` 至少 1 项，且必须对应上游 `SCENARIO_XXX`
- `risk_level` 只能是 `none`、`low`、`medium`、`high`
- `output_file` 必须对应 `output_files` 或 `updated_files` 中的一个路径
- `responsibility_change`、`dependency_change`、`summary` 不能为空；如无变化填写“无”

### candidate_interface_impact 对象

`candidate_interface_impacts` 中每一项必须包含：

```json
{
  "id": "CII-001",
  "architecture_impact_id": "AI-001",
  "element_id": "ARCH_ELEMENT_AUSF",
  "interface_id": "N/A",
  "impact_type": "unknown",
  "source_scenarios": ["SCENARIO_001"],
  "reason": "业务要求外部可观察稳定 NF Instance ID，但观察入口仍待确认。",
  "handoff_to_05": "由 05 判断是否涉及已有接口、注册信息、日志或健康检查输出契约。"
}
```

字段限制：
- `id` 使用 `CII-001` 递增格式
- `architecture_impact_id` 必须对应 `architecture_impacts[].id`
- `impact_type` 只能是 `new`、`modify`、`delete`、`none`、`unknown`
- `source_scenarios` 至少 1 项
- `reason`、`handoff_to_05` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "interface_uncertainty",
  "content": "SCENARIO_001 的外部观察入口仍未确认，候选接口影响标记为 unknown。",
  "recommendation": "05 阶段确认该观察入口是否涉及接口契约变更。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `input_quality`、`architecture_mapping`、`interface_uncertainty`、`compatibility`、`boundary`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "稳定 NF Instance ID 的外部观察入口应映射到哪个架构元素或接口？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；阻止生成可靠架构影响结论的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_05`
- `readiness_for_design`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `request_fields`
- `response_fields`
- `error_codes`
- `implementation_modules`
- `code_files`
- `test_files`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已识别 1 个受影响架构元素和 1 项候选接口影响，外部观察入口仍待 05 阶段确认。",
  "input_feature_change_status": "COMPLETED_WITH_WARNINGS",
  "input_inheritance_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
      "type": "architecture_change",
      "operation": "created"
    }
  ],
  "updated_files": [],
  "architecture_impacts": [
    {
      "id": "AI-001",
      "element_id": "ARCH_ELEMENT_AUSF",
      "element_name": "AUSF",
      "change_type": "modify",
      "source_scenarios": ["SCENARIO_001", "SCENARIO_002", "SCENARIO_003"],
      "source_impacts": ["SI-001", "SI-002", "SI-003"],
      "responsibility_change": "AUSF 启动阶段需要支持稳定 NF Instance ID 的配置来源，并在非法配置时拒绝启动。",
      "dependency_change": "无新增外部依赖。",
      "risk_level": "low",
      "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
      "summary": "AUSF 架构职责扩展为支持可配置 NF Instance ID。"
    }
  ],
  "candidate_interface_impacts": [
    {
      "id": "CII-001",
      "architecture_impact_id": "AI-001",
      "element_id": "ARCH_ELEMENT_AUSF",
      "interface_id": "N/A",
      "impact_type": "unknown",
      "source_scenarios": ["SCENARIO_001"],
      "reason": "业务要求外部可观察稳定 NF Instance ID，但观察入口仍待确认。",
      "handoff_to_05": "由 05 判断是否涉及已有接口、注册信息、日志或健康检查输出契约。"
    }
  ],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "interface_uncertainty",
      "content": "SCENARIO_001 的外部观察入口仍未确认，候选接口影响标记为 unknown。",
      "recommendation": "05 阶段确认该观察入口是否涉及接口契约变更。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未进行接口字段、逻辑流、代码模块或测试文件设计。"
  ]
}
```
