# Historical Change Evaluation Benchmark v1

本目录用于评估 workflow 对真实历史代码变更的复现能力。样本来自 `repos/` 下各独立 Git 仓库的历史提交。

目录分为两类：

- `bugfix/`：缺陷修复类样本，主要评估定位、边界条件、错误处理和最小修复能力。
- `requirement-change/`：需求调整/功能增强类样本，主要评估配置扩展、协议字段补充、跨模块集成、生命周期改造、API 能力新增和可观测性增强能力。

每个 case 目录包含：

- `metadata.yaml`：case 元数据、commit、涉及文件、行为摘要和评分关注点。
- `prompt.md`：回放时给 workflow 的输入。该文件不包含真实 diff。
- `ground_truth.patch`：真实人工提交 diff，评测时应作为隐藏答案。
- `scoring.md`：该 case 使用的评分规则。

推荐回放流程：

1. 进入 `metadata.yaml` 指定的仓库。
2. checkout 到 `before_commit`。
3. 只把 `prompt.md` 内容提供给 workflow。
4. 保存 workflow 生成的 patch、说明和验证输出。
5. 用 `ground_truth.patch` 与 `scoring.md` 对结果进行人工或半自动评分。
