---
element_id: amf
element_name: amf
element_type: service
repo_path: repos/amf
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: medium
---

# 架构元素规格：amf

> 本文件是**架构层抽象**，结合代码逆向（事实域）与历史架构设计文档（意图域）综合生成。
> - **事实域**（接口、依赖、协议、当前 DFX 实现、当前部署形态）：以代码 + `repos/amf/.agent/*.md` 为准，标注"现状"。
> - **意图域**（战略角色、设计目的、原 DFX 目标、原部署规划）：以 `knowledge/历史方案/架构方案/` 为准，标注"原设计意图"。
> - 同章节内两类信息并存表达，明示标签。
> - 实现细节（具体功能点、接口契约签名、数据字段、代码位置）归 `repos/amf/.agent/*.md`，本文件不重复抄写，仅在节末以"契约详情见..."指引。
>
> **历史方案输入状态**：`knowledge/历史方案/架构方案/Pando V1.0版本架构设计说明书.md` 当前为空文件，对 amf 元素无内容覆盖。本元素所有意图域条目均标注「无历史方案输入」，整体 confidence 由 high 降级为 medium，但事实域章节（§3、§5、§6、§7）置信度仍为高。

## 1. 元素定位

**现状**（事实域）：
amf 是 3GPP 5G 核心网的控制面接入网元，是 UE 接入网络的唯一控制面入口。它终结 N1（NAS）与 N2（NGAP）接口，承担 UE 注册、鉴权、连接与移动性管理的协议终结点角色；同时通过 SBI 与 NRF/AUSF/UDM/SMF/PCF/NSSF 等控制面 NF 协作，编排跨 NF 的注册与会话流程。在架构上，amf 是 UE 侧所有控制信令的汇聚点，将无线侧协议（NAS/NGAP）与服务侧协议（SBI）解耦。

**原设计意图**（意图域）：
无历史方案输入。`knowledge/历史方案/架构方案/Pando V1.0版本架构设计说明书.md` 当前为空文件，未覆盖 amf 元素的战略定位描述。

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | amf | - |
| 元素名 | amf | - |
| 元素类型 | service（对外提供 Namf SBI，独立部署 NF） | - |
| 所属代码仓 | repos/amf | - |
| 战略角色 | 5GC 控制面接入与移动性管理锚点：UE 侧控制信令唯一入口、N1/N2 协议终结点、跨 NF 流程编排者 | 无历史方案输入 |
| 置信度 | 高 | - |

## 2. 职责描述

**现状**（事实域）：
amf 承担 5G 核心网的接入与移动性控制面职责：维护 UE 注册态与 GMM 状态机，终结 N1/N2 协议并转发至内部处理链，协调鉴权、策略、切片、会话等跨 NF 流程，管理 UE 上下文生命周期。它不承担用户面转发（归 upf）、不承担订阅数据存储（归 udm）、不承担策略决策（归 pcf），是编排者而非决策者。

**原设计意图**（意图域）：
无历史方案输入。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | UE 注册管理 | 维护 UE 与网络的关系生命周期，是接入控制入口 | 无历史方案输入 |
| CAP-002 | NAS 信令处理 | 终结 N1 协议，隔离无线侧与核心网 | 无历史方案输入 |
| CAP-003 | NGAP 信令处理 | 终结 N2 协议，管理 RAN 连接与 NGAP UE 映射 | 无历史方案输入 |
| CAP-004 | 鉴权与安全 | 协同 AUSF 完成主认证，建立 NAS 安全上下文 | 无历史方案输入 |
| CAP-005 | PDU 会话管理协调 | 编排 SMF 会话生命周期，不持有会话状态 | 无历史方案输入 |
| CAP-006 | 移动性管理 | 维护 UE 在小区/RAN/AMF 间的位置与切换状态 | 无历史方案输入 |
| CAP-007 | UE 上下文管理 | 维护注册态 UE 的控制面状态机 | 无历史方案输入 |
| CAP-008 | AMF 事件暴露 | 向订阅方推送 UE 状态变更，解耦事件消费 | 无历史方案输入 |
| CAP-009 | N1N2 消息转发 | 为外部 NF 提供 UE/RAN 信令投递通道 | 无历史方案输入 |
| CAP-010 | MBS 支持 | 多播广播会话的控制面协调 | 无历史方案输入 |
| CAP-011 | 位置信息提供 | 为 LCS 系统提供 UE 位置查询入口 | 无历史方案输入 |
| CAP-012 | OAM 查询 | 为运维提供运行态 UE 上下文可见性 | 无历史方案输入 |
| CAP-013 | NRF 注册与发现 | 声明本 NF 可达性，发现协作 NF | 无历史方案输入 |
| CAP-014 | 策略控制协同 | 与 PCF 建立 AM 策略关联，执行接入与移动性策略 | 无历史方案输入 |
| CAP-015 | 订阅数据获取 | 从 UDM 拉取订阅数据驱动决策 | 无历史方案输入 |
| CAP-016 | 网络切片选择 | 协同 NSSF 将 UE 路由到正确切片 | 无历史方案输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | NGAP 消息并发处理（worker pool 可配）；同一 UE 的消息通过 UE 池串行化避免上下文竞态；SBI 与 NGAP 处理链互不阻塞；UE/RAN 池基于 sync.Map 降低锁竞争 | 无历史方案输入 |
| 可靠性 | 计划性终止须向 RAN 发送 AMF Status Indication、通知所有订阅方、向 NRF 注销 NF 实例；子 goroutine 由 context.Context + WaitGroup 统一管理可追踪可等待；SCTP 连接错误/通知独立处理 | 无历史方案输入 |
| 可用性 | NRF 不可达不阻断本元素启动（注册失败仅 Warn，进程继续运行进入降级态，后续可重试）；启动序列对下游 NF（AUSF/UDM/SMF/PCF/NSSF）无硬阻塞依赖 | 无历史方案输入 |
| 可扩展性 | NGAP worker 规模通过 NgapWorkerPoolSize/NgapTaskBufferSize 配置可水平扩展；SBI 服务名按 Configuration.ServiceNameList 可选启用；多副本部署需配合 NRF NFInstance 与 AMF Set 协调 | 无历史方案输入 |
| 安全性 | 对外 SBI 强制 mTLS（双向 TLS）；callback 路由组独立 OAuth2 鉴权（与业务路由授权策略隔离）；NAS 安全上下文强制建立（NEA0~3 / NIA0~3 算法可配）；IMEISV 掩码保护 UE 身份；UE 上下文并发用 RWMutex 保护 | 无历史方案输入 |
| 可测试性 | UT 隔离所有外部 NF 依赖（SCTP 用手写 SctpConnStub、AMF App 用 gomock、SBI 调用用 Consumer 接口注入）；不依赖真实网络与磁盘；UT 执行 `go test ./...` 全量在本地完成；E2E 归 free5gc 主仓统一编排 | 无历史方案输入 |
| 可观测性 | 分模块 logger（NgapLog/GmmLog/CallbackLog/ConsumerLog/ProducerLog 等，7 级可配，运行时可切换）；Prometheus 指标在独立端口暴露（业务指标含 UE CM/Handover/PDU/GMM States/UE Connectivity，统一由 internal/metrics/business/ 子包注册）；NGAP handler 用 defer+metricStatusOk 模式记录成功/失败；SBI 出站通过 openapi 客户端注入 OpenTelemetry span | 无历史方案输入 |

历史方案未覆盖的行在"原目标值 + 策略原因"列已统一标注「无历史方案输入」。

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | UEContextTransfer | SBI (Namf_Communication) | 跨 AMF 切换时 UE 上下文转移 |
| IF-002 | CreateUEContext | SBI (Namf_Communication) | 目标 AMF 创建 UE 上下文 |
| IF-003 | ReleaseUEContext | SBI (Namf_Communication) | 释放 UE 上下文 |
| IF-004 | RegistrationStatusUpdate | SBI (Namf_Communication) | 向旧 AMF 同步注册状态 |
| IF-005 | N1N2MessageTransfer | SBI (Namf_Communication) | 外部 NF 投递 N1/N2 消息入口 |
| IF-006 | AMFStatusChangeSubscribe | SBI (Namf_Communication) | 订阅 AMF 状态变更 |
| IF-007 | AMFStatusChangeSubscribeModify | SBI (Namf_Communication) | 修改 AMF 状态变更订阅 |
| IF-008 | AMFStatusChangeUnSubscribe | SBI (Namf_Communication) | 取消 AMF 状态变更订阅 |
| IF-009 | EBIAssignment | SBI (Namf_Communication) | EPS Bearer ID 分配 |
| IF-010 | EventExposureCreateSubscription | SBI (Namf_EventExposure) | 订阅 UE 事件（注册/可达性/位置等） |
| IF-011 | MT-EnableUeReachability | SBI (Namf_MT) | 使能 UE 可达性（触发寻呼） |
| IF-012 | Location-ProvideLocationInfo | SBI (Namf_Location) | 向 LCS 提供 UE 位置信息 |
| IF-013 | MBSBroadcast-Context | SBI (Namf_MBSBroadcast) | 多播广播会话上下文管理 |
| IF-014 | MBSCommunication-N2MessageTransfer | SBI (Namf_MBSCommunication) | MBS N2 消息转移 |
| IF-015 | OAM-RegisteredUEContext | SBI (Namf_OAM) | 运维查询已注册 UE 上下文 |
| IF-016 | AmPolicyControlUpdateNotify | HTTP-Callback | PCF 推送 AM 策略更新 |
| IF-017 | SmContextStatusNotify | HTTP-Callback | SMF 通知 SM 上下文状态 |
| IF-018 | N1MessageNotify | HTTP-Callback | SMF 通知 N1 消息 |
| IF-019 | DeregistrationNotification | HTTP-Callback | UDM 通知去注册 |
| IF-020 | N2-NGAP | NGAP over SCTP | RAN 与 AMF 控制面信令承载（非 SBI） |
| IF-021 | N1-NAS | NAS over N1 | UE 与 AMF 控制面信令承载（经 RAN 透传，非 SBI） |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/amf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与发现，是所有跨 NF 调用的前置 |
| ausf | UE 主认证（5G-AKA / EAP-AKA'），注册流程前置 |
| udm | 订阅数据获取与变更订阅、UECM 注册，驱动授权与会话决策 |
| smf | PDU 会话生命周期编排（建立/修改/释放） |
| pcf | AM 策略关联建立/更新/删除，接入与移动性策略执行 |
| nssf | 网络切片选择，UE 路由到正确切片 |
| amf（目标 AMF） | 跨 AMF 切换时 UE 上下文转移（自反依赖） |
| RAN (gNB) | N2 NGAP 信令承载（外部接入设备，非本系统 NF 元素） |
| UE | N1 NAS 信令承载（经 RAN 透传，外部接入设备） |
| Prometheus | 指标 scrape（外部监控基础设施） |
| OpenTelemetry collector | 分布式追踪上报（外部观测基础设施，间接依赖） |

**详细依赖清单与调用时机**：见 `repos/amf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| UE 上下文（AmfUe） | 维护单 UE 的注册态、GMM 状态机、安全上下文、订阅数据、位置、PDU 会话关联，是控制面核心状态 | 内存，非持久化，重启丢失 |
| RAN 连接上下文（AmfRan） | 维护单 gNB 的 SCTP 连接与 NGAP 关联 | 内存 |
| RAN 侧 UE 上下文（RanUe） | 维护 NGAP UE ID 与 AmfUe 的映射 | 内存 |
| PDU 会话上下文（SmContext，AMF 侧） | 维护会话与 UE 的关联，不持有会话状态细节 | 内存 |
| NAS 定时器（T3502/T3512/T3513/T3522/T3550/T3555/T3560/T3565/T3570） | 驱动 GMM 状态机超时迁移与流程重试 | 内存 |
| AMF 全局上下文（AMFContext） | 维护 NF 实例信息、服务区配置（ServedGuamiList/SupportTaiList/PlmnSupportList）、UE/RAN 池索引、安全算法配置 | 内存 + YAML 配置（启动加载） |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立 Go 二进制进程，可容器化（仓内无 Dockerfile，由 free5gc 顶层统一构建镜像） | 无历史方案输入 |
| 副本策略 | 单副本部署；多副本需配合 NRF NFInstance 负载均衡与 AMF Set 协调（仓内未自带集群协调） | 无历史方案输入 |
| 启动依赖 | NRF 可达（不可达降级运行）、mTLS 证书就绪（cert/key 文件路径可配）、YAML 配置文件就绪、SCTP 内核模块可用、NGAP 监听端口可绑定 | 无历史方案输入 |
| 可观测出口 | Prometheus 指标在独立 metrics server 端口暴露（端口与 SBI 不可相同）；logrus 分模块日志（7 级可配，可运行时切换）；OpenTelemetry span 经 openapi 客户端注入 | 无历史方案输入 |
| 终止行为 | 计划性终止流程：发送 AMF Status Indication 通知所有 RAN 不可用 GUAMI → 关闭 NGAP scheduler 与 sctp server → 通知所有 AMF Status Change 订阅方 → 向 NRF 注销 NF 实例 → 等待子 goroutine 退出；NRF 注销失败仅记录错误日志不阻塞 | 无历史方案输入 |
| 容量规格 | 无明确量化目标；UE 池基于 sync.Map 理论上受内存限制；NGAP worker pool / 任务缓冲通过配置应对突发 | 无历史方案输入 |

历史方案未覆盖的维度在"原规划"列已统一标注「无历史方案输入」。

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| 无历史方案输入 | - |

`intent_source_count` = 0。`knowledge/历史方案/架构方案/Pando V1.0版本架构设计说明书.md` 当前为空文件，对 amf 元素无任何内容覆盖；全文意图域章节（§1 战略角色、§2 职责描述意图、§3 业务能力原设计目的、§4 质量属性原目标值、§8 部署原规划）均已统一标注「无历史方案输入」并触发 confidence 降级（high → medium）。事实域章节（§3 能力名/架构用途、§5 接口、§6 依赖、§7 数据概念）保持高置信度。
