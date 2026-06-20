---
module_id: {module_id}
repo_id: {repo_id}
template_version: "1.0"
last_modified: {last_modified}
last_modified_by: {skill_name}
confidence: high | medium | low
---

# {module_id} 模块规格（逆向还原）

> 本文档为模块级规格说明。首次由 `rev-repo-to-spec-and-design` skill 逆向生成，后续可由 `fwd-doc-sync` 等正向 skill 增量刷新，由 `qa-artifact-auto-verify` skill 做一致性校验。
>
> **代码定位约定**：所有"代码位置/代码证据"列使用 `文件路径::符号名` 格式（如 `internal/gmm/handler.go::HandleRegistrationRequest`），不使用行号。行号会随上游提交漂移导致误导，仅在生成时的逆向报告中附一次。

## 1. 概述
{一句话描述本模块的功能定位与职责}

## 2. 技术栈（若有特殊补充）
{如果与仓级 spec 一致，写"同仓级 spec"；若有特殊要求，列出}

## 3. 对外接口
| 接口函数 | 方向 | 说明 | 代码位置 |
|----------|------|------|----------|
| {函数签名} | 提供/消费 | {用途} | {文件路径}::{函数名} |

## 4. 依赖
| 依赖项 | 类型 | 说明 | 代码证据 |
|--------|------|------|----------|
| {依赖模块或外部系统} | 内部模块/外部系统 | {用途} | {include/import/调用点} |

## 5. 关联业务/架构概念
- 关联架构元素：{element_id} {元素名}
- 关联业务场景：{SCENARIO_XXX}（如有）
