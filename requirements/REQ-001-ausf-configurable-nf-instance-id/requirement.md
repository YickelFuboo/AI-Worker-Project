---
requirement_id: REQ-001-ausf-configurable-nf-instance-id
title: AUSF 支持配置 nfInstanceId
created: 2026-06-26
status: draft
---

# 需求说明：AUSF 支持配置 nfInstanceId

## 1. 5W2H 需求澄清

| 维度 | 内容 | 确认状态 |
|------|------|----------|
| Who（谁） | 5GC 系统运维人员、Kubernetes 部署维护人员、外部健康检查或监控系统，以及依赖 AUSF 身份稳定性的排障人员。 | 已确认 |
| When（何时） | AUSF 启动并初始化自身 NF 上下文时；尤其是在 Kubernetes Pod 重启、滚动发布、故障恢复或运维检查期间。 | 已确认 |
| Where（何处） | AUSF 的配置文件和 AUSF NF 上下文初始化过程；业务边界位于 AUSF 自身身份生成与对外可观察的 NF Instance ID 表达。 | 已确认 |
| What（做什么） | 支持在配置文件中可选声明 `nfInstanceId`；当声明值是合法 UUID v4 时，AUSF 使用该值作为自身 NF Instance ID；当未声明时，保持原有每次启动自动生成 UUID 的行为。 | 已确认 |
| Why（为什么） | 当前 AUSF 每次启动都会生成新的 NF Instance ID，导致 Kubernetes 部署、外部检查和运维追踪难以稳定识别同一个 AUSF 实例。 | 已确认 |
| How（如何表现） | 运维人员可以通过配置文件为 AUSF 指定稳定的 `nfInstanceId`；AUSF 启动后对外表现为使用该配置值标识自身。未配置时，启动行为与原先一致。 | 已确认 |
| How much（多少） | 配置值必须是合法 UUID v4；该配置项为可选项；未配置场景必须保持向后兼容；配置非法格式或非 UUID v4 时，AUSF 应启动失败并提示配置错误。 | 已确认 |

## 2. 需求背景

- 客户场景：在 Kubernetes 或类似容器化环境中部署 AUSF 时，Pod 重启、滚动发布或故障恢复可能导致 AUSF 重新启动。当前 AUSF 每次启动生成新的 NF Instance ID，使外部检查、监控、日志关联和运维追踪难以判断是否仍为同一个预期实例。
- 业务价值：允许部署方为 AUSF 配置稳定的 NF Instance ID，提升部署可观测性、运维追踪稳定性和自动化检查的一致性，同时避免影响未使用该配置项的现有部署。
- 触发来源（客户投诉/市场调研/合规要求/技术演进）：运维和部署可维护性改进需求。

## 3. 需求目标

- 核心目标（一句话）：AUSF 支持通过配置文件可选指定稳定的 `nfInstanceId`，并在未配置时保持原有自动生成行为。
- 量化指标（如性能、覆盖率、可用性、容量、时延、成功率）：
  - 配置合法 UUID v4 时，AUSF 启动后使用该配置值作为 NF Instance ID。
  - 未配置 `nfInstanceId` 时，AUSF 仍自动生成 UUID，不要求部署方修改现有配置。
  - 配置非法格式或非 UUID v4 的 `nfInstanceId` 时，AUSF 启动失败并提示配置错误。

## 4. 功能范围

### 4.1 范围内

- AUSF 配置文件支持可选配置项 `nfInstanceId`。
- AUSF 在初始化自身 NF 上下文时识别该配置项。
- 当 `nfInstanceId` 是合法 UUID v4 时，AUSF 使用该值作为自身 NF Instance ID。
- 当未配置 `nfInstanceId` 时，AUSF 保持原有每次启动自动生成 UUID 的行为。
- 明确配置项对 Kubernetes 部署、外部检查和运维追踪场景的可观察结果。

### 4.2 范围外

- 不要求修改除 AUSF 以外的其它 NF 的 `nfInstanceId` 配置能力。
- 不要求改变 AUSF 的鉴权业务流程、Nausf 服务能力或与 AMF/UDM 的业务交互语义。
- 不要求在本阶段判断现有代码、配置文件、特性树或具体实现模块的变更落点。
- 不要求定义配置错误提示的具体文案、错误码或实现方式，这些内容由后续阶段确定。

## 5. 用户/业务场景

### 场景 1：运维人员为 AUSF 配置稳定 nfInstanceId 后启动

- **触发角色**：5GC 系统运维人员或 Kubernetes 部署维护人员。
- **触发条件**：部署方希望在重启、滚动发布或外部检查中稳定识别同一个 AUSF 实例，并在 AUSF 配置文件中声明合法 UUID v4 格式的 `nfInstanceId`。
- **业务过程**：
  1. 运维人员在 AUSF 配置文件中填写 `nfInstanceId`。
  2. AUSF 启动并初始化自身 NF 上下文。
  3. AUSF 对外使用配置文件中的 `nfInstanceId` 作为自身 NF Instance ID。
  4. 外部检查、监控或运维追踪基于该稳定 ID 识别 AUSF。
- **业务结果**：AUSF 重启后仍能以配置的稳定 NF Instance ID 被部署和运维体系识别。
- **验收标准（Given-When-Then）**：
  - Given AUSF 配置文件中声明了合法 UUID v4 的 `nfInstanceId`，When AUSF 启动并完成自身上下文初始化，Then AUSF 的 NF Instance ID 等于配置文件中的 `nfInstanceId`。
  - Given AUSF 使用配置的 `nfInstanceId` 启动，When 运维人员或外部检查系统读取 AUSF 对外可观察的 NF Instance ID，Then 观察到的 ID 与配置值一致。

### 场景 2：未配置 nfInstanceId 时 AUSF 保持自动生成行为

- **触发角色**：未启用该配置项的现有部署方。
- **触发条件**：AUSF 配置文件中未声明 `nfInstanceId`。
- **业务过程**：
  1. 部署方沿用现有 AUSF 配置文件，不增加 `nfInstanceId`。
  2. AUSF 启动并初始化自身 NF 上下文。
  3. AUSF 按原有行为自动生成 NF Instance ID。
- **业务结果**：现有部署无需修改配置即可继续启动 AUSF，原有自动生成 UUID 的行为保持不变。
- **验收标准（Given-When-Then）**：
  - Given AUSF 配置文件中未声明 `nfInstanceId`，When AUSF 启动并完成自身上下文初始化，Then AUSF 自动生成 NF Instance ID。
  - Given 现有部署未使用 `nfInstanceId` 配置项，When 升级到支持该配置项的版本后启动 AUSF，Then 不需要额外配置即可保持原有启动行为。

### 场景 3：配置的 nfInstanceId 不是合法 UUID v4

- **触发角色**：配置 AUSF 的运维人员。
- **触发条件**：AUSF 配置文件中声明了 `nfInstanceId`，但该值不是合法 UUID v4。
- **业务过程**：
  1. 运维人员在 AUSF 配置文件中填写非法格式或非 UUID v4 的 `nfInstanceId`。
  2. AUSF 启动时读取该配置项。
  3. AUSF 启动失败并提示 `nfInstanceId` 配置错误。
- **业务结果**：AUSF 启动失败，并向运维人员提示 `nfInstanceId` 配置错误，避免系统使用不符合 UUID v4 要求的 NF Instance ID。
- **验收标准（Given-When-Then）**：
  - Given AUSF 配置文件中声明了非法格式或非 UUID v4 的 `nfInstanceId`，When AUSF 启动并读取配置，Then AUSF 启动失败并提示 `nfInstanceId` 配置错误。

## 6. 业务规则

| 规则ID | 规则描述 | 优先级 |
|--------|----------|--------|
| BR-001 | `nfInstanceId` 是 AUSF 配置文件中的可选配置项。 | 必须 |
| BR-002 | 当 `nfInstanceId` 已配置且为合法 UUID v4 时，AUSF 必须使用该配置值作为自身 NF Instance ID。 | 必须 |
| BR-003 | 当 `nfInstanceId` 未配置时，AUSF 必须保持原有每次启动自动生成 UUID 的行为。 | 必须 |
| BR-004 | `nfInstanceId` 的合法配置值必须满足 UUID v4 格式。 | 必须 |
| BR-005 | 当 `nfInstanceId` 已配置但格式非法或不是 UUID v4 时，AUSF 必须启动失败并提示配置错误。 | 必须 |

## 7. 非功能要求

| 类别 | 要求 |
|------|------|
| 性能 | 该配置能力不应对 AUSF 启动流程引入可感知的额外延迟；具体阈值待确认。 |
| 可靠性 | 未配置 `nfInstanceId` 时必须保持原有自动生成行为，避免影响现有部署启动。 |
| 安全 | `nfInstanceId` 仅作为 NF 实例标识配置，不应改变 AUSF 鉴权业务语义；是否需要对配置来源或日志暴露做额外约束待确认。 |
| 兼容性 | 现有未声明 `nfInstanceId` 的 AUSF 配置文件应继续可用。 |
| 可观测性 | 配置合法 UUID v4 后，外部检查、监控或运维追踪应能观察到稳定的 AUSF NF Instance ID；具体观察入口待后续阶段确认。 |

## 8. 后续分析交接

本需求文档只描述需求本身，不在本阶段判断现有业务能力的变更落点。本文档完成后应先进入 `01-Q-fwd-req-quality-check` 做需求质量门禁检查；门禁通过或告警放行后，再由 `02-fwd-feature-change-gen` 进行特性和场景级变更分析。

## 9. 待确认项

- [ ] `nfInstanceId` 的配置项名称是否必须精确为 `nfInstanceId`，以及它在配置文件中的层级位置是否已有约束？
- [ ] 外部检查或运维追踪读取 AUSF NF Instance ID 的观察入口是什么，例如日志、NRF 注册信息、健康检查输出或其它接口？
- [ ] 对 AUSF 启动性能是否有明确阈值要求？
