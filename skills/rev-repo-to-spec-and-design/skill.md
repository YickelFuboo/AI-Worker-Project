# 代码仓规格与设计逆向生成

## 功能描述

为代码仓逆向生成规格与设计文档，支持任意规模的仓与嵌套模块结构：
- **仓级必产**：`repos/{repo}/.agent/` 下的 spec.md / design.md / interfaces.md（rules.md 与 DTFrame.md 由各自独立 skill 生成）
- **模块级按需递归产出**：遍历仓内目录树，对**每个源码文件数 > 800 的目录**，在 `repos/{repo}/.agent/modules/{目录相对路径}/` 下产 spec.md + design.md；若该目录的子目录也 >800，子目录同样产出，形成多层嵌套，无层数限制

提取类/函数结构、数据结构、状态机和关键流程，生成对应级别的 spec.md 和 design.md（含 PlantUML 图）。

## 所属 Agent

实现逆向 Agent

## 适用场景

- 存量项目逆向还原时，需为仓与大型模块生成规格与设计文档
- 仓/模块代码变更后需增量更新设计文档
- 存量反向分析流程的第三步（业务→架构→实现）

## 工作方式

### 执行步骤

**模式判定**：
- 仓级：检查 `repos/{repo}/.agent/spec.md` 与 `design.md` 是否存在且 YAML 头部有 `last_modified`。两者均存在 → 仓级增量更新模式；任一不存在 → 仓级首次生成模式
- 模块级：对每个 >800 文件的目录，检查对应 `modules/{路径}/spec.md` 与 `design.md` 是否存在。均存在 → 该模块增量更新；任一不存在 → 该模块首次生成

#### 首次生成模式

1. **仓级文档生成**：
   - 扫描全仓源码，识别业务功能、DFX、技术栈、外部依赖、对外接口、跨仓协作、构建部署
   - 生成 `spec.md` / `design.md` / `interfaces.md` 三文件（共享一次扫描结果）
2. **目录树遍历**：递归遍历仓内目录，统计每个目录的源码文件数
3. **模块级文档生成**：对每个 >800 文件的目录：
   - 读取该模块源码，加载仓级 `design.md` 理解模块在仓中的位置
   - 参考 `knowledge/领域知识/` 中的协议规范和常见模式
   - 代码分析：提取类/函数清单与签名、识别核心数据结构、提取状态机、追踪关键调用链
   - 逻辑还原：从代码推导设计意图，绘制 PlantUML 状态图和序列图
   - 生成 `modules/{路径}/spec.md`（用 module_spec_template）和 `modules/{路径}/design.md`（用 module_design_template）
4. **递归子模块**：若该 >800 目录下还有 >800 子目录，对子目录重复步骤 3，产出 `modules/{父路径}/{子路径}/spec.md` 与 `design.md`
5. **更新仓级模块清单**：仓级 design.md 模块清单列出所有产了模块级 md 的目录路径（含嵌套层级），不重复展开详设

#### 增量更新模式

1. **仓级时间锚**：读取仓级 spec.md / design.md / interfaces.md YAML 头部 `last_modified`，取最早者为锚点
2. **定位锚点提交**：`git log --before="<last_modified>" -1 --format=%H`
3. **变更探测**：`git diff <锚点提交>..HEAD --name-status`，按文件路径归入影响域
4. **仓级章节刷新**：按变更分类刷新 spec/design/interfaces 对应章节（接口签名三处一致性校验）
5. **模块级增量**：对每个已存在模块级 md 的目录，读取其 `last_modified`，按同样方式探测变更并刷新；同时检查是否有**新增的 >800 目录**（首次跨越阈值的目录）需生成模块级 md
6. **阈值跨越处理**：若某目录因新增文件从 ≤800 跨越到 >800，触发该目录首次生成模式；若某目录因删除文件从 >800 降到 ≤800，模块级 md 保留但标注"已降级，信息可融合到上级"
7. **跨文件一致性校验**：仓级 design.md 模块清单 ↔ 各模块级 md 存在性；接口签名在 spec/interfaces/design 三处一致
8. **更新时间戳与报告**

### 注意事项

- **产出规则**：仓级必产；递归遍历目录树，对每个源码文件数 > 800 的目录产模块级 spec.md + design.md，多层嵌套无层数限制
- **阈值跨越**：目录因新增文件从 ≤800 跨越到 >800 时触发首次生成；因删除降到 ≤800 时保留文档但标注"已降级"
- PlantUML 图必须准确反映代码中的实际状态转换和调用关系；跨模块流程图必须包含异常分支（失败点、错误表现、处理策略）
- **职责边界**：spec 只写"有什么能力+目标指标"；design 只写"通过什么设计手段达成"；编码约束与经验归 rules.md；测试基础设施归 DTFrame.md。三处不得跨界重复
- spec.md 与 DTFrame.md 的测试框架信息分工：spec.md 不写测试框架细节（统一引用 DTFrame.md）
- 仓级 spec.md 模块清单为索引式（模块路径+一句话职责+模块级文档位置），详细职责归模块级或仓级 design.md
- spec.md 必须包含对外接口契约索引（§3）与跨仓协作关系（§4.2），供 fwd-cross-repo-impact 使用；接口契约详情归 interfaces.md
- design.md 必须包含配置项说明、关键异常流程、数据流向、兜底策略、关键设计决策，供 AI 修改配置/异常处理/理解设计意图时参考
- 仓级一次执行产 3 文件：spec.md + design.md + interfaces.md，共享同一次代码扫描结果，保证三文件信息一致
- 模块级文档路径：`repos/{repo}/.agent/modules/{目录相对路径}/spec.md` 与 `design.md`，支持嵌套（如 `modules/internal/ngap/dispatcher/spec.md`）
- 代码定位用 `文件路径::符号名` 格式，不使用行号
- 低置信章节末尾标注"本节置信度：低"，frontmatter 整体置信度不低于最低分节置信度
- 增量模式下，若仓内有 rebase/squash 导致 `last_modified` 早于实际最近提交，需以锚点提交为准
- 删除文件若对应废弃模块/特性，需从仓级模块清单、目录概览、对外接口契约中同步移除；模块级 md 对应目录删除时同步移除
- 增量刷新不应降低置信度；若变更引入不确定项，置信度维持原值并在报告中标注新增不确定项

### 输出要求

- **仓级文档（必产）**：`repos/{repo}/.agent/` 下产 3 文件
  - `spec.md` 严格按模板：`templates/repo_spec_template.md`
  - `design.md` 严格按模板：`templates/repo_design_template.md`
  - `interfaces.md` 严格按模板：`templates/interfaces_template.md`
- **模块级文档（递归按需）**：对每个源码文件数 > 800 的目录，在 `repos/{repo}/.agent/modules/{目录相对路径}/` 下产
  - `spec.md` 严格按模板：`templates/module_spec_template.md`
  - `design.md` 严格按模板：`templates/module_design_template.md`
  - 嵌套目录同样产出（如 `modules/internal/ngap/dispatcher/spec.md`），无层数限制
  - 模块级不单独产 interfaces.md，对外接口统一归仓级 interfaces.md
- 仓级 design.md 模块清单列出所有产了模块级 md 的目录路径与嵌套层级
- `last_modified` 格式为 ISO 8601 带时区（如 `2026-06-21T14:30:00+08:00`），用于增量模式下 `git log --before="<last_modified>"` 精确定位锚点提交；仅日期精度会导致同日内多次提交无法区分
- 包含 PlantUML 状态图（如有状态机）和序列图（关键流程含异常分支）
- 不再单设"逆向来源"章节；置信度写入 YAML 头部，不确定项与人工复核点写入本次生成/更新的差异摘要（一次性产物，不持久化到 md 正文）
- 三文件接口签名一致性：spec.md §3 索引 ↔ interfaces.md 详情 ↔ design.md §6 模块间接口
- 如为更新已有文档，输出差异摘要
