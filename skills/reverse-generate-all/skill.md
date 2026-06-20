# 存量项目反向生成全套 Spec

## 功能描述

对存量代码仓（无 Spec/Design 文档的项目），执行完整的反向工程流程：代码 → 构建图谱 → Spec → 设计文档。将已有代码转化为结构化的规格说明书和设计文档，为后续 AI 辅助开发建立基准。

## 适用场景

- 存量产品首次接入 AI 辅助开发
- 代码与文档严重脱节，需要从代码重建文档体系
- 接手遗留项目，需要理解其架构和功能
- 反向流程的编排入口

## 工作方式

### 执行步骤

#### 第一阶段：建立数字孪生

1. 执行 `build-graph`：构建代码知识图谱
2. 确认图谱构建成功（检查构建报告）

#### 第二阶段：反向生成 Spec

1. 执行 `code-to-spec`：
   - 生成仓级 Spec（功能清单、技术栈、外部依赖）
   - 生成模块级 Spec（对外接口、依赖）
2. 标注所有由代码反推的条目标记 `[INFERRED]`

#### 第三阶段：反向生成设计文档

1. 执行 `code-to-design`：
   - 生成仓级设计（模块划分、核心数据对象、模块间接口）
   - 生成模块级设计（核心类/函数、数据结构、关键交互流程）
2. 标注所有由代码反推的条目标记 `[INFERRED]`

#### 第四阶段：补充项目级文档

1. 生成/更新 `Claude.md`（或 `AGENT.md`）：包含代码定位指南、修改原则、编码规范
2. 生成/更新 `README.md`：项目概述、目录结构、构建运行说明

#### 第五阶段：输出总结

1. 汇总所有生成的文档清单
2. 列出所有待人工确认项
3. 建议下一步：哪些 `[INFERRED]` 项需要优先人工 Review

### 注意事项

- 此流程为一次性操作（项目接入时），后续变更通过 `change-log` 和 `doc-sync` 维护
- 反推的文档质量取决于代码质量（注释、命名、结构清晰度）
- 业务背景、设计决策理由等无法从代码反推的内容标注"待补充"
- 建议完成后由熟悉项目的开发者 Review 所有 `[INFERRED]` 标记项
- 大型项目可分模块逐步执行，避免一次输出过多

### 输出要求

- 仓级 Spec：`requirements/specs/repo_spec.md`
- 模块级 Spec：`requirements/specs/modules/{module_name}_spec.md`
- 仓级 Design：`architectures/repo_design.md`
- 模块级 Design：`architectures/modules/{module_name}/design.md`
- Claude.md / AGENT.md：项目根目录
- 待确认项清单：`requirements/specs/pending_review.md`
