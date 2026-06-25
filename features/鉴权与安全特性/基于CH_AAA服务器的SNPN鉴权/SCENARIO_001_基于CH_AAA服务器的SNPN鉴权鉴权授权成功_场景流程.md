---
id: SCENARIO_001
name: 基于CH AAA服务器的SNPN鉴权鉴权授权成功
feature_path:
  - { level: L1, id: cat_authentication_security, name: 鉴权与安全特性 }
  - { level: L2, id: sec_snpn_ch_aaa, name: 基于CH AAA服务器的SNPN鉴权 }
scenario_type: 授权场景
last_modified: "2026-06-25T23:32:24+08:00"
last_modified_by: rev-code-to-scenario
intent_source_count: 0
confidence: low
---

# 场景流程：基于CH AAA服务器的SNPN鉴权鉴权授权成功

## 1. 场景概述

| 项目 | 内容 |
|------|------|
| 场景 ID | SCENARIO_001 |
| 场景名 | 基于CH AAA服务器的SNPN鉴权鉴权授权成功 |
| L1 一级特性 | cat_authentication_security — 鉴权与安全特性 |
| L2 二级特性 | sec_snpn_ch_aaa — 基于CH AAA服务器的SNPN鉴权 |
| 场景类型 | 授权场景 |
| 置信度 | low |
| 意图源覆盖 | 0 |

## 2. 业务意图（意图域）

**业务目的**：UE或业务方成功完成基于CH AAA服务器的SNPN鉴权相关鉴权授权。

**关键假设**：
- 场景属于 `基于CH AAA服务器的SNPN鉴权` 的具体用户业务场景，而不是固定流程模板。
- 参与方来自架构引用、规范角色或相邻系统角色；缺少代码事实时保持低置信度，不编造函数级实现。

**场景优先级 / 演进定位**：以特性状态 `planned` 和后续版本规划为准。

## 3. 参与方（事实域）

| 角色 | 架构元素 | 元素 spec 链接 | 说明 |
|------|---------|--------------|------|
| 外部/相邻参与方 | UE | - | 场景上下文参与方 |
| 外部/相邻参与方 | SEAF | - | 场景上下文参与方 |
| 相关功能 | NEF | architectures/logic_view/elements/nef/spec.md | 参与 `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 的架构交互 |
| 相关功能 | NSSF | architectures/logic_view/elements/nssf/spec.md | 参与 `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 的架构交互 |
| 相关功能 | AUSF | architectures/logic_view/elements/ausf/spec.md | 参与 `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 的架构交互 |
| 相关功能 | UDM | architectures/logic_view/elements/udm/spec.md | 参与 `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 的架构交互 |

## 4. 前置条件（事实域）

1. 当前业务请求命中 `基于CH AAA服务器的SNPN鉴权` 特性范围。
2. 相关配置、订阅、拓扑或对端能力满足 `TS 23.501 §5.30, TS 33.501 §6.1.4` 要求。

## 5. 场景流程（事实域，与架构元素一致）

```plantuml
@startuml
participant "UE" as UE
participant "SEAF" as SEAF
participant "NEF" as NEF
participant "NSSF" as NSSF
participant "AUSF" as AUSF
participant "UDM" as UDM

UE -> SEAF: 触发基于CH AAA服务器的SNPN鉴权鉴权授权成功
SEAF -> NEF: 转发业务请求/上下文
NEF -> NSSF: SBI / 相关规范接口
NSSF --> NEF: 返回处理结果
NEF -> AUSF: SBI / 相关规范接口
AUSF --> NEF: 返回处理结果
NEF -> UDM: SBI / 相关规范接口
UDM --> NEF: 返回处理结果
NEF --> SEAF: 返回业务结果
SEAF --> UE: 返回接入侧结果
@enduml
```

## 6. 步骤明细（事实域）

| 步骤 | 发起方 | 接收方 | 动作 | 使用接口 | 数据/参数 | 异常分支编号 |
|------|--------|--------|------|----------|----------|------------|
| 1 | UE | SEAF | 触发基于CH AAA服务器的SNPN鉴权鉴权授权成功 | 待事实源确认 | 特性相关上下文 | E-1 |
| 2 | SEAF | NEF | 转发业务请求/上下文 | 转发业务请求/上下文 | 特性相关上下文 | E-1 |
| 3 | NEF | NSSF | SBI / 相关规范接口 | SBI / 相关规范接口 | 特性相关上下文 | E-1 |
| 4 | NSSF | NEF | 返回处理结果 | 待事实源确认 | 特性相关上下文 | E-1 |
| 5 | NEF | AUSF | SBI / 相关规范接口 | SBI / 相关规范接口 | 特性相关上下文 | E-1 |
| 6 | AUSF | NEF | 返回处理结果 | 待事实源确认 | 特性相关上下文 | E-1 |
| 7 | NEF | UDM | SBI / 相关规范接口 | SBI / 相关规范接口 | 特性相关上下文 | E-1 |
| 8 | UDM | NEF | 返回处理结果 | 待事实源确认 | 特性相关上下文 | E-1 |
| 9 | NEF | SEAF | 返回业务结果 | 待事实源确认 | 特性相关上下文 | E-1 |
| 10 | SEAF | UE | 返回接入侧结果 | 待事实源确认 | 特性相关上下文 | E-1 |

## 7. 异常处理

### 7.1 异常处理意图（意图域）

| 异常编号 | 业务侧含义 | 用户体验取舍 | 回退策略动机 | 来源 |
|---------|-----------|------------|------------|------|
| E-1 | `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 未能满足前置条件、订阅、策略、拓扑或对端能力要求 | 以规范和现网策略约束为准 | 以后续系统方案和代码事实源为准 | - |

### 7.2 异常分支现状（事实域，与代码一致）

| 异常编号 | 触发条件（代码定位） | 当前处理方式 | 当前影响范围 |
|---------|------------------|------------|------------|
| E-1 | 待事实源确认 | 待事实源确认 | 待事实源确认 |

## 8. 后置条件（事实域）

- `基于CH AAA服务器的SNPN鉴权鉴权授权成功` 结束后，相关上下文、策略、会话、事件或接口结果与 `基于CH AAA服务器的SNPN鉴权` 的业务约束保持一致。

## 9. 关联代码实现（事实域）

- 当前场景暂无可确认代码锚点；后续由事实源增量补充。

## 10. 架构关联

参见所属最子特性目录下 [`spec.md`](spec.md) 与 [`arch_ref.yaml`](arch_ref.yaml)。

## 参考源

本场景采纳的历史方案：

| solution_name | 状态 | 主要采纳章节 | 采纳节 |
|---------------|------|------------|--------|
| - | - | - | - |
