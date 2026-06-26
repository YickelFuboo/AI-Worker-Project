# 逻辑流设计

## 功能描述

基于 `04-fwd-arch-impact-analysis` 和 `05-fwd-interface-contract-analysis` 的结构化结果，将已确认的架构元素变化和接口契约变化细化为模块级逻辑流程、数据流和状态转换设计。该步骤生成或更新 `requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`，并直接返回结构化 JSON，供后续 `06-Q-fwd-architecture-design-check` 和 `07-fwd-change-scope-refinement` 消费。

该 skill 做模块级逻辑设计，但不定位具体代码文件，不给出最终函数级变更清单，不生成测试文件清单；这些属于 07 或后续实现阶段职责。

## 所属 Agent

实现设计 Agent / 架构设计 Agent

## 适用场景

- `04-fwd-arch-impact-analysis` 已生成或更新架构变更文件并返回结构化 JSON
- `05-fwd-interface-contract-analysis` 已生成或更新接口契约内容并返回结构化 JSON
- 需要把架构元素变化和接口契约变化细化为模块间控制流、数据流和状态机
- 需要为 07 的代码变更范围细化提供设计输入

## 输入要求

### 必需输入

1. `04-fwd-arch-impact-analysis` 返回的 JSON 对象
2. 04 JSON 中声明的 `architecture_changes/**` 文件
3. `05-fwd-interface-contract-analysis` 返回的 JSON 对象
4. 05 JSON 中声明的更新文件或接口契约文件
5. 相关代码仓或模块的现有设计资料，例如仓级 `design.md`、模块 `design.md`、领域知识和协议规范

### 04/05 JSON 要求

允许执行 06 的 04 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`

允许执行 06 的 05 状态：

- `COMPLETED`
- `COMPLETED_WITH_WARNINGS`

不得执行 06 的 04 或 05 状态：

- `BLOCKED`
- `INCONCLUSIVE`

当 04 或 05 的 `status` 为 `BLOCKED` 或 `INCONCLUSIVE` 时，本 skill 不生成逻辑流设计文件，只返回 `status = BLOCKED` 或 `status = INCONCLUSIVE` 的 JSON 结果，并在 `warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取 04 JSON 和架构变更文件**：理解受影响架构元素、职责变化、依赖变化和候选接口影响
2. **读取 05 JSON 和接口契约内容**：理解接口新增、修改、删除、未知或无变化结论，以及兼容性影响
3. **读取现有设计资料**：加载相关代码仓和模块设计文档，只用于理解模块边界和既有逻辑，不输出代码文件级范围
4. **确定设计目标和模块边界**：将架构元素影响映射为模块级职责、参与对象和边界
5. **设计关键交互流程**：用 PlantUML 序列图描述模块间交互和外部系统交互
6. **设计状态与数据流**：如存在状态机，使用 PlantUML 状态图；描述核心数据对象及其流转
7. **生成逻辑流设计文件**：按模板输出到 `requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`
8. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出生成/更新文件、逻辑流、数据流、状态机、告警和待确认项

### 逻辑流设计边界

06 可以输出：

- 代码仓或模块名称
- 模块级参与对象和职责
- PlantUML 序列图和状态图
- 关键数据对象的业务字段含义
- 异常场景的逻辑处理策略
- 与 04/05 结果的追溯关系

06 不得输出：

- 最终代码文件路径变更清单
- 函数级新增/修改/删除清单
- 具体类名、函数名或测试文件
- 代码实现片段
- 工作量估算或提交计划

这些内容属于 07 或实现阶段职责。

### 注意事项

- 每个逻辑流必须可追溯到 `AI-XXX`、`IC-XXX` 或 `SCENARIO_XXX`
- 对 05 中 `impact_type = unknown` 的接口契约，逻辑流不得假设具体接口字段或错误码，只能记录待确认分支
- PlantUML 图必须描述模块边界上的可观察交互，不得变成代码级调用栈
- 逻辑流设计文件可以按代码仓聚合多个架构影响，但 JSON 中必须保持逐流程追溯

### 文件输出要求

- 输出路径：`requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`
- 严格按模板格式输出：`templates/implementation_design_template.md`
- 包含 PlantUML 序列图；如存在状态转换，包含 PlantUML 状态图
- 包含核心数据对象和数据流转说明
- 不得包含最终文件级/函数级变更清单；该清单由 07 生成
- 如果无法可靠生成任何逻辑流设计文件，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `06-fwd-logic-flow-design` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 04/05 JSON 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次逻辑流设计结果，不能为空 |
| `input_architecture_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `input_interface_status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `logic_flows` | array | 是 | 逻辑流程设计清单；没有流程时必须是空数组 `[]` |
| `data_flows` | array | 是 | 数据流设计清单；没有数据流时必须是空数组 `[]` |
| `state_machines` | array | 是 | 状态机设计清单；无状态机时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`logic_flows` 至少 1 项，`warnings` 和 `pending_questions` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`logic_flows` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files`、`logic_flows`、`data_flows` 和 `state_machines` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md",
  "type": "logic_design",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `logic_design`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### logic_flow 对象

`logic_flows` 中每一项必须包含：

```json
{
  "id": "LF-001",
  "name": "AUSF 启动时确定 NF Instance ID",
  "repo_name": "free5gc",
  "source_architecture_impacts": ["AI-001"],
  "source_interface_changes": ["IC-001"],
  "source_scenarios": ["SCENARIO_001", "SCENARIO_002", "SCENARIO_003"],
  "participants": ["AUSF 启动流程", "AUSF 配置读取", "AUSF NF 上下文"],
  "observable_result": "AUSF 使用配置的合法 nfInstanceId、未配置时自动生成、非法配置时启动失败。",
  "diagram_ref": "implementation_design.md#3.1-ausf-启动时确定-nf-instance-id",
  "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md",
  "summary": "描述 AUSF 启动阶段选择 NF Instance ID 的模块级交互。"
}
```

字段限制：
- `id` 使用 `LF-001` 递增格式
- `source_architecture_impacts` 至少 1 项
- `source_interface_changes` 可为空数组 `[]`
- `source_scenarios` 至少 1 项
- `participants` 至少 1 项，必须是模块级或系统边界参与方，不得是具体函数名
- `output_file` 必须对应 `output_files` 或 `updated_files` 中的一个路径
- `name`、`observable_result`、`diagram_ref`、`summary` 不能为空

### data_flow 对象

`data_flows` 中每一项必须包含：

```json
{
  "id": "DF-001",
  "logic_flow_id": "LF-001",
  "data_object": "NF Instance ID",
  "source": "AUSF 配置或自动生成机制",
  "destination": "AUSF NF 上下文",
  "transformation": "合法配置值直接成为 NF Instance ID；未配置时由系统生成；非法值触发配置错误。",
  "summary": "说明 NF Instance ID 在启动流程中的来源和流转。"
}
```

字段限制：
- `id` 使用 `DF-001` 递增格式
- `logic_flow_id` 必须对应 `logic_flows[].id`
- `data_object`、`source`、`destination`、`transformation`、`summary` 不能为空

### state_machine 对象

`state_machines` 中每一项必须包含：

```json
{
  "id": "SM-001",
  "logic_flow_id": "LF-001",
  "name": "AUSF NF Instance ID 配置状态",
  "states": ["未读取配置", "使用配置值", "自动生成", "配置错误"],
  "diagram_ref": "implementation_design.md#4.1-ausf-nf-instance-id-配置状态",
  "summary": "描述 nfInstanceId 配置状态对启动结果的影响。"
}
```

字段限制：
- `id` 使用 `SM-001` 递增格式
- `logic_flow_id` 必须对应 `logic_flows[].id`
- `states` 至少 1 项
- `name`、`diagram_ref`、`summary` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "interface_uncertainty",
  "content": "05 中外部观察入口仍为 unknown，逻辑流未固化具体接口字段。",
  "recommendation": "06-Q 检查时确认该不确定性已被保留而非被隐式假设。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `input_architecture`、`input_interface`、`logic_flow`、`data_flow`、`state_machine`、`boundary`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "外部观察 NF Instance ID 的具体入口是否需要在逻辑流中作为独立参与方展示？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；阻止生成可靠逻辑流设计的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_06Q`
- `readiness_for_07`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `code_files`
- `test_files`
- `function_changes`
- `function_signatures`
- `implementation_tasks`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已为 AUSF NF Instance ID 配置变更生成 1 个模块级逻辑流设计，并保留外部观察入口待确认项。",
  "input_architecture_status": "COMPLETED_WITH_WARNINGS",
  "input_interface_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md",
      "type": "logic_design",
      "operation": "created"
    }
  ],
  "updated_files": [],
  "logic_flows": [
    {
      "id": "LF-001",
      "name": "AUSF 启动时确定 NF Instance ID",
      "repo_name": "free5gc",
      "source_architecture_impacts": ["AI-001"],
      "source_interface_changes": ["IC-001"],
      "source_scenarios": ["SCENARIO_001", "SCENARIO_002", "SCENARIO_003"],
      "participants": ["AUSF 启动流程", "AUSF 配置读取", "AUSF NF 上下文"],
      "observable_result": "AUSF 使用配置的合法 nfInstanceId、未配置时自动生成、非法配置时启动失败。",
      "diagram_ref": "implementation_design.md#3.1-ausf-启动时确定-nf-instance-id",
      "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md",
      "summary": "描述 AUSF 启动阶段选择 NF Instance ID 的模块级交互。"
    }
  ],
  "data_flows": [
    {
      "id": "DF-001",
      "logic_flow_id": "LF-001",
      "data_object": "NF Instance ID",
      "source": "AUSF 配置或自动生成机制",
      "destination": "AUSF NF 上下文",
      "transformation": "合法配置值直接成为 NF Instance ID；未配置时由系统生成；非法值触发配置错误。",
      "summary": "说明 NF Instance ID 在启动流程中的来源和流转。"
    }
  ],
  "state_machines": [],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "input_interface",
      "content": "05 中外部观察入口仍为 unknown，逻辑流未固化具体接口字段。",
      "recommendation": "06-Q 检查时确认该不确定性已被保留而非被隐式假设。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未生成代码文件、函数级变更或测试文件范围。"
  ]
}
```
