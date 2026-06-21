---
element_id: amf
element_name: amf
element_type: service
repo_path: repos/amf
last_modified: "2026-06-21T11:30:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：amf

> 本文件是**架构层抽象**，描述 amf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/amf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
amf 是 3GPP 5G 核心网的控制面接入网元，是 UE 接入网络的唯一控制面入口。它终结 N1（NAS）与 N2（NGAP）接口，承担 UE 注册、鉴权、连接与移动性管理的协议终结点角色；同时通过 SBI 与 NRF/AUSF/UDM/SMF/PCF/NSSF 等控制面 NF 协作，编排跨 NF 的注册与会话流程。在架构上，amf 是 UE 侧所有控制信令的汇聚点，将无线侧协议（NAS/NGAP）与服务侧协议（SBI）解耦。

| 项目 | 内容 |
|------|------|
| 元素ID | amf |
| 元素名 | amf |
| 元素类型 | service（对外提供 Namf SBI，独立部署 NF） |
| 所属代码仓 | repos/amf |
| 置信度 | 高 |

## 2. 职责描述
amf 承担 5G 核心网的接入与移动性控制面职责：维护 UE 注册态与 GMM 状态机，终结 N1/N2 协议并转发至内部处理链，协调鉴权、策略、切片、会话等跨 NF 流程，管理 UE 上下文生命周期。它不承担用户面转发（归 upf）、不承担订阅数据存储（归 udm）、不承担策略决策（归 pcf），是编排者而非决策者。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | UE 注册管理 | 维护 UE 与网络的关系生命周期，是接入控制入口 |
| CAP-002 | NAS 信令处理 | 终结 N1 协议，隔离无线侧与核心网 |
| CAP-003 | NGAP 信令处理 | 终结 N2 协议，管理 RAN 连接与 NGAP UE 映射 |
| CAP-004 | 鉴权与安全 | 协同 AUSF 完成主认证，建立 NAS 安全上下文 |
| CAP-005 | PDU 会话管理协调 | 编排 SMF 会话生命周期，不持有会话状态 |
| CAP-006 | 移动性管理 | 维护 UE 在小区/RAN/AMF 间的位置与切换状态 |
| CAP-007 | UE 上下文管理 | 维护注册态 UE 的控制面状态机 |
| CAP-008 | AMF 事件暴露 | 向订阅方推送 UE 状态变更，解耦事件消费 |
| CAP-009 | N1N2 消息转发 | 为外部 NF 提供 UE/RAN 信令投递通道 |
| CAP-010 | MBS 支持 | 多播广播会话的控制面协调 |
| CAP-011 | 位置信息提供 | 为 LCS 系统提供 UE 位置查询入口 |
| CAP-012 | OAM 查询 | 为运维提供运行态 UE 上下文可见性 |
| CAP-013 | NRF 注册与发现 | 声明本 NF 可达性，发现协作 NF |
| CAP-014 | 策略控制协同 | 与 PCF 建立 AM 策略关联，执行接入与移动性策略 |
| CAP-015 | 订阅数据获取 | 从 UDM 拉取订阅数据驱动决策 |
| CAP-016 | 网络切片选择 | 协同 NSSF 将 UE 路由到正确切片 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | NGAP 消息并发处理；同一 UE 的消息串行化避免上下文竞态；SBI 与 NGAP 互不阻塞 |
| 可靠性 | 计划性终止须通知 RAN 与所有订阅方并注销 NRF；子任务生命周期可追踪可等待 |
| 可用性 | NRF 不可达不阻断本元素启动（降级运行，后续重试） |
| 可扩展性 | NGAP worker 规模可水平扩展；SBI 处理链独立可扩 |
| 安全性 | 对外 SBI 强制 mTLS；回调路由组独立鉴权；NAS 安全上下文强制建立 |
| 可测试性 | UT 隔离所有外部 NF 依赖；不依赖真实网络与磁盘 |
| 可观测性 | 分模块日志 + 独立指标端口 + 分布式追踪 span 注入 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | UEContextTransfer | SBI (Namf_Communication) | 跨 AMF 切换时 UE 上下文转移 |
| IF-002 | CreateUEContext | SBI (Namf_Communication) | 目标 AMF 创建 UE 上下文 |
| IF-003 | ReleaseUEContext | SBI (Namf_Communication) | 释放 UE 上下文 |
| IF-004 | RegistrationStatusUpdate | SBI (Namf_Communication) | 向旧 AMF 同步注册状态 |
| IF-005 | N1N2MessageTransfer | SBI (Namf_Communication) | 外部 NF 投递 N1/N2 消息入口 |
| IF-006 | AMFStatusChangeSubscribe | SBI (Namf_Communication) | 订阅 AMF 状态变更 |
| IF-007 | AMFStatusChangeSubscribeModify | SBI (Namf_Communication) | 修改状态变更订阅 |
| IF-008 | AMFStatusChangeUnSubscribe | SBI (Namf_Communication) | 取消状态变更订阅 |
| IF-009 | EBIAssignment | SBI (Namf_Communication) | EPS Bearer ID 分配 |
| IF-010 | AmPolicyControlUpdateNotify | HTTP-Callback | PCF 推送 AM 策略更新 |
| IF-011 | N1MessageNotify | HTTP-Callback | SMF 通知 N1 消息 |
| IF-012 | SmContextStatusNotify | HTTP-Callback | SMF 通知 SM 上下文状态 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/amf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与发现，是所有跨 NF 调用的前置 |
| ausf | UE 主认证，注册流程前置 |
| udm | 订阅数据获取与变更订阅，驱动授权决策 |
| smf | PDU 会话生命周期编排 |
| pcf | AM 策略关联，接入与移动性策略执行 |
| nssf | 网络切片选择，UE 路由到正确切片 |
| amf（目标） | 跨 AMF 切换时 UE 上下文转移（自反依赖） |
| RAN (gNB) | N2 NGAP 信令承载（外部系统） |
| UE | N1 NAS 信令承载（经 RAN 透传，外部系统） |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/amf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| UE 上下文 | 维护 UE 注册/会话/移动性状态，是控制面核心状态 | 内存，非持久化，重启丢失 |
| RAN 连接上下文 | 维护 N2 连接与 NGAP UE ID 映射 | 内存 |
| PDU 会话上下文（AMF 侧） | 维护会话与 UE 的关联，不持有会话状态细节 | 内存 |
| NAS 定时器 | 驱动 GMM 状态机超时迁移 | 内存 |
| AMF 全局上下文 | 维护 NF 实例信息、服务区配置、UE/RAN 池索引 | 内存 + YAML 配置 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化
- **副本策略**：单副本部署；多副本需配合 NRF NFInstance 负载均衡与 AMF Set 协调
- **启动依赖**：NRF 可达（不可达降级运行）、mTLS 证书就绪、YAML 配置文件就绪
- **可观测出口**：Prometheus 指标（独立端口）+ logrus 分模块日志（7 级可配）+ OpenTelemetry 分布式追踪（间接依赖）
- **终止行为**：计划性终止时发送 AMF Status Indication 通知所有 RAN、通知订阅方、向 NRF 注销 NF 实例，等待子 goroutine 退出
