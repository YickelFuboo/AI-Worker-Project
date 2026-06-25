# 代码到业务场景挖掘

## 功能描述

**结合代码事实 + 架构设计成果 + 历史系统方案，反向挖掘业务特性与业务场景**，产出 `features/` 目录下的业务视角内容。

本 skill 的核心边界是：**特性是特性，场景是场景；YAML 是索引框架，Markdown 是详细内容载体**。目录树只表达一级、二级、三级等业务特性；`feature.yaml` 只承载索引、meta、父子关系、leaf 文档引用和 traceability 锚点；特性的详细规格、业务约束、实现现状、架构关联说明必须写在 leaf 的 `spec.md`；子场景的主流程、分支流程、异常流程和边界流程必须写在 `SCENARIO_*.md`。不得用 YAML 替代 `spec.md` 或 `SCENARIO_*.md`，也不得把 `SCENARIO_*` 当成下一级特性节点。

## 统一结构模型

### 根索引 schema

`features/features_tree.yaml` 是根索引，不是递归总树。它只管理全局 `meta` 和 L1 特性入口，不展开 L2/L3/L4/L5，也不保存 leaf 的 `spec_path`、`arch_ref_path` 或 `scenarios` 明细。L2 及以下层级只由对应目录下的 `feature.yaml` 管理。

```yaml
meta:
  schema: root_feature_index_v1
  version: "4.0"
  last_updated: "YYYY-MM-DDTHH:MM:SS+08:00"
  last_modified_by: rev-code-to-scenario
  scope: 严格特性 (3GPP feature)，排除架构原则/基础流程/基础机制
  root_path: features/
  index_level: root
  child_level: L1
  stats:
    l1_count: 18
    feature_count: 130
    implemented_count: 16
    partial_count: 19
    planned_count: 95
    scenario_count: 18
child_features:
  - id: cat_xxx
    name: 一级特性中文名
    description: 一级特性摘要
    status: implemented | partial | planned
    level: L1
    path: 一级特性/feature.yaml
```

根索引不得出现递归 `features:`。如果需要查看某个 L1 下的 L2/L3，必须进入该 L1 目录读取 `feature.yaml`。

### 目录本地 feature.yaml schema

每个特性目录必须有一个统一命名的 `feature.yaml`。它不是全局树的递归副本，只描述**当前目录对应的特性节点 + 直接子特性索引 + 当前节点追踪信息**。

```yaml
meta:
  schema: directory_feature_node_v1
  version: "1.0"
  level: L1 | L2 | L3 | L4 | L5
  parent_feature_id: cat_xxx        # L1 为 null
  parent_feature_path: ../feature.yaml # L1 为 null；相对当前目录
  feature_path: feature.yaml
  last_updated: "YYYY-MM-DDTHH:MM:SS+08:00"
  last_modified_by: rev-code-to-scenario
  source: feature-catalog | code+architecture | code+architecture+intent
  confidence: high | medium | low
  intent_source_count: 0

feature:
  id: ...
  name: ...
  description: ...
  releases: [...]
  ref: "..."
  status: implemented | partial | planned
  level: L1 | L2 | L3 | L4 | L5
  path: features/{L1}/{L2}/feature.yaml
  spec_path: spec.md           # 可选；仅当前节点为最子特性且已有特性说明时使用
  arch_ref_path: arch_ref.yaml # 可选；仅当前节点有架构关联时使用
  last_modified: "YYYY-MM-DDTHH:MM:SS+08:00"
  last_modified_by: rev-code-to-scenario

child_features:                # 必填数组；只列直接子特性，不递归复制孙辈；leaf 为空数组
  - id: ...
    name: ...
    description: ...
    status: implemented | partial | planned
    level: L2 | L3 | L4 | L5
    path: 子特性目录/feature.yaml

scenarios:                     # 可选；仅当前节点为最子特性时使用
  - id: SCENARIO_001
    name: ...
    description: ...
    scenario_type: 成功场景 | 失败场景 | 回退场景 | 迁移场景 | 授权场景 | 计费场景 | 开放场景 | 分析场景 | 注册场景 | 发现场景
    path: SCENARIO_001_*.md

traceability:
  code_anchors:
    - repo: repos/amf
      path: internal/gmm/handler.go
      symbol: handleRequestedNssai
      line: 1102
      role: 子特性主入口
  test_anchors:
    - repo: repos/amf
      path: internal/gmm/handler_test.go
      test: TestName
      type: unit | integration | e2e
  architecture_refs:
    - element_id: amf
      path: architectures/logic_view/elements/amf/spec.md
```

`traceability` 是代码-测试-特性一致性的入口：事实域锚点能定位到代码、测试和架构元素时必须填写；不能可靠定位时保留空数组，不得编造符号、测试名或路径。

### 场景索引 schema

场景不是特性节点。场景只允许出现在最子特性节点的 `scenarios:` 下：

```yaml
scenarios:
  - id: SCENARIO_001
    name: ...
    description: ...
    scenario_type: 成功场景 | 失败场景 | 回退场景 | 迁移场景 | 授权场景 | 计费场景 | 开放场景 | 分析场景 | 注册场景 | 发现场景
    path: SCENARIO_001_*.md
```

### 文件产出规则

- **根索引**：`features/features_tree.yaml` 只保存全局 meta 和 L1 `child_features`，不得递归展开 L2 及以下，不得保存 leaf 的 `spec_path`、`arch_ref_path` 或 `scenarios`。
- **目录树就是特性树**：`features/{L1}/{L2}/{L3}/...` 只表达特性层级，不为场景单独建特性目录。
- **每个特性目录必须有 `feature.yaml`**：它描述当前特性、直接子特性索引和当前节点 traceability，不递归复制所有后代；YAML 只保留摘要、索引和锚点，不承载详细规格或场景流程。
- **最子特性必须保留 `spec.md` 作为详细规格载体**：描述该特性本身，包括业务定义、业务目标、范围边界、触发条件、约束、架构关联、实现现状和场景清单；这些详细内容不得迁移到 YAML。
- **最子特性下可以有多个 `SCENARIO_*.md` 作为场景流程载体**：场景必须是该特性下更具体的用户业务场景或业务结果路径，数量按特性语义、事实源和意图源决定，不得固定套用 `主流程 / 异常处理流程 / 边界条件流程` 三件套。流程步骤、前后置条件、异常处理和交互细节不得迁移到 YAML。
- **非最子特性只作为聚合节点**：有目录和 `feature.yaml`，但不生成描述场景的 `SCENARIO_*.md`。
- **架构依赖由最子特性目录下 `arch_ref.yaml` 承担**：场景文档引用它，不复制完整架构契约；目录级 `feature.yaml` 只在 `traceability.architecture_refs` 中保留指针。
- **废弃旧 L1 视图文件**：不得再生成 `features/{L1}/{L1}_feature.yaml`。

推荐物理结构：

```text
features/
  features_tree.yaml
  一级特性/
    feature.yaml
    二级特性/
      feature.yaml
      spec.md
      arch_ref.yaml
      SCENARIO_001_呼叫成功场景流程.md
      SCENARIO_002_呼叫失败场景流程.md
```

### 场景拆分原则

场景是最子特性的业务语义细分，不是模板化流程分类。每个场景必须回答“用户或外部业务方在什么条件下触发了什么业务结果”，例如语音特性可拆为呼叫成功、被叫无响应呼叫失败、被叫忙呼叫失败、EPS Fallback 成功/失败等；网络切片重路由可拆为经 N1MessageNotify 重定向、回退至 RAN Reroute NAS、目标 AMF 不可用导致重路由失败等。

场景数量必须按特性自身复杂度决定：简单能力可以只有 2 个场景，复杂能力可以有 4 个或更多。不得为了凑数给所有 leaf 固定生成 `主流程 / 异常处理流程 / 边界条件流程`。只有在事实源和意图源不足、但必须先保留骨架时，才允许临时低置信度生成泛化场景，并必须在后续增量更新中用业务语义场景替换。

`scenario_type` 应表达业务结果或业务路径类型，例如 `成功场景`、`失败场景`、`回退场景`、`迁移场景`、`授权场景`、`计费场景`、`开放场景`、`分析场景`，而不是机械复用流程模板。
## 双信息域抽取

代码反推只能告诉我们「现在在跑什么场景」，反推不出「为什么要有这个特性和场景、原设计的关键假设、异常处理的业务意图、场景之间的优先级与演进路线」。这些只能由人在历史系统方案中写明。本 skill 把输入做双信息域抽取：

| 信息域 | 主抽取源 | 写入位置 | 缺失时行为 |
|--------|---------|---------|-----------|
| **事实域**：调用链、状态机、接口签名、消息处理路径、异常分支现状 | 各代码仓 `.agent/*.md` + `spec.md` / `design.md` + 源码 + `architectures/logic_view/elements/` | 最子特性 `spec.md` 的实现现状/架构关联摘要、`SCENARIO_*.md` 的时序步骤/异常分支现状、`arch_ref.yaml`、目录 `feature.yaml` 的 `traceability` | 必须有，缺失时本 skill 不应执行 |
| **意图域**：特性业务目的、场景业务目的、关键设计假设、异常处理业务意图、优先级和演进路线 | `knowledge/历史方案/系统方案/` + `architectures/system_architectures.md` §5 + `architectures/decisions/ADR-*.md` | 最子特性 `spec.md` 的业务目标/设计意图、`SCENARIO_*.md` 的业务意图/异常处理意图、目录 `feature.yaml` 的 `meta.intent_source_count` | 章节留空或仅保留表头；只在 frontmatter / meta 的 `intent_source_count: 0` + `confidence: low` 中体现，不在正文写「无历史方案输入」之类提示 |

**分流规则**：事实域以代码为准；意图域以历史系统方案为准（除非 status=已废弃）；两域不互相覆盖，并存表达。冲突的事实差异记入差异摘要请人工裁决，不阻断产出。

## 所属 Agent

业务逆向 Agent

## 适用场景

- 存量项目缺少业务文档，需要从代码反向理解业务并融合历史系统方案的设计意图
- 架构逆向（`rev-arch-element-extract` + `rev-arch-system-design`）已完成，需要在业务视角补全特性与场景层
- 代码中有完整实现但缺少对应的特性说明和场景描述
- 需要建立业务特性 ↔ 业务场景 ↔ 架构元素 ↔ 代码实现 ↔ 测试用例的映射
- 历史系统方案新增 / 更新时，业务视角需同步抽取新意图

## 工作方式

### 执行步骤

**模式判定**：检查目标最子特性目录下 `feature.yaml`、`spec.md`、`arch_ref.yaml`、`SCENARIO_*.md` 是否存在且有 `last_modified` / `last_updated`；同时确认 `features_tree.yaml` 中 L1 入口指向该特性所属 L1 目录，父目录 `feature.yaml` 的 `child_features` 能逐级到达该节点。存在 → 增量更新模式；不存在 → 首次生成模式。

#### 首次生成模式

1. **加载事实源（代码仓）**：
   - 各代码仓 `.agent/*.md` 作为首选事实源。
   - 各仓 `spec.md` / `design.md` 理解仓库定位、技术栈、模块切分。
   - 扫描关键模块入口函数、消息处理函数、状态机实现、协议事件回调，识别业务特性和场景的代码足迹。
   - 提取调用链、状态迁移、测试用例路径作为场景的事实域内容和 `traceability`。

2. **加载架构设计成果**：
   - `architectures/logic_view/elements_tree.yaml`：理解元素与依赖。
   - 涉及元素的 `architectures/logic_view/elements/{name}/spec.md` / `interfaces.yaml` / `dependencies.yaml`：接口签名、协议、对端。
   - `architectures/system_architectures.md` §5 端到端流程索引：跨元素流程总图与编排意图。
   - `architectures/decisions/ADR-*.md`：与特性/场景相关决策的背景与权衡。

3. **加载意图源（历史系统方案）**：
   - 扫描 `knowledge/历史方案/系统方案/` 下所有 `.md` / `.pdf` / `.txt`（doc/docx/pptx 需先用 pandoc 转 md；本 skill 不做格式转换）。
   - `*系统设计说明书*.md` 提供特性级和端到端流程级意图，主要写入最子特性 `spec.md` 与场景「业务意图」。
   - `*场景方案设计说明书*.md` / `*场景*.md` 提供单场景级意图，主要写入 `SCENARIO_*.md` 的「关键假设」「异常处理意图」。
   - 空文件或仅占位文件不计入意图源。
   - 每条意图条目记录来源：`参考自 {solution_name} §X`。

4. **识别最子特性与业务场景**：
   - 特性节点来自目录树、根索引 L1 和目录级 `feature.yaml`，不得从 `SCENARIO_*` 反造特性节点。
   - 对每个最子特性生成一个 `spec.md`。
   - 对每个最子特性识别一个或多个**业务场景**：场景应来自用户动作、业务触发条件、成功/失败业务结果、回退路径、迁移路径、授权路径、计费路径、开放路径、分析路径等语义拆分。
   - 场景数量按特性语义决定，不得统一生成固定数量；不得把 `主流程 / 异常处理流程 / 边界条件流程` 当作所有特性的默认最终结果。
   - 场景写入该最子特性目录的 `feature.yaml` 中的 `scenarios:`，不得写入根索引或任何父节点 `child_features`。

5. **生成业务视角产物**：
   - **根索引**：`features/features_tree.yaml` 按 `root_feature_index_v1` 只写全局 `meta` 和 L1 `child_features`。
   - **目录本地特性节点**：每个特性目录生成 `feature.yaml`，按 `templates/feature_node_template.yaml`，只描述当前节点和直接子特性。
   - **最子特性说明**：`features/{L1}/{最子特性路径}/spec.md`，按 `templates/feature_spec_template.md`，描述特性本身。
   - **场景流程**：`features/{L1}/{最子特性路径}/SCENARIO_{NNN}_{中文名}_场景流程.md`，按 `templates/scenario_flow_template.md`。
   - **架构依赖**：`features/{L1}/{最子特性路径}/arch_ref.yaml`，关联架构元素与接口，只保留事实引用，不复制元素层契约。
   - **追踪信息**：目录 `feature.yaml` 的 `traceability` 从代码锚点、测试锚点和 `arch_ref.yaml` / 架构元素中提取；无法确认的锚点留空数组。

6. **frontmatter、meta 与置信度**：
   - `feature.yaml` 的 `meta` 必含 `schema` / `version` / `level` / `parent_feature_id` / `parent_feature_path` / `feature_path` / `last_updated` / `last_modified_by` / `source` / `intent_source_count` / `confidence`。
   - `spec.md` frontmatter 必含 `id` / `name` / `feature_path` / `last_modified` / `last_modified_by: rev-code-to-scenario` / `intent_source_count` / `confidence`。
   - `SCENARIO_*.md` frontmatter 必含 `id` / `name` / `feature_path`（只列特性路径，不把场景列成 L3 特性）/ `scenario_type` / `last_modified` / `last_modified_by: rev-code-to-scenario` / `intent_source_count` / `confidence`。
   - 置信度：事实源完整 + 意图源充足覆盖 → high；事实源完整 + 意图源部分覆盖 → medium；事实源完整 + 意图源缺失 → low；事实源不完整 → 不执行。
   - 不在正文中写「无历史方案输入」「置信度降级」「建议补齐...」之类提示。

#### 增量更新模式

1. **解析时间锚**：读取根索引 `meta.last_updated`，目录 `feature.yaml` 的 `meta.last_updated`，以及 `spec.md`、`SCENARIO_*.md`、`arch_ref.yaml` 的 `last_modified`。
2. **变更探测**：分别检查事实源、架构源、意图源是否晚于时间锚。
3. **章节映射**：
   - 入口函数 / 消息处理 / 状态机变更 → 刷新对应 `SCENARIO_*.md` 时序步骤、异常分支现状，并同步 `traceability.code_anchors`。
   - 测试新增 / 改名 / 删除 → 刷新 `traceability.test_anchors`。
   - 模块接口签名变更 → 刷新 `arch_ref.yaml`、`traceability.architecture_refs` 与 `spec.md` 架构关联摘要。
   - 特性边界或实现范围变化 → 刷新当前目录 `feature.yaml`、父目录 `child_features`、根索引 L1 摘要和 leaf `spec.md`。
   - 历史系统方案新增/更新 → 刷新 `spec.md`、`SCENARIO_*.md` 的意图域章节，以及目录 `feature.yaml` 的 `meta.intent_source_count` / `meta.confidence`。
4. **刷新决策**：无变更仅更新时间戳；局部变更只刷新对应章节与对应信息域；新增最子特性或核心系统方案首次纳入 → 触发首次生成式全量刷新。

### 一致性校验规则

- **结构一致性**：
  - `features_tree.yaml` 的 `meta.schema` 必须是 `root_feature_index_v1`，且只能有 `child_features`，不得出现递归 `features`。
  - 根索引每个 L1 `path` 必须存在，并指向 `features/{L1}/feature.yaml`。
  - 每个目录 `feature.yaml` 的 `meta.schema` 必须是 `directory_feature_node_v1`。
  - 父节点 `child_features[*].path` 必须存在，子节点 `meta.parent_feature_id` 必须等于父节点 `feature.id`。
  - 父节点不得递归复制孙辈；`child_features` 只能列直接子目录。
  - leaf 节点 `status=implemented` 时必须有 `spec.md`；有 `scenarios` 时每个 `path` 必须存在。
  - 不得存在 `features/{L1}/{L1}_feature.yaml` 或其他旧 L1 视图文件。

- **事实锚点一致性**：
  - `traceability.code_anchors[*].repo` 和 `path` 必须存在；如果填写 `symbol`，该符号应能在对应文件中定位。
  - `traceability.architecture_refs[*].path` 必须存在；`element_id` 应与架构元素目录或元素文档一致。
  - 事实域缺失时不得伪造锚点，应保留空数组并降低置信度或阻断执行。

- **测试覆盖一致性**：
  - `traceability.test_anchors[*].repo` 和 `path` 必须存在；如果填写 `test`，该测试名应能在对应文件中定位。
  - implemented leaf 缺少测试锚点时记为 warning；测试路径或测试名填写但无法定位时记为 error。
  - 需求类特性可没有测试锚点，但必须在差异摘要中说明覆盖缺口。

### 注意事项

- **根索引不保存 L2/L3/L4/L5**：`features_tree.yaml` 只保存 L1 入口；子特性必须放在对应目录的 `feature.yaml` 中。
- **不得把 `SCENARIO_*` 写入 `child_features`**：`SCENARIO_*` 不是一级/二级/三级特性。
- **每个特性目录必须有 `feature.yaml`**：该文件只描述当前特性节点、直接子特性索引和当前节点 traceability；详细规格、约束、实现说明和场景流程必须留在 Markdown 中。
- **不得在 `feature.yaml` 中递归复制完整后代**：父节点只列直接子节点，子节点详情由子目录自己的 `feature.yaml` 承担。
- **最子特性必须保留 `spec.md`**：它描述特性本身，而不是某个场景流程；不得把 `spec.md` 的详细规格压缩进 YAML。
- **场景文档只描述具体用户业务场景**：场景应按该特性的业务语义拆分，例如成功、失败、回退、迁移、授权、计费、开放、分析、注册、发现、重定位等具体业务结果或路径；不得把所有特性统一写成 `主流程 / 异常处理流程 / 边界条件流程`。
- **目录树就是特性树**：如果未来存在三级特性，应体现为目录和 `child_features` 子特性，而不是场景文件。
- **双信息域并存表达**：事实陈述与意图陈述并列时必须明示「事实域」「意图域」。
- **意图抽取是主动任务，不是装饰**：历史方案有材料而未抽取，视为产物不达标。
- **历史方案与代码冲突的分流规则**：事实层以代码为准并写差异摘要；意图层取最新 status=现行 的方案。
- **不抢架构层职责**：架构元素接口契约、依赖、协议由 `rev-arch-element-extract` 产出；本 skill 引用而不复制。
- **历史方案为空文件视为意图源缺失**：不计入 `intent_source_count`。
- **本 skill 不修改架构层和历史方案**：发现问题时写入差异摘要请人工裁决。

### 输出要求

- **根索引**：`features/features_tree.yaml`
  - 按 `root_feature_index_v1`。
  - 只列 L1 `child_features` 和全局 `meta.stats`，不递归列 L2/L3，不写场景。
- **目录本地特性节点**：`features/{L1 中文名}/{特性路径}/feature.yaml`
  - 按 `templates/feature_node_template.yaml`。
  - 描述当前特性、直接子特性索引、leaf 的 spec/arch/scenario 引用，以及 `traceability`。
- **最子特性说明**：`features/{L1 中文名}/{最子特性路径}/spec.md`
  - 按 `templates/feature_spec_template.md`。
  - 描述特性定义、业务目标、范围边界、触发条件、约束、架构关联、实现现状、场景清单。
- **场景流程**：`features/{L1 中文名}/{最子特性路径}/SCENARIO_{NNN}_{中文名}_场景流程.md`
  - 按 `templates/scenario_flow_template.md`。
  - frontmatter 的 `feature_path` 只列所属特性路径，不把场景列为特性层级。
- **架构依赖**：`features/{L1 中文名}/{最子特性路径}/arch_ref.yaml`。
- `last_modified` / `last_updated` 格式 ISO 8601 带时区（如 `2026-06-25T01:30:00+08:00`）。
- **参考源章节**：每个 `spec.md` 和 `SCENARIO_*.md` 末尾列出本次采纳的历史方案。
- **差异摘要**：一次性报告，不持久化到正文；包含事实/意图冲突项、置信度调整、新增意图条目数、新建/更新特性和场景数、traceability 覆盖缺口。
- 输出报告必须列出：生成的 `feature.yaml`、最子特性 `spec.md`、场景列表、置信度评估、代码映射、测试映射、架构映射、参考源采纳点数、差异摘要。
