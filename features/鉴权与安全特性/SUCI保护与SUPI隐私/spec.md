---
id: sec_suci_protection
name: SUCI保护与SUPI隐私
feature_path:
  - { level: L1, id: cat_authentication_security, name: 鉴权与安全特性 }
  - { level: L2, id: sec_suci_protection, name: SUCI保护与SUPI隐私 }
last_modified: "2026-06-25T13:45:33+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: high
---

# 特性说明：SUCI保护与SUPI隐私

## 1. 特性概述

| 项目 | 内容 |
|------|------|
| 特性 ID | sec_suci_protection |
| 特性名 | SUCI保护与SUPI隐私 |
| 所属 L1 | cat_authentication_security — 鉴权与安全特性 |
| 状态 | implemented |
| 规范参考 | TS 33.501 §6.12 |
| 置信度 | high |
| 意图源覆盖 | 0 |

## 2. 业务定义与目标（意图域）

**业务定义**：用运营商公钥加密 SUPI 防止 IMSI catcher

**业务目标**：围绕 `SUCI保护与SUPI隐私` 提供对应 5GC 业务能力。当前未采纳有效历史系统方案，业务目标以后续意图源增量补充为准。

**范围边界**：

- 包含：`SUCI保护与SUPI隐私` 对应的业务能力、规范约束、触发条件、架构参与方和场景流程。
- 不包含：不属于 `鉴权与安全特性` / `SUCI保护与SUPI隐私` 特性目录的其他业务能力。

## 3. 规范基线与触发条件（事实域）

| 项目 | 内容 |
|------|------|
| 规范基线 | TS 33.501 §6.12 |
| 触发条件 | 参见场景文档和后续代码事实源。 |
| 重试退避 | 以代码事实源和场景文档中的异常分支现状为准。 |
| 关键约束 | 用运营商公钥加密 SUPI 防止 IMSI catcher |

## 4. 架构关联（事实域）

参见同目录 [`arch_ref.yaml`](arch_ref.yaml)。

| 架构元素 | 角色 | 关键接口 / 文档 |
|---------|------|----------------|
| ausf | 相关架构元素 | architectures/logic_view/elements/ausf/spec.md |
| udm | 相关架构元素 | architectures/logic_view/elements/udm/spec.md |

## 5. 实现现状（事实域）

- `repos/udm/internal/sbi/processor/generate_auth_data.go::GenerateAuthDataProcedure`：SUCI 解隐藏与鉴权向量生成

## 6. 场景清单

| 场景 ID | 场景名 | 类型 | 文档 |
|---------|--------|------|------|
| SCENARIO_001 | SUCI解隐藏与鉴权向量下发 | 正常流程 | [SCENARIO_001_SUCI解隐藏与鉴权向量下发_场景流程.md](SCENARIO_001_SUCI解隐藏与鉴权向量下发_场景流程.md) |
| SCENARIO_002 | SUCI解隐藏失败 | 异常流程 | [SCENARIO_002_SUCI解隐藏失败_场景流程.md](SCENARIO_002_SUCI解隐藏失败_场景流程.md) |

## 6. 子场景清单

| 场景 ID | 场景名 | 类型 | 文件 |
|---------|--------|------|------|
| SCENARIO_001 | SUCI保护与SUPI隐私鉴权授权成功 | 授权场景 | [SCENARIO_001_SUCI保护与SUPI隐私鉴权授权成功_场景流程.md](SCENARIO_001_SUCI保护与SUPI隐私鉴权授权成功_场景流程.md) |
| SCENARIO_002 | SUCI保护与SUPI隐私鉴权授权失败 | 失败场景 | [SCENARIO_002_SUCI保护与SUPI隐私鉴权授权失败_场景流程.md](SCENARIO_002_SUCI保护与SUPI隐私鉴权授权失败_场景流程.md) |
| SCENARIO_003 | SUCI保护与SUPI隐私安全上下文更新 | 授权场景 | [SCENARIO_003_SUCI保护与SUPI隐私安全上下文更新_场景流程.md](SCENARIO_003_SUCI保护与SUPI隐私安全上下文更新_场景流程.md) |

## 7. 参考源

本特性采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
