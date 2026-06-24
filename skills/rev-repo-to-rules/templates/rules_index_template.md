---
repo_id: {repo_id}
last_modified: "{YYYY-MM-DDTHH:MM:SS±HH:MM}"
last_modified_by: rev-repo-to-rules
file_count: {int}
confidence: {high|medium|low}
---

# {repo_id} 编码规则索引

> 本目录是本仓的**编码规则与经验**集合,按关注点拆分为单文件,AI 按文件名精准加载。仅包含全局 `knowledge/编码规范/` 公共规范未覆盖或需细化的条目,冲突项不写入(提请人工裁决)。
>
> **目录结构**:
> - `约束/` — 长期不变的编码约束(代码扫描沉淀,MR 检视补充)
> - `模式/` — 修改模式与实现模式(从 MR 归纳 + 代码扫描)
>
> **AI 加载约定**:正向 skill(`fwd-generate-code` / `fwd-code-compliance-check` / `fwd-ut-generate` 等)按任务关键词匹配本索引中文件名,只加载相关文件,不读全文。
>
> **代码定位约定**:所有"代码证据"列使用 `文件路径::符号名` 格式(如 `go.mod::require free5gc/nas`、`internal/sbi/consumer/ausf_service.go::AusfService`),不使用行号。

## 约束/

| 文件 | 标题 | 一句话摘要 | 置信度 |
|------|------|-----------|--------|
| 第三方库.md | 第三方库使用规则 | {依赖版本约束、使用边界、禁用项} | {high/medium/low} |
| 接口使用.md | 接口使用约定 | {必须走封装层、禁止直接调底层} | {置信度} |
| 编码风格.md | 编码风格特有约定 | {error/log/context/concurrency/resource} | {置信度} |
| 性能.md | 性能注意事项 | {性能热点与已知约束} | {置信度} |
| 可观测性.md | 可观测性约定 | {日志/指标/追踪/告警实现约定} | {置信度} |
| 文档同步.md | 文档同步约定 | {变更类型与需同步刷新的文档} | {置信度} |

## 模式/

| 文件 | 标题 | 一句话摘要 | 置信度 |
|------|------|-----------|--------|
| {中文文件名}.md | {模式名} | {一句话摘要} | {置信度} |

> 若本仓暂无沉淀的修改模式,本节写"无"。

## 维护说明

- 本索引由 `rev-repo-to-rules` skill 维护,每次执行刷新 `last_modified`
- 文件增删必须同步刷新本索引,否则 AI 检索会失效
- 各规则文件的 frontmatter `last_modified` 独立维护,本索引 `last_modified` 反映最近一次任意文件的变更
- 增量刷新时仅更新有变更的文件,其他文件保持不变
