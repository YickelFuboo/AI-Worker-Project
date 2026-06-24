# 架构元素抽取

## 功能描述

逆向抽取**一个代码仓对应的顶层架构元素**，生成或更新该元素的规格、接口索引、依赖索引文档。原则：**一个 repo 对应一个顶层架构元素**（如 amf 仓 → `amf` 元素；smf 仓 → `smf` 元素）。仓内 component/subsystem 层级归 `repos/{repo}/.agent/design.md`，本 skill 不再拆解。

输入优先级：**若仓内 `.agent/*.md` 已存在，优先读取作为元素信息源**（避免重复扫码）；仅当 `.agent/*.md` 缺失时，才降级扫源码 + 构建配置补齐。本 skill 产出的元素文档是**架构层自包含抽象**：用架构语言描述元素的角色/能力/质量要求/部署形态，**不在每行表格挂代码位置或 `.agent/*.md §N` 引用**（那会沦为代码定位索引，失去架构抽象价值）；`.agent/*.md` 仅在必要时以节末指引方式出现一次，用于读者跳转查阅实现细节。

## 所属 Agent

架构逆向 Agent

## 适用场景

- 存量项目缺少架构视图，需从代码仓反向构建跨仓元素图谱（elements_tree.yaml）
- 代码仓已有 `.agent/*.md`，需在架构层补一份元素级索引（定位/质量属性/部署/跨仓依赖）
- 仓内 `.agent/*.md` 增量刷新后，元素文档需同步增量刷新（以 `last_modified` 锚点判定）
- 跨仓影响分析（`fwd-arch-impact-analysis` / `fwd-cross-repo-impact`）需要元素级依赖图作为输入

## 工作方式

### 执行步骤

**模式判定**：
1. 读取 `architectures/logic_view/elements_tree.yaml`，按 `repo_path` 字段查找本仓对应的元素名（多数情况元素名 = repo 名）。
2. 检查 `architectures/logic_view/elements/{元素名}/spec.md` 是否存在且 YAML 头部有 `last_modified`。存在 → 增量更新模式；不存在 → 首次生成模式。

#### 首次生成模式

1. **元素名与 repo 关联确认**：从 `elements_tree.yaml` 读取本仓的 `element_name` 与 `repo_path` 映射；若 `elements_tree.yaml` 中无本仓条目，先在 `elements_tree.yaml` 新增一行（元素名默认取 repo 名，`element_type` 由 repo 角色判定，见步骤 4）。
2. **输入源加载（事实源：`.agent/*.md`；参考源：历史架构方案）**：

   **事实源（决定本元素 spec/interfaces/dependencies 的最终内容）**：
   - 优先读取 `repos/{repo}/.agent/spec.md`（业务功能 / SBI 接口索引 / 外部依赖 / 模块清单 → 元素职责、业务能力、提供的接口）
   - 优先读取 `repos/{repo}/.agent/interfaces.md`（接口契约详情 → §5 提供的接口引用）
   - 优先读取 `repos/{repo}/.agent/design.md`（设计目标 / 模块划分 / 数据对象 / 部署 / 质量属性 → §4 质量属性、§7 数据对象、§8 部署）
   - 优先读取 `repos/{repo}/.agent/rules/_index.md` 与 `rules/约束/可观测性.md`（可观测性约定 → §4 质量属性的可观测性子项）、`rules/约束/编码风格.md`（部署运行约定相关）
   - 优先读取 `repos/{repo}/.agent/DTFrame.md`（测试基础设施 → §4 质量属性的可测试性子项）
   - 若 `.agent/*.md` 部分缺失：对缺失部分降级扫源码 + 构建配置（go.mod / Makefile / CI）补齐，并在 spec.md §1 标注"本节由源码扫描补齐，置信度降级"
   - 若 `.agent/*.md` 全部缺失：执行全量源码扫描（参考 `rev-repo-to-spec-and-design` 的扫描策略），产出的同时**建议**触发 rev-repo-* 系列 skill 先补 `.agent/*.md`，本 skill 不直接生成 `.agent/*.md`

   **意图源（针对设计意图、原架构假设、原 DFX 目标值；与事实源并存表达）**：
   - 若 `knowledge/历史方案/架构方案/` 目录非空，扫描该目录下所有 `.md` / `.pdf` / `.txt` 文件（doc/docx/pptx 需投递时先用 pandoc 转 md；本 skill 不做格式转换）
   - 筛选与本元素相关的方案（按 frontmatter 中的 `related_elements` 或 `related_repos` 字段；无 frontmatter 时按文档内容是否出现本元素名）
   - 过滤 status=已废弃；status=已演进 沿 `superseded_by` 链找到现行方案再使用
   - **强抽取四类意图信息（不只校准，是主动归纳进产物）**：
     1. 元素定位与战略角色（§1 元素定位 / §2 职责描述）—— 当年为什么定义这个元素、它在系统中的战略意图
     2. 业务能力的设计意图（§3 业务能力的"原设计目的"列）—— 每个能力当年要解决的具体业务问题
     3. 质量属性的原目标值与策略原因（§4 质量属性的"原目标值 + 策略原因"列）—— 历史方案给的性能/可靠性/可用性数字与背后理由
     4. 部署形态与容量规格的原意图（§8 部署与运行）—— 当年规划的部署形态、容量上限、扩缩容策略
   - **事实/意图分流规则**：
     - 事实域（接口签名、依赖、协议、当前部署形态、当前 DFX 实现）以代码 + `.agent/*.md` 为准
     - 意图域（战略角色、设计目的、原 DFX 目标、原部署规划）以历史方案为准
     - 同章节内两者并存表达，明示「现状」与「原设计意图」标签
     - 事实层冲突（历史方案 vs 代码）→ 事实写代码版本，差异摘要标注「历史方案描述为 A，现行实现为 B，建议人工裁决」
   - **抽取留痕**：每条意图条目末尾标「参考自 {solution_name} §X」，便于读者回溯原文
   - **历史方案缺失**：意图域章节标注「无历史方案输入，本节仅基于现行代码归纳」，confidence 降级，但不阻断产出
3. **元素类型判定**：根据 repo 在系统中的角色判定 `element_type`：
   - `service`：对外提供 SBI/REST/RPC 接口的独立部署 NF（如 amf/smf/upf）
   - `component`：被其他元素以库形式依赖的组件（如 util/openapi 共享库）
   - `subsystem`：由多个 service 组合的子系统（如集合多个 NF 的网关子系统）
   - 一 repo 一顶层元素，类型唯一；仓内子层级归 `.agent/design.md`
4. **跨仓依赖抽取**：从 `.agent/spec.md` §4 外部依赖 或源码 import 关系，识别本元素依赖的其他架构元素（如 amf 依赖 nrf/ausf/udm/smf/pcf/nssf/udr），写入 `dependencies.yaml`，每条依赖引用对应元素名 + 接口 ID。
5. **质量属性归纳**：从 `.agent/design.md` §11 DFX 设计、§12 关键设计决策 + `.agent/rules/约束/可观测性.md`（可观测性约定）+ `.agent/DTFrame.md` §2 测试防护网分层，归纳元素级质量属性（性能/可靠性/可用性/可扩展性/安全性/可测试性/可观测性），每条标注来源 `.agent/*.md` 章节或 `rules/` 文件。
6. **生成元素文档**：按模板输出 `spec.md` / `interfaces.yaml` / `dependencies.yaml`，同步更新 `elements_tree.yaml` 本仓行的 `last_modified`。

#### 增量更新模式

1. **解析时间锚**：读取 `elements/{元素名}/spec.md` YAML 头部 `last_modified`
2. **变更探测**：
   - 源 A：`repos/{repo}/.agent/*.md` 任一文件的 YAML 头部 `last_modified` 晚于元素 spec.md 的 `last_modified` → 触发刷新
   - 源 B：`git log --before="<元素 spec.md last_modified>" -1 --format=%H` 定位锚点提交 → `git diff <锚点>..HEAD --name-status` 过滤本仓源码变更；若仅有非架构性变更（如纯测试/文档/CI 调整）→ 跳过
3. **变更分类与章节映射**：
   - `.agent/spec.md` 变更（业务功能 / 接口索引 / 模块清单）→ 刷新 spec.md §2 职责、§3 业务能力、§5 提供的接口索引、§7 数据对象
   - `.agent/interfaces.md` 变更（接口契约）→ 刷新 spec.md §5 接口引用 + `interfaces.yaml`（仅索引层，详情引用 interfaces.md）
   - `.agent/design.md` 变更（设计目标 / DFX / 部署 / 数据对象）→ 刷新 spec.md §4 质量属性、§7 数据对象、§8 部署
   - `.agent/rules/约束/可观测性.md` 变更（可观测性）→ 刷新 spec.md §4 可观测性子项
   - `.agent/DTFrame.md` 变更（测试防护网）→ 刷新 spec.md §4 可测试性子项
   - 跨仓依赖变更（spec.md §4 外部依赖 或源码 import 变化）→ 刷新 `dependencies.yaml` + `elements_tree.yaml` 依赖边
4. **刷新决策**：
   - 无变更 → 仅更新 `last_modified` 为检查时间并记录"无变更"
   - 局部变更 → 仅刷新对应章节，保持其他章节不变
   - `.agent/*.md` 整体重构（如 spec.md §2 业务功能重写）→ 触发首次生成式全量刷新
5. **刷新执行**：按模板比对现有内容，合并更新；架构层抽象描述保持稳定（角色/能力/质量要求不随代码细部变动），仅当架构层语义变化时才刷新对应章节
6. **更新时间戳与报告**：更新 `last_modified`，输出差异摘要

### 注意事项

- **一 repo 一顶层元素**：禁止把仓内模块拆成多个架构元素；仓内层级归 `.agent/design.md`，本 skill 只做仓→元素的顶层映射
- **优先读 .agent/*.md**：`.agent/*.md` 是 rev-repo-* skill 沉淀的活文档，是本 skill 的首选输入；直接扫码仅作降级补齐，且需在 spec.md 标注降级章节
- **架构层自包含抽象，禁止代码定位索引化**：元素 spec.md 用架构语言描述角色/能力/质量要求/部署形态；业务能力表只写"能力名 + 架构用途（一句话）"，接口表只写"接口名 + 协议 + 架构用途"，数据对象表只写"数据概念 + 架构作用 + 持久化"。**禁止在表格行里挂 `repos/{repo}/.agent/*.md §N` 或 `文件路径::符号名` 代码证据列**。`.agent/*.md` 仅在 §5/§6 节末以"契约详情见..."方式出现一次指引，供读者按需跳转。架构层文档与实现层文档职责分离，不互相抄写
- **元素名稳定性**：元素名一旦写入 `elements_tree.yaml` 不得随意改名（跨仓引用依赖此名）；若 repo 改名，元素名保留旧名并在 tree.yaml 加 `aliases` 字段
- **跨仓依赖必须双向校验**：本元素 `dependencies.yaml` 声明依赖 X 元素 → X 元素的 `interfaces.yaml` 必须有对应接口提供；不一致时标注"待人工裁决"
- **增量模式以 .agent/*.md 的 last_modified 为主要锚点**：元素文档跟随 .agent/*.md 漂移，不直接跟源码 commit；源码 commit 仅在 .agent/*.md 未及时刷新时作辅助探测
- **置信度评估**：基于 .agent/*.md 高置信度章节归纳的为高；降级扫码补齐的章节为中；.agent/*.md 全缺全量扫码的为低
- **不生成 .agent/*.md**：本 skill 只消费 .agent/*.md，不生产；若仓内 .agent/*.md 缺失，建议触发 rev-repo-* skill 补齐后再跑本 skill
- **历史架构方案是意图源、与事实源并存**：`knowledge/历史方案/架构方案/` 下文档用于强抽取设计意图、原 DFX 目标值、原部署规划、战略角色定位；与事实源（代码/`.agent/*.md`）并存表达，事实层冲突以事实源为准，意图层以历史方案为准；意图条目末尾必须留来源「参考自 {solution_name} §X」；doc/docx/pptx 等格式需投递时先用 pandoc 转 md，本 skill 不内嵌格式转换

### 输出要求

- **元素 spec.md**：`architectures/logic_view/elements/{元素名}/spec.md`，严格按模板 `templates/element_spec_template.md`
- **元素 interfaces.yaml**：`architectures/logic_view/elements/{元素名}/interfaces.yaml`，接口索引（ID + 名称 + 协议 + 方向 + `repos/{repo}/.agent/interfaces.md §N` 引用），不抄写完整契约
- **元素 dependencies.yaml**：`architectures/logic_view/elements/{元素名}/dependencies.yaml`，依赖的外部元素 + 接口 ID + 用途 + 引用 `.agent/spec.md §4` 证据
- **elements_tree.yaml**：`architectures/logic_view/elements_tree.yaml`，跨仓元素索引；本 skill 维护本仓对应行的 `element_name` / `element_type` / `repo_path` / `last_modified` / 依赖边
- YAML 元数据头部包含 `element_id`、`element_name`、`element_type`、`repo_path`、`last_modified`、`last_modified_by`（写入 `rev-arch-element-extract`）、`confidence`
- `last_modified` 格式为 ISO 8601 带时区（如 `2026-06-21T14:30:00+08:00`），用于增量模式下 `git log --before="<last_modified>"` 精确定位锚点提交；仅日期精度会导致同日内多次提交无法区分
- 元素 spec.md 正文分节：元素定位 / 职责描述 / 业务能力 / 质量属性 / 提供的接口 / 依赖的外部接口 / 关键架构数据 / 部署与运行
- 元素 spec.md 是**架构层抽象文档**：每节用架构语言自包含描述，禁止表格行挂代码证据列或 `.agent/*.md §N` 引用；`.agent/*.md` 仅在 §5/§6 节末以"契约详情见..."方式出现一次指引
- 降级扫码补齐的章节：在 §1 置信度说明中标注"本节由源码扫描补齐"，不在正文每行重复标注
- 输出架构抽取报告：识别的元素名、类型、置信度、依赖边统计、PlantUML 依赖图片段
