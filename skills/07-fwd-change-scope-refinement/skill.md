# 变更范围细化

## 功能描述

基于 `06-fwd-logic-flow-design` 生成的逻辑流设计文件和其返回的结构化 JSON（已通过 `06-Q-fwd-architecture-design-check` 门禁），将模块级设计细化为代码仓、模块、文件、函数和数据结构级的变更范围清单。该步骤生成 `repo_changes/overview.md` 和必要的仓级细化内容，并直接返回结构化 JSON，供后续编码实现、测试设计或工作量评估阶段消费。

`06-Q-fwd-architecture-design-check` 是架构分析综合质量门禁节点，由 workflow 依据其 `verdict` 决定是否调度本 skill。07 不消费 06-Q 的检查 JSON，也不依据 06-Q 的 `verdict` 自行决定是否执行；07 的输入是 04、05、06 已通过门禁的分析交付件本身。

该 skill 是正向流程中首次允许进入代码文件和函数级范围的阶段。它只定义“需要改哪里、改什么类型、为什么改”，不直接写业务代码，不生成测试用例实现，不提交代码。

## 所属 Agent

实现设计 Agent

## 适用场景

- `06-fwd-logic-flow-design` 已生成或更新 `repo_changes/{仓名}/implementation_design.md` 并返回结构化 JSON，且该交付件已通过 `06-Q-fwd-architecture-design-check` 门禁（由 workflow 判定）
- 需要把架构与逻辑设计映射为代码仓、模块、文件、函数、数据结构级变更范围
- 需要为编码实现或测试设计提供可追溯的修改目标清单

## 输入要求

### 必需输入

1. `06-fwd-logic-flow-design` 返回的 JSON 对象
2. 06 JSON 中声明的 `repo_changes/**/implementation_design.md` 文件
3. `04-fwd-arch-impact-analysis` 和 `05-fwd-interface-contract-analysis` 的交付件，用于追溯架构影响和接口契约变化
4. 相关代码仓的仓级规格、设计文档、模块设计文档和约束文件
5. 必要的代码阅读结果，用于定位文件、函数和数据结构

### 输入门禁前提

04、05、06 的分析交付件必须是已通过 `06-Q-fwd-architecture-design-check` 门禁的内容。门禁判定由 workflow 依据 `06-Q` 的 `verdict` 完成：只有 `verdict` 为 `PASS` 或 `PASS_WITH_WARNINGS` 时，workflow 才调度本 skill。

07 不读取 `06-Q` 的检查 JSON，也不依据 `06-Q` 的 `verdict` 自行决定是否执行。07 的输入只有 04、05、06 的分析交付件（JSON 和文件）以及代码仓资料。

如果 06 的逻辑流设计交付件缺失、不可解析或内容不足以支撑代码范围细化，本 skill 返回 `status = INCONCLUSIVE` 或 `status = BLOCKED`，并在 `notes`、`warnings` 或 `pending_questions` 中说明原因。

## 工作方式

### 执行步骤

1. **读取 06 JSON 和逻辑设计文件**：理解逻辑流、数据流、状态机、参与模块和追溯关系
2. **读取 04/05 交付件**：理解架构影响和接口契约变化，继承其非阻断告警和待确认项
3. **读取仓级约束和设计资料**：加载相关代码仓 `spec.md`、`design.md`、模块设计文档和 `.agent/rules/` 约束
4. **读取代码定位范围**：使用代码阅读工具定位涉及的文件、函数、数据结构和调用点
5. **映射变更范围**：将 `LF-XXX`、`DF-XXX`、`SM-XXX` 映射到代码仓、模块、文件、函数和数据结构级变更项
6. **评估依赖和优先级**：标注变更项之间的依赖关系、优先级和风险
7. **生成代码变更总览**：输出 `requirements/{需求ID}/repo_changes/overview.md`
8. **更新仓级设计文件**：如需补充文件级或函数级范围，更新 `requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`
9. **返回 JSON 结果**：直接返回符合“输出 JSON 契约”的 JSON 对象，列出生成/更新文件、代码范围清单、依赖、风险、告警和待确认项

### 变更类型规则

- `new`：新增文件、函数、数据结构、配置项或模块职责
- `modify`：修改现有文件、函数、数据结构、配置项或模块职责
- `delete`：删除或废止现有文件、函数、数据结构、配置项或模块职责
- `unknown`：需要人工确认或进一步代码阅读后才能定位的范围

### 边界规则

07 可以输出：

- 代码仓名、模块名、文件路径
- 函数、方法、结构体、配置项或数据结构名称
- 新增、修改、删除或未知的变更类型
- 与 06 逻辑流、数据流、状态机的追溯关系
- 依赖顺序、优先级、风险和待确认项

07 不得输出：

- 完整业务代码实现
- 单元测试或集成测试源码
- 具体提交命令或分支策略
- workflow 调度决策

### 注意事项

- 每个代码范围项必须可追溯到 `LF-XXX`、`DF-XXX` 或 `SM-XXX`
- 如果 04、05、06 交付件存在非阻断告警，07 必须在 `warnings` 或 `pending_questions` 中保留相关上下文，不得隐式消除
- 对 `unknown` 接口影响或设计不确定项，不得强行映射为确定代码改动
- 读取代码时应遵守仓级 `.agent/rules/` 约束；如约束缺失或冲突，记录为告警或待确认项

### 文件输出要求

- 总览输出：`requirements/{需求ID}/repo_changes/overview.md`
- 仓级细化：`requirements/{需求ID}/repo_changes/{仓名}/implementation_design.md`
- `overview.md` 严格按模板格式输出：`templates/repo_changes_overview_template.md`
- 输出必须包含文件级变更清单、函数/方法级变更清单、数据结构或配置项变更清单、依赖顺序和风险项
- 如果无法可靠生成任何代码变更范围文件，必须返回 `BLOCKED` 或 `INCONCLUSIVE`，并说明原因

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `07-fwd-change-scope-refinement` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自 06 JSON 或输入目录名 |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次变更范围细化结果，不能为空 |
| `input_logic_design_status` | string | 是 | 上游 `06-fwd-logic-flow-design` 报告的状态，只能是 `COMPLETED`、`COMPLETED_WITH_WARNINGS`、`BLOCKED`、`INCONCLUSIVE` |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `repo_scopes` | array | 是 | 仓级变更范围清单；没有范围时必须是空数组 `[]` |
| `file_changes` | array | 是 | 文件级变更清单；没有文件变更时必须是空数组 `[]` |
| `function_changes` | array | 是 | 函数/方法级变更清单；没有函数变更时必须是空数组 `[]` |
| `data_structure_changes` | array | 是 | 数据结构或配置项变更清单；没有变更时必须是空数组 `[]` |
| `dependency_order` | array | 是 | 建议变更依赖顺序；无顺序要求时必须是空数组 `[]` |
| `risks` | array | 是 | 代码范围风险列表；无风险时必须是空数组 `[]` |
| `warnings` | array | 是 | 非阻断告警列表；无告警时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无问题时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`repo_scopes` 至少 1 项，`file_changes` 至少 1 项，`warnings` 和 `pending_questions` 必须为空
- `status = COMPLETED_WITH_WARNINGS` 时：`output_files` 或 `updated_files` 至少 1 项，`repo_scopes` 至少 1 项，`warnings` 至少 1 项或 `pending_questions` 至少 1 项或 `risks` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`warnings` 至少 1 项或 `pending_questions` 至少 1 项
- `status = INCONCLUSIVE` 时：`output_files`、`updated_files`、`repo_scopes`、`file_changes`、`function_changes` 和 `data_structure_changes` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/overview.md",
  "type": "repo_change_overview",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `repo_change_overview`、`repo_implementation_design`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`

### repo_scope 对象

`repo_scopes` 中每一项必须包含：

```json
{
  "id": "RSCOPE-001",
  "repo_name": "free5gc",
  "source_logic_flows": ["LF-001"],
  "scope_summary": "AUSF 启动配置读取和 NF 上下文初始化范围需要调整。",
  "change_count": {
    "files": 3,
    "functions": 4,
    "data_structures": 1
  },
  "priority": "high",
  "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md"
}
```

字段限制：
- `id` 使用 `RSCOPE-001` 递增格式
- `source_logic_flows` 至少 1 项，且必须对应 06 JSON 中的 `logic_flows[].id`
- `priority` 只能是 `high`、`medium`、`low`
- `change_count.files`、`change_count.functions`、`change_count.data_structures` 必须是非负整数
- `output_file` 必须对应 `output_files` 或 `updated_files` 中的一个路径
- `scope_summary` 不能为空

### file_change 对象

`file_changes` 中每一项必须包含：

```json
{
  "id": "FILE-001",
  "repo_scope_id": "RSCOPE-001",
  "repo_name": "free5gc",
  "file_path": "NFs/ausf/internal/context/context.go",
  "change_type": "modify",
  "source_logic_flows": ["LF-001"],
  "source_data_flows": ["DF-001"],
  "reason": "该文件承载 AUSF NF 上下文中的 NF Instance ID 初始化职责。",
  "expected_change": "增加从配置值确定 NF Instance ID 的范围，并保留未配置自动生成行为。",
  "risk_level": "medium"
}
```

字段限制：
- `id` 使用 `FILE-001` 递增格式
- `repo_scope_id` 必须对应 `repo_scopes[].id`
- `change_type` 只能是 `new`、`modify`、`delete`、`unknown`
- `source_logic_flows` 至少 1 项
- `source_data_flows` 可为空数组 `[]`
- `risk_level` 只能是 `none`、`low`、`medium`、`high`
- `repo_name`、`file_path`、`reason`、`expected_change` 不能为空；如无法定位路径，`change_type` 必须为 `unknown` 且 `file_path` 填写 `待确认`

### function_change 对象

`function_changes` 中每一项必须包含：

```json
{
  "id": "FUNC-001",
  "file_change_id": "FILE-001",
  "symbol": "InitAusfContext",
  "change_type": "modify",
  "source_logic_flows": ["LF-001"],
  "expected_change": "在初始化 AUSF NF 上下文时接入 nfInstanceId 配置值校验和选择逻辑。",
  "dependency": ["DATA-001"]
}
```

字段限制：
- `id` 使用 `FUNC-001` 递增格式
- `file_change_id` 必须对应 `file_changes[].id`
- `change_type` 只能是 `new`、`modify`、`delete`、`unknown`
- `source_logic_flows` 至少 1 项
- `dependency` 无内容时必须是空数组 `[]`
- `symbol`、`expected_change` 不能为空；如无法定位函数，`change_type` 必须为 `unknown` 且 `symbol` 填写 `待确认`

### data_structure_change 对象

`data_structure_changes` 中每一项必须包含：

```json
{
  "id": "DATA-001",
  "repo_scope_id": "RSCOPE-001",
  "name": "AUSF 配置结构中的 nfInstanceId 配置项",
  "change_type": "new",
  "source_data_flows": ["DF-001"],
  "expected_change": "新增可选 nfInstanceId 配置承载位置，并约束为合法 UUID v4。",
  "affected_files": ["config/ausfcfg.yaml", "NFs/ausf/pkg/factory/config.go"]
}
```

字段限制：
- `id` 使用 `DATA-001` 递增格式
- `repo_scope_id` 必须对应 `repo_scopes[].id`
- `change_type` 只能是 `new`、`modify`、`delete`、`unknown`
- `source_data_flows` 至少 1 项
- `affected_files` 无内容时必须是空数组 `[]`
- `name`、`expected_change` 不能为空

### dependency_order 对象

`dependency_order` 中每一项必须包含：

```json
{
  "id": "DEP-001",
  "before": "DATA-001",
  "after": "FUNC-001",
  "reason": "函数初始化逻辑依赖配置结构先具备 nfInstanceId 承载位置。"
}
```

字段限制：
- `id` 使用 `DEP-001` 递增格式
- `before`、`after` 必须引用本 JSON 中的变更项 ID
- `reason` 不能为空

### risk 对象

`risks` 中每一项必须包含：

```json
{
  "id": "R-001",
  "risk_level": "medium",
  "related_changes": ["FILE-001", "FUNC-001"],
  "content": "NF Instance ID 初始化路径影响 AUSF 启动结果，错误处理需要保持清晰。",
  "mitigation": "实现阶段优先覆盖合法配置、未配置和非法配置三类路径。"
}
```

字段限制：
- `id` 使用 `R-001` 递增格式
- `risk_level` 只能是 `low`、`medium`、`high`
- `related_changes` 至少 1 项
- `content`、`mitigation` 不能为空

### warning 对象

`warnings` 中每一项必须包含：

```json
{
  "id": "W-001",
  "dimension": "upstream_architecture_check",
  "content": "06-Q 保留外部观察入口 unknown 告警，07 未将其映射为确定接口代码改动。",
  "recommendation": "实现前确认观察入口是否需要额外代码范围。"
}
```

字段限制：
- `id` 使用 `W-001` 递增格式
- `dimension` 建议使用 `upstream_architecture_check`、`code_mapping`、`dependency_order`、`repo_rules`、`boundary`
- `content`、`recommendation` 不能为空

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "AUSF nfInstanceId 配置项在配置文件中的准确层级是否已确定？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户或上游分析阶段的问题
- `blocking` 为布尔值；阻止生成可靠代码范围清单的问题为 `true`

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_implementation`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `commit_plan`
- `branch_name`
- `pull_request`
- `test_code`
- `implementation_code`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_WARNINGS",
  "summary": "已将 AUSF NF Instance ID 配置逻辑细化为 1 个代码仓、3 个文件和 4 个函数级变更范围，并保留配置层级待确认项。",
  "input_logic_design_status": "COMPLETED_WITH_WARNINGS",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/overview.md",
      "type": "repo_change_overview",
      "operation": "created"
    }
  ],
  "updated_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md",
      "type": "repo_implementation_design",
      "operation": "updated"
    }
  ],
  "repo_scopes": [
    {
      "id": "RSCOPE-001",
      "repo_name": "free5gc",
      "source_logic_flows": ["LF-001"],
      "scope_summary": "AUSF 启动配置读取和 NF 上下文初始化范围需要调整。",
      "change_count": {
        "files": 3,
        "functions": 4,
        "data_structures": 1
      },
      "priority": "high",
      "output_file": "requirements/REQ-001-ausf-configurable-nf-instance-id/repo_changes/free5gc/implementation_design.md"
    }
  ],
  "file_changes": [
    {
      "id": "FILE-001",
      "repo_scope_id": "RSCOPE-001",
      "repo_name": "free5gc",
      "file_path": "NFs/ausf/internal/context/context.go",
      "change_type": "modify",
      "source_logic_flows": ["LF-001"],
      "source_data_flows": ["DF-001"],
      "reason": "该文件承载 AUSF NF 上下文中的 NF Instance ID 初始化职责。",
      "expected_change": "增加从配置值确定 NF Instance ID 的范围，并保留未配置自动生成行为。",
      "risk_level": "medium"
    }
  ],
  "function_changes": [
    {
      "id": "FUNC-001",
      "file_change_id": "FILE-001",
      "symbol": "InitAusfContext",
      "change_type": "modify",
      "source_logic_flows": ["LF-001"],
      "expected_change": "在初始化 AUSF NF 上下文时接入 nfInstanceId 配置值校验和选择逻辑。",
      "dependency": ["DATA-001"]
    }
  ],
  "data_structure_changes": [
    {
      "id": "DATA-001",
      "repo_scope_id": "RSCOPE-001",
      "name": "AUSF 配置结构中的 nfInstanceId 配置项",
      "change_type": "new",
      "source_data_flows": ["DF-001"],
      "expected_change": "新增可选 nfInstanceId 配置承载位置，并约束为合法 UUID v4。",
      "affected_files": ["config/ausfcfg.yaml", "NFs/ausf/pkg/factory/config.go"]
    }
  ],
  "dependency_order": [
    {
      "id": "DEP-001",
      "before": "DATA-001",
      "after": "FUNC-001",
      "reason": "函数初始化逻辑依赖配置结构先具备 nfInstanceId 承载位置。"
    }
  ],
  "risks": [
    {
      "id": "R-001",
      "risk_level": "medium",
      "related_changes": ["FILE-001", "FUNC-001"],
      "content": "NF Instance ID 初始化路径影响 AUSF 启动结果，错误处理需要保持清晰。",
      "mitigation": "实现阶段优先覆盖合法配置、未配置和非法配置三类路径。"
    }
  ],
  "warnings": [
    {
      "id": "W-001",
      "dimension": "upstream_architecture_check",
      "content": "06-Q 保留外部观察入口 unknown 告警，07 未将其映射为确定接口代码改动。",
      "recommendation": "实现前确认观察入口是否需要额外代码范围。"
    }
  ],
  "pending_questions": [],
  "notes": [
    "本阶段未生成实现代码、测试代码或 workflow 调度决策。"
  ]
}
```
