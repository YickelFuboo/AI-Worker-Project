# 需求澄清与结构化分析

## 功能描述

将用户的自然语言业务诉求转化为结构化需求文档。该步骤只负责把需求本身说清楚：补齐 5W2H 要素，明确需求背景、目标、范围、业务场景、业务规则、验收标准和待确认问题，为后续质量门禁、特性变更分析、规格说明和设计文档提供输入。

该 skill 必须生成或更新 `requirements/{需求ID}/需求分析.md`，并在完成后直接返回结构化 JSON，供上层 workflow 或调度程序解析本次产物路径、摘要和待确认项。

## 所属 Agent

需求分析 Agent

## 适用场景

- 用户提出模糊或宽泛的业务需求（如"给计费加紧急呼叫豁免"、"支持多租户计费"）
- 需要将一段自然语言描述拆解为可执行的功能需求项
- 需要明确需求边界、适用角色、业务发生时机、业务发生位置、期望结果和量化约束
- 正向流程的第一步：需求 → 需求质量门禁 → 特性变更 → 规格 → 设计 → 代码

## 工作方式

### 执行步骤

1. **收集需求上下文**：阅读用户提供的需求说明、背景材料、产品简介、领域术语和协议规范；不得在本步骤读取或分析现有特性库来推断变更落点
2. **补齐 5W2H**：确认 Who（谁）、When（何时）、Where（何处）、What（做什么）、Why（为什么）、How（业务上如何表现）、How much（多少/量化约束）是否完整
3. **理解诉求**：与用户确认需求背景、目标用户、业务价值、触发条件、期望结果和验收口径
4. **业务场景拆解**：识别具体用户/业务场景，每个场景说明触发条件、参与角色、业务过程、业务结果和 Given-When-Then 验收标准；不得机械套用“正常流程/异常流程/边界条件”作为固定场景集合
5. **需求结构化**：按模板输出需求分析文档到 `requirements/{需求ID}/需求分析.md`，包含 5W2H、功能范围、业务场景、业务规则、非功能要求、验收标准和待确认项
6. **边界确认**：明确在范围内、范围外和待确认的事项，避免后续范围蔓延
7. **返回 JSON 结果**：生成或更新 `需求分析.md` 后，直接返回符合“输出 JSON 契约”的 JSON 对象，供 workflow 获取产物路径和摘要

### 注意事项

- 遇到需求中的关键不确定性（5W2H 缺口、边界、兼容性、输入输出格式、量化指标），必须先提问或在文档中标注“待确认”
- 需求分析聚焦“做什么”和“业务上如何表现”，不涉及技术实现细节
- `01-fwd-req-analysis` 只负责澄清和结构化需求本身，不负责判断现有业务能力的变更落点；这些判断必须先经过 `01-Q-fwd-req-quality-check` 质量门禁，再由 `02-fwd-feature-change-gen` 基于结构化需求和现有特性库完成
- 输出中不得包含确定性的现有业务能力映射、代码模块定位或影响结论
- 每个需求项应有明确的验收标准（Given-When-Then 格式）
- 输出前查阅 `knowledge/领域知识/` 中的协议规范和术语表，确保领域概念使用正确
- 参考 `knowledge/模板库/需求说明模板.md` 的格式

### 文件输出要求

- 文档路径：`requirements/{需求ID}/需求分析.md`
- 严格按模板格式输出：`templates/requirement_template.md`
- 包含完整的 5W2H、功能概述、业务场景、用例列表、业务规则、非功能要求、验收标准和待确认项
- 如有不明确项，在文档中标注“待确认”
- 输出 `requirements/{需求ID}/需求分析.md` 后，下一步应由 workflow 调用 `01-Q-fwd-req-quality-check`；本 skill 只在 JSON 中报告产物，不决定 workflow 下一步动作

## 输出 JSON 契约

最终回答必须是单个 JSON 对象，不能包裹在 Markdown 代码块中，不能附加解释文字。该 JSON 是本次 `01-fwd-req-analysis` 的机器可解析执行结果。

### 顶层字段

| 字段 | 类型 | 必填 | 约束 |
|------|------|------|------|
| `schema_version` | string | 是 | 固定为 `"1.0"` |
| `requirement_id` | string | 是 | 来自输入需求 frontmatter、目录名或本次分析生成的 ID |
| `status` | string | 是 | 只能是 `COMPLETED`、`COMPLETED_WITH_PENDING_QUESTIONS`、`BLOCKED`、`INCONCLUSIVE` |
| `summary` | string | 是 | 一句话概括本次结构化分析结果，不能为空 |
| `output_files` | array | 是 | 本次新生成文件列表；没有新文件时必须是空数组 `[]` |
| `updated_files` | array | 是 | 本次更新文件列表；没有更新文件时必须是空数组 `[]` |
| `key_points` | array | 是 | 结构化后的核心需求要点；无可提取要点时必须是空数组 `[]` |
| `pending_questions` | array | 是 | 待确认问题列表；无待确认项时必须是空数组 `[]` |
| `notes` | array | 是 | 其它非阻断说明；无说明时必须是空数组 `[]` |

### status 枚举语义

- `COMPLETED`：已生成或更新可供质量检查的 `需求分析.md`，且没有显式待确认项
- `COMPLETED_WITH_PENDING_QUESTIONS`：已生成或更新可供质量检查的 `需求分析.md`，但存在非阻断待确认项
- `BLOCKED`：缺少关键输入，无法生成可用的结构化需求文档
- `INCONCLUSIVE`：输入缺失、格式异常或需求意图无法判断，未能形成可靠分析结果

### status 与字段一致性

- `status = COMPLETED` 时：`output_files` 或 `updated_files` 至少 1 项，`pending_questions` 必须为空
- `status = COMPLETED_WITH_PENDING_QUESTIONS` 时：`output_files` 或 `updated_files` 至少 1 项，`pending_questions` 至少 1 项
- `status = BLOCKED` 时：`output_files` 和 `updated_files` 必须为空，`pending_questions` 至少 1 项，且问题必须说明阻断原因
- `status = INCONCLUSIVE` 时：`output_files` 和 `updated_files` 必须为空，`notes` 至少 1 项说明无法分析的原因

### file 对象

`output_files` 和 `updated_files` 中每一项必须包含：

```json
{
  "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/需求分析.md",
  "type": "requirement",
  "operation": "created"
}
```

字段限制：
- `path` 必须是仓库相对路径
- `type` 只能是 `requirement`、`supporting_material`
- `operation` 在 `output_files` 中只能是 `created`，在 `updated_files` 中只能是 `updated`
- `需求分析.md` 必须出现在 `output_files` 或 `updated_files` 中，除非 `status` 是 `BLOCKED` 或 `INCONCLUSIVE`

### pending_questions 对象

`pending_questions` 中每一项必须包含：

```json
{
  "id": "Q-001",
  "content": "外部检查或运维追踪应主要通过哪个入口观察 AUSF 的 NF Instance ID？",
  "blocking": false
}
```

字段限制：
- `id` 使用 `Q-001` 递增格式
- `content` 不能为空，必须是可直接询问用户的问题
- `blocking` 为布尔值；阻止生成结构化需求文档的问题为 `true`，可交给后续质量门禁判断的待确认项为 `false`

### key_points

`key_points` 必须是字符串数组，用于给 workflow 或调用方快速了解结构化后的核心诉求。每一项应是业务需求事实，不得包含代码位置、特性库映射或实现方案。

### 禁止字段

输出 JSON 中不得包含以下字段或同义字段：

- `next_action`
- `next_step`
- `readiness_for_02`
- `canProceedToNext`
- `target_skill`
- `workflow_decision`
- `feature_mapping`
- `affected_modules`

## 输出示例

```json
{
  "schema_version": "1.0",
  "requirement_id": "REQ-001-ausf-configurable-nf-instance-id",
  "status": "COMPLETED_WITH_PENDING_QUESTIONS",
  "summary": "已将 AUSF 支持配置 nfInstanceId 的原始诉求结构化为需求文档，覆盖合法配置、未配置和非法配置三类核心场景。",
  "output_files": [
    {
      "path": "requirements/REQ-001-ausf-configurable-nf-instance-id/需求分析.md",
      "type": "requirement",
      "operation": "created"
    }
  ],
  "updated_files": [],
  "key_points": [
    "AUSF 配置文件支持可选 nfInstanceId。",
    "合法 UUID v4 被用于 AUSF NF Instance ID。",
    "未配置 nfInstanceId 时保持自动生成 UUID。",
    "非法 nfInstanceId 时启动失败并提示配置错误。"
  ],
  "pending_questions": [
    {
      "id": "Q-001",
      "content": "外部检查或运维追踪应主要通过哪个入口观察 AUSF 的 NF Instance ID？",
      "blocking": false
    }
  ],
  "notes": [
    "本阶段未分析现有特性库、代码模块或具体变更落点。"
  ]
}
```
