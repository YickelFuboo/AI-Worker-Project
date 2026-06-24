---
element_id: nef
element_name: nef
element_type: service
repo_path: repos/nef
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: high
---

# 架构元素规格：nef

> 本文件是**架构层抽象**，结合代码逆向（事实域）与历史架构设计文档（意图域）综合生成。
> - **事实域**（接口、依赖、协议、当前 DFX 实现、当前部署形态）：以代码 + `repos/nef/.agent/*.md` 为准，标注"现状"。
> - **意图域**（战略角色、设计目的、原 DFX 目标、原部署规划）：以 `knowledge/历史方案/架构方案/` 为准，标注"原设计意图"；本次抽取历史方案输入为空，意图域章节均降级为"无历史方案输入"，confidence 主要由事实源支撑。
> - 实现细节（具体功能点、接口契约签名、数据字段、代码位置）归 `repos/nef/.agent/*.md`，本文件不重复抄写，仅在节末以"契约详情见..."指引。

## 1. 元素定位

**现状**（事实域）：
nef 是 3GPP 5G 核心网的**网络能力开放**控制面网元（Network Exposure Function），承担"AF 友好的能力开放代理"角色。它把 PCF/UDR 等内部 SBI 服务收敛成面向 AF/SCS-AS 的 RESTful API（TS 29.522 流量影响、TS 29.122 PFD 管理），并把 SMF 的事件通知扇出到 AF。nef 不参与 UE 信令面（无 N1/N2 路径），不持久化业务数据，在架构上是"无状态代理 + 内存订阅索引"的轻量边界元素，是 5GC 内部能力对外暴露的唯一控制面出口。

**原设计意图**（意图域）：
无历史方案输入。

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | nef | - |
| 元素名 | nef | - |
| 元素类型 | service | - |
| 所属代码仓 | repos/nef | - |
| 战略角色 | 5GC 对外能力开放控制面出口，AF/SCS-AS 与 5GC 内部 NF 的协议转换边界 | 无历史方案输入 |
| 置信度 | 高 | - |

## 2. 职责描述

**现状**（事实域）：
nef 承担 5G 核心网的能力开放控制面职责：终结来自 AF/SCS-AS 的 RESTful 请求并转换为下游 SBI 调用，落地流量影响订阅至 PCF（单 UE）或 UDR（组/AnyUE），代理 PFD 管理至 UDR，并向 SMF 暴露 PFD 查询、变更订阅与事件通知回流转发。它不持有业务长期状态（无持久化），不做策略决策（归 PCF），不做数据存储（归 UDR），是协议转换者与通知扇出者，是 5GC 与第三方应用之间的能力边界。

**原设计意图**（意图域）：
无历史方案输入。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | AF 流量影响订阅管理 | 提供 AF 侧 CRUD 入口，将外部应用的流量重定向意图落地到 5GC 策略面 | 无历史方案输入 |
| CAP-002 | 单 UE / 组 UE 双落地路由 | 单 UE 订阅落 PCF 应用会话，组/AnyUE 订阅落 UDR 影响数据，是能力分流的架构决策点 | 无历史方案输入 |
| CAP-003 | PFD 管理（AF 侧） | 为 SCS/AS 提供 PFD 事务 CRUD，是应用流量识别规则的外部下发入口 | 无历史方案输入 |
| CAP-004 | PFDF 应用 PFD 查询 | 向 SMF 暴露按 appID 的 PFD 查询，是 UPF 规则更新前的数据获取通道 | 无历史方案输入 |
| CAP-005 | PFD 变更订阅与异步扇出 | 维护 PFD 订阅清单，PFD 变更后异步通知 SMF 等订阅方，解耦写路径与通知路径 | 无历史方案输入 |
| CAP-006 | SMF 事件通知转发 | 接收 SMF 推送的事件通知，按订阅路由转发至 AF NotificationDestination，是事件回流的反向通道 | 无历史方案输入 |
| CAP-007 | NRF 注册与发现 | 声明本 NF 可达性，按需发现 PCF/UDR，是所有跨 NF 调用的前置 | 无历史方案输入 |
| CAP-008 | OAuth2 双向鉴权 | 入站按 service 名校验 Bearer Token，出站向 NRF 取 token，是能力开放的安全边界 | 无历史方案输入 |
| CAP-009 | AF 上下文管理 | 按 afID 维护订阅/事务索引与 ID 生成器，是订阅生命周期的内存载体 | 无历史方案输入 |
| CAP-010 | OAM 索引 | 提供运维占位接口，预留运行态可见性扩展点 | 无历史方案输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | AF 请求与 PFD 通知互不阻塞；通知扇出异步执行；同 AF 内订阅串行避免索引竞态，跨 AF 并行；下游客户端按 URI 缓存复用降低握手成本 | 无历史方案输入 |
| 可靠性 | 启动期 NRF 注册失败定时重试（2s 间隔）不阻断本元素就绪；终止时主动注销 NF 并 HTTP graceful shutdown（2s 超时）；异步通知 panic 守恒不影响主流程；UDR PFD 读 panic 守卫转 error | 无历史方案输入 |
| 可用性 | NRF 不可达不阻断启动（降级运行，持续重试至成功）；下游 NF 调用前按需发现，缓存复用；callback 转发失败不影响对 SMF 的 204 响应 | 无历史方案输入 |
| 可扩展性 | 入站 SBI / AF API 处理与出站 NRF/PCF/UDR 调用解耦；通知器独立 goroutine 扇出可水平扩展；nnef-pfdmanagement 与 3gpp-pfd-management 共享业务编排但走独立 OAuth scope | 无历史方案输入 |
| 安全性 | SBI 可配 https + mTLS；入站强制 OAuth2（按 service 名校验 Bearer Token，未启用时直通用于 dev/test）；callback 路由组独立鉴权 scope；出站调用前向 NRF 取 token；NfInstanceId 三级解析（env > config > 自动 uuid）保证唯一标识 | 无历史方案输入 |
| 可测试性 | UT 隔离所有外部 NF 依赖（NRF/PCF/UDR/AF/SMF），通过 gock 在 HTTP 客户端 transport 层拦截；不依赖真实网络与磁盘；CI 跑全量 `go test -v ./...`（无 `-cover` 阈值阻断） | 无历史方案输入 |
| 可观测性 | 14 类分类日志（Main/Init/CFG/CTX/CMI/GIN/SBI/Consumer/Processor/Util/TraffInflu/PFDManage/PFDF/OAM），固定字段顺序（NF/Category/AFID/SubID/PfdTRID）+ Prometheus 指标独立端口（默认 9091，与 SBI 端口校验冲突）+ OpenTelemetry 分布式追踪（间接依赖）；运行时日志开关支持热改 | 无历史方案输入 |

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | TrafficInfluenceSubscription | AF REST (3gpp-traffic-influence, TS 29.522) | AF 流量影响订阅的 CRUD 入口 |
| IF-002 | PFDManagementTransactions | AF REST (3gpp-pfd-management, TS 29.122) | SCS/AS PFD 事务的 CRUD 入口 |
| IF-003 | PFDManagementApplications | AF REST (3gpp-pfd-management) | SCS/AS PFD 应用粒度的 CRUD 入口 |
| IF-004 | PFDFApplicationsQuery | SBI (Nnef_PFDmanagement) | SMF 按 appID 查询 PFD 数据 |
| IF-005 | PFDFSubscriptions | SBI (Nnef_PFDmanagement) | SMF 订阅 PFD 变更通知 |
| IF-006 | SmfNotificationCallback | SBI (Nnef_EventExposure callback) | SMF 推送事件通知入口（按 NotifId 路由并转发至 AF） |
| IF-007 | OamIndex | OAM REST (nnef-oam) | OAM 索引占位 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/nef/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与发现，是所有跨 NF 调用的前置（含出站 OAuth2 token 获取） |
| pcf | 单 UE 流量影响落地到应用会话（PolicyAuthorization） |
| udr | 组/AnyUE 流量影响数据 + PFD 数据存储（DataRepository） |
| smf | 接收 SMF 事件通知回流并转发 AF；为 SMF 提供 PFD 查询与订阅；PFD 变更异步扇出至 SMF |
| AF / SCS-AS | 能力开放消费者（外部第三方应用），同时是事件回流的最终接收方 |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/nef/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| AF 上下文（AfData） | 按 afID 索引该 AF 下的订阅与事务，是订阅生命周期的内存载体 | 内存，非持久化，重启丢失 |
| 流量影响订阅（AfSubscription） | 维护 AF 提交的流量影响意图与下游落地引用（PCF appSessionId 或 UDR influenceId） | 内存 |
| PFD 事务（AfPfdTransaction） | 维护 SCS/AS 提交的 PFD 事务与 UDR 存储引用 | 内存（UDR 侧为真实持久化） |
| PFD 变更订阅 | 维护订阅 PFD 变更的 NotifyUri 双向索引，驱动异步扇出 | 内存 |
| Consumer 客户端缓存 | 按 URI 缓存 NRF/PCF/UDR 客户端，复用降低握手成本 | 内存 |
| NF 实例信息 | NfInstanceId + 服务清单 + OAuth2 要求，注册到 NRF | 内存 + YAML 配置 |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立进程（Go 二进制），可容器化（alpine 多阶段镜像，暴露 8000，user free5gc） | 无历史方案输入 |
| 副本策略 | 单副本部署；多副本需配合 NRF NFInstance 负载均衡（订阅状态内存态，不支持跨副本共享） | 无历史方案输入 |
| 启动依赖 | NRF 可达（不可达降级重试运行）；mTLS 证书就绪（若启用 https）；YAML 配置就绪且版本须匹配 NefExpectedConfigVersion；PCF/UDR 按需懒发现 | 无历史方案输入 |
| 可观测出口 | Prometheus 指标（独立端口，默认 9091，与 SBI 端口校验冲突）+ logrus 14 类分类日志（7 级可配，运行时可热改）+ OpenTelemetry 分布式追踪（间接依赖） | 无历史方案输入 |
| 终止行为 | 计划性终止时向 NRF 注销 NF 实例；HTTP server graceful shutdown（2 秒超时）；listenShutdownEvent + main + startServer 三处 defer recover 守护进程不崩溃式退出 | 无历史方案输入 |
| 容量规格 | 无量化容量声明；AF/Sub/PfdTrans map 受进程内存限制；ID 自增 uint64（NumSubscID/NumTransID/NumCorreID） | 无历史方案输入 |

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| 无历史方案输入 | 全文意图域章节均标注"无历史方案输入"，confidence 由事实源（`repos/nef/.agent/*.md`）支撑 |
