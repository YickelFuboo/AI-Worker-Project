# 单 MR 影响分析

## 功能描述

正向开发流程中，对**当前正在进行的单个 MR / commit** 实时分析其代码 diff，输出该次变更的影响分析报告（影响哪些模块/接口/数据对象/配置项，影响哪些下游仓，建议刷新哪些 .agent/*.md 章节，建议校验哪些一致性规则，建议回归哪些测试用例）。报告作为 `fwd-doc-sync` / `qa-artifact-auto-verify` / `fwd-regression-test-select` 三个下游 skill 的**共享前置输入**，避免三个 skill 各自重复读 diff 判断影响面。

本 skill 是正向链路 skill，分析的是**当前变更**，不是历史沉淀。区别于 `rev-repo-mr-to-rules-candidate`（逆向批量分析历史 MR + 检视意见，产 rules 候选，供 rev-repo-to-rules 源 2 消费）。

## 所属 Agent

编码实现 Agent（MR 提交后、合入前触发）

## 适用场景

- MR 合入前评估变更影响范围（本仓 + 跨仓），作为合入门禁
- 作为 `fwd-doc-sync` 的前置步骤，决定"这个 MR 要刷哪些 .agent/*.md 章节"
- 作为 `qa-artifact-auto-verify` 的前置步骤，决定"这个 MR 要校验哪些一致性规则"
- 作为 `fwd-regression-test-select` 的前置步骤，决定"这个 MR 要回归哪些测试用例"

## 工作方式

### 执行步骤

1. **输入解析**：接收 MR 标识（MR ID / commit SHA / commit 范围），获取 diff 与 commit message、关联需求/issue
2. **重复触发判定**（同一 MR 多次 push）：
   - 检查 `repos/{仓名}/.agent/mr_reports/` 下是否已存在该 MR ID 的报告
   - **存在**→ 进入**增量刷新模式**：以 MR 目标分支最新 HEAD 为新基准，重跑步骤 3-7，**覆盖**原报告文件；在报告头部追加 revision 历史（revision N 时间、新增 commit SHA、影响面差异摘要）。下游消费方始终读取最新一份
   - **不存在**→ 进入**首次生成模式**：正常执行步骤 3-7
3. **变更分类**：解析 diff，按文件类型与路径归入影响域：
   - 业务源码（handler/service/consumer/context 等）→ 模块/接口/数据对象影响
   - 对外接口文件（SBI handler / API 定义 / OpenAPI spec）→ 对外接口契约影响
   - 配置文件（config.go / yaml schema）→ 配置项影响
   - 测试文件（*_test.go / testdata）→ 测试影响
   - 依赖声明（go.mod / package.json）→ 第三方库依赖影响
   - CI/构建（Makefile / Dockerfile / .github/workflows）→ 构建部署影响
4. **本仓影响分析**：
   - 对照 `repos/{仓名}/.agent/spec.md` §3 对外接口契约、§8 模块清单，识别受影响的接口与模块
   - 对照 `design.md` §5 核心数据对象、§6 模块间接口、§8 模块详细设计、§9 关键跨模块流程，识别受影响的数据对象/接口/流程
   - 对照 `interfaces.md` 接口列表，识别受影响的接口契约
   - 对照 `rules.md` 实现模式与经验、已知技术债，识别是否触及既有约束
   - 对照 `DTFrame.md` 已有 Mock 清单、测试防护网分层，识别测试影响
5. **跨仓影响分析**：基于 `spec.md` §4.2 跨仓调用关系，识别本 MR 变更是否影响下游仓的调用方，列出需通知的下游仓清单及对应 spec.md 引用
6. **文档刷新建议**：列出本次 MR 需刷新的 .agent/*.md 章节（精确到章节号），供 fwd-doc-sync 执行
7. **一致性校验建议**：列出本次 MR 触发的一致性规则（如接口签名三处一致、配置项与 spec 同步），供 qa-artifact-auto-verify 执行
8. **测试建议**：列出需新增/回归的测试用例（UT/IT/E2E 层级），供 fwd-ut-generate / fwd-regression-test-select 执行
9. **生成影响分析报告**：按模板输出

### 注意事项

- 本 skill 只产影响分析报告，不直接修改 .agent/*.md 文件；文档刷新由 fwd-doc-sync 执行，一致性校验由 qa-artifact-auto-verify 执行，回归用例选择由 fwd-regression-test-select 执行
- **MR 多次 push 处理**：同一 MR ID 每次新 push 都覆盖刷新原报告文件（保持单文件、最新即权威），头部追加 revision 历史记录"哪次 push、新增 commit、影响面差异"，避免下游消费方读到过期影响面
- 影响分析需区分"直接影响"（diff 涉及的文件）与"间接影响"（调用方/被调用方/数据对象使用者），两者分别列出
- 跨仓影响必须基于 spec.md §4.2 的跨仓调用关系，不得臆测；若 §4.2 缺失，标注"跨仓影响待 rev-repo-to-spec-and-design 补全后复核"
- 对外接口签名变更属高风险变更，必须在报告中高亮并提示接口兼容性
- 报告置信度：diff 直接涉及的为高，间接调用链推断的为中，跨仓影响基于既有 spec 推断的为中低
- 单个 MR 若涉及多仓（monorepo 或跨仓提交），需按仓分别输出影响分析
- 本 skill 不负责提炼编码规则与经验（那是 `rev-repo-mr-to-rules-candidate` 的逆向职责）；本 skill 聚焦"当前变更影响什么"，不产出 rules 候选

### 输出要求

- 输出路径：`repos/{仓名}/.agent/mr_reports/{YYYY-MM-DD}-{MR_ID 或 commit SHA 短码}-impact.md`（一次性报告，不作为活文档维护）
- 严格按模板格式输出：`templates/mr_impact_report_template.md`
- 报告包含：MR 概述 / Revision 历史 / 变更分类 / 本仓影响（模块/接口/数据对象/配置项/测试）/ 跨仓影响 / 文档刷新建议 / 一致性校验建议 / 测试建议 / 置信度
- 文档刷新建议精确到 .agent/*.md 的章节号
- 跨仓影响列出下游仓名与对应 spec.md §4.2 引用位置
