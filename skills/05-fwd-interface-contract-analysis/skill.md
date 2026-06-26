# 接口契约变更分析

## 功能描述

基于 `04-fwd-arch-impact-analysis` 生成的架构元素变更说明和 04 直接返回的结构化 JSON，对候选接口影响进行契约级细化分析。该步骤定义接口层面的新增、修改、删除或不变结论，描述请求、响应、错误、兼容性和调用方影响，并将接口契约分析结果写入对应架构变更文件或独立接口契约说明文件，同时直接返回结构化 JSON。

该 skill 只做接口契约级分析，不设计模块内部逻辑流，不定位代码文件或函数，不生成实现方案。

## 所属 Agent

架构设计 Agent

## 适用场景

- `04-fwd-arch-impact-analysis` 已生成或更新 `architecture_changes/**` 文件
- 04 已直接返回结构化 JSON，且 `status` 为 `COMPLETED` 或 `COMPLETED_WITH_WARNINGS`
- 04 JSON 中存在 `candidate_interface_impacts`，或架构变更文件中明确需要判断接口契约影响
- 需要精确描述接口新增、修改、删除、不变或未知结论
- 需要评估接口变更对调用方、被调方和兼容性约束的影响

## 输入要求

### 必需输入

1. `04-fwd-arch-impact-analysis` 返回的 JSON 对象
2. 04 JSON 中声明的 `architecture_changes/**` 文件
3. 受影响架构元素的 `interfaces.yaml` 或等价接口资料
4. 必要的元素依赖、调用关系或接口消费者资料

### 04 JSON 要求

允许执行 05 的 04 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`

不得执行 05 的 04 状态：

- `BLOCKED`
- `INCONCLUSIVE`

当 04 的 `status` 为 `BLOCKED` 或 `INCONCLUSIVE` 时，本 skill 不生成或更新接口契约分析内容，只返回 `status = BLOCKED` 或 `status = INCONCLUSIVE` 的 JSON 结果，并在 `warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取 04 JSON**：读取架构影响清单、候选接口影响、告警和架构变更文件路径
2. **读取架构变更文件**：理解每个架构元素的职责变化、依赖变化和候选接口影响
3. **读取接口资料**：加载受影响元素的 `interfaces.yaml` 或等价接口契约资料
4. **判定接口影响**：逐候选接口判断 `new`、`modify`、`delete`、`none` 或 `unknown`
5. **细化契约变更**：对确认受影响的接口描述请求、响应、错误语义、兼容性和调用方影响
6. **更新或生成接口契约内容**：将接口契约变更写入对应架构变更文件，或在必要时生成 `interface_contracts/**` 支撑文件
7. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出更新/生成文件、接口契约变更、兼容性影响、告警和待确认项

### 接口影响判定规则

- `new`：需求引入现有接口资料中不存在的新接口或新的外部契约
- `modify`：需求改变现有接口的业务语义、请求结构、响应结构、错误语义、调用时机或兼容性承诺
- `delete`：需求明确废止现有接口或契约能力
- `none`：架构元素变化不影响接口契约
- `unknown`：缺少接口资料或观察入口未确认，无法可靠判断

### 契约细化边界

05 可以输出：

- 接口 ID、接口名、提供方、调用方
- 请求字段、响应字段、错误语义的业务级变更说明
- 兼容性结论和调用方影响
- 迁移约束或待确认事项

05 不得输出：

- 模块内部调用流程
- 状态机或 PlantUML 逻辑流
- 代码文件、函数名、类名、测试文件
- 具体实现方案或代码改法

这些内容属于 06 或 07 的职责。

### 注意事项

- 每个接口契约变更必须可追溯到 `AI-XXX`、`CII-XXX` 和 `SCENARIO_XXX`
- 破坏性变更必须标记为 `breaking_change = true`，并说明受影响调用方和业务迁移约束
- 对 04 中 `impact_type = unknown` 的候选接口影响，若仍无法判断，不得强行落为 `modify`，必须保留 `unknown` 并记录待确认项
- 可以更新 04 生成的架构变更文件，但不得改写 04 的架构影响结论

### 文件输出要求

- 默认更新路径：04 JSON 中对应的 `architecture_changes/**/AR-XXX-..._变更说明.md`
- 可选新增路径：`requirements/{需求ID}/interface_contracts/{元素名}/IC-{序号}-{接口名}_契约变更.md`
- 若更新已有架构变更文件，必须在 JSON 的 `updated_files` 中列出
- 若新增接口契约支撑文件，必须在 JSON 的 `output_files` 中列出
- 如果无法可靠生成或更新任何接口契约内容，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `05-fwd-interface-contract-analysis` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 04 JSON 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次接口契约分析结果，不能为空 |
| `input_architecture_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `interface_contract_changes` | array | 是 | 接口契约变更清单；没有接口变更时必须列出 `impact_type = none` 或为空数组 `[]`，取决于 04 是否提供候选接口 |
| `compatibility_impacts` | array | 是 | 接口兼容性影响列表；无影响时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`interface_contract_changes` 至少 1 项，`warnings` 和 `pending_questions` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`interface_contract_changes` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files`、`interface_contract_changes` 和 `compatibility_impacts` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
  "type": "architecture_change",
  "operation": "updated"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `architecture_change`、`interface_contract`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### interface_contract_change 对象

`interface_contract_changes` 中每一项必须包含：

```json
{
  "id": "IC-001",
  "architecture_impact_id": "AI-001",
  "candidate_interface_impact_id": "CII-001",
  "element_id": "ARCH_ELEMENT_AUSF",
  "interface_id": "Nausf_Management_Register",
  "interface_name": "AUSF NF 注册信息上报",
  "impact_type": "modify",
  "source_scenarios": ["SCENARIO_001"],
  "request_change_summary": "无请求字段变化。",
  "response_change_summary": "响应契约无变化。",
  "error_change_summary": "非法配置导致启动失败，不形成运行期接口错误码变化。",
  "breaking_change": false,
  "affected_callers": ["NRF"],
  "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
  "summary": "接口契约不新增字段，但 NF Instance ID 的可观察值来源发生业务语义变化。"
}
```

字段限制：
- `id` 使用 `IC-001` 递增格式
- `architecture_impact_id` 必须对应 04 JSON 中的 `architecture_impacts[].id`
- `candidate_interface_impact_id` 必须对应 04 JSON 中的 `candidate_interface_impacts[].id`；如 04 未提供候选项，填写 `N/A`
- `impact_type` 只能是 `new`、`modify`、`delete`、`none`、`unknown`
- `source_scenarios` 至少 1 项
- `breaking_change` 为布尔值
- `affected_callers` 无内容时必须是空数组 `[]`
- `output_file` 必须对应 `output_files` 或 `updated_files` 中的一个路径；若未写文件，必须返回 `BLOCKED` 或 `INCONCLUSIVE`
- `request_change_summary`、`response_change_summary`、`error_change_summary`、`summary` 不能为空；如无变化填写“无”

### compatibility_impact 对象

`compatibility_impacts` 中每一项必须包含：

```json
{
  "id": "CI-001",
  "interface_contract_change_id": "IC-001",
  "risk_level": "low",
  "content": "接口字段不变，但外部观察到的 NF Instance ID 可由配置稳定指定。",
  "affected_parties": ["外部检查系统", "运维追踪系统"],
  "mitigation": "保持未配置时自动生成行为，避免影响存量调用方。"
}
```

字段限制：
- `id` 使用 `CI-001` 递增格式
- `interface_contract_change_id` 必须对应 `interface_contract_changes[].id`
- `risk_level` 只能是 `none`、`low`、`medium`、`high`
- `affected_parties` 无内容时必须是空数组 `[]`
- `content`、`mitigation` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "interface_contract",
  "content": "SCENARIO_001 的外部观察入口仍待确认，接口影响暂标记为 unknown。",
  "recommendation": "补充观察入口后重新细化接口契约影响。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `input_architecture`、`interface_contract`、`compatibility`、`caller_impact`、`boundary`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "外部检查或运维追踪应主要通过哪个接口观察 AUSF 的 NF Instance ID？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；阻止生成可靠接口契约结论的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_06`
- `readiness_for_design`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `logic_flows`
- `implementation_modules`
- `code_files`
- `test_files`
- `function_signatures`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已完成 1 项候选接口影响的契约分析，接口字段无明确变更，但外部观察入口仍待确认。",
  "input_architecture_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [],
  "updated_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
      "type": "architecture_change",
      "operation": "updated"
    }
  ],
  "interface_contract_changes": [
    {
      "id": "IC-001",
      "architecture_impact_id": "AI-001",
      "candidate_interface_impact_id": "CII-001",
      "element_id": "ARCH_ELEMENT_AUSF",
      "interface_id": "N/A",
      "interface_name": "稳定 NF Instance ID 外部观察入口",
      "impact_type": "unknown",
      "source_scenarios": ["SCENARIO_001"],
      "request_change_summary": "待确认观察入口后判断。",
      "response_change_summary": "待确认观察入口后判断。",
      "error_change_summary": "非法配置在启动阶段失败，暂不判断运行期接口错误码变化。",
      "breaking_change": false,
      "affected_callers": [],
      "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/architecture_changes/AUSF/AR-001-AUSF_变更说明.md",
      "summary": "外部观察入口未确认，接口契约影响保留为 unknown。"
    }
  ],
  "compatibility_impacts": [],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "interface_contract",
      "content": "SCENARIO_001 的外部观察入口仍待确认，接口影响暂标记为 unknown。",
      "recommendation": "补充观察入口后重新细化接口契约影响。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未进行逻辑流、代码模块、函数或测试文件设计。"
  ]
}
```
