---
element_id: upf
element_name: upf
element_type: service
repo_path: repos/go-upf
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: medium
---

# 架构元素规格：upf

> 本文件是**架构层抽象**，结合代码逆向（事实域）与历史架构设计文档（意图域）综合生成。
> - **事实域**（接口、依赖、协议、当前 DFX 实现、当前部署形态）：以代码 + `repos/go-upf/.agent/*.md` 为准，标注"现状"。
> - **意图域**（战略角色、设计目的、原 DFX 目标、原部署规划）：以 `knowledge/历史方案/架构方案/` 为准，标注"原设计意图"。本次抽取检索 `Pando V1.0版本架构设计说明书.md` 内未发现 upf / UPF / 用户面 / N4 / PFCP / GTP-U / N3 / N6 / N9 / gtp5g 等关键词的有效章节内容，故意图域章节均标注「无历史方案输入」，意图条目计数 `intent_source_count: 0`。
> - 同章节内两类信息并存表达，明示标签。
> - 实现细节（PFCP 消息字段、PDR/FAR/QER/URR/BAR 规则模型、netlink 属性、代码位置）归 `repos/go-upf/.agent/*.md`，本文件不重复抄写，仅在节末以"契约详情见..."指引。
>
> **NF 特殊性说明**：upf 是 3GPP 5G 核心网**用户面网元**，**不提供 SBI HTTP/REST 接口**。对外接口为 PFCP（N4 控制信令，UDP/8805）与 GTP-U（N3/N9 用户面隧道，UDP/2152），与控制面 NF（amf/smf/...）的 SBI 接口形态完全不同。此外，本元素的用户面数据转发**不在用户态实现**，而是下沉到内核 `gtp5g` 模块，本元素仅在用户态承担 PFCP 信令处理与规则翻译下发的职责。

## 1. 元素定位

**现状**（事实域）：
upf 是 3GPP 5G 核心网的用户面接入网元，是 UE 数据流的转发与执行点。它在控制面侧终结 N4 PFCP 接口（被动方，响应 SMF 下发的会话规则），在用户面侧终结 N3（gNB↔UPF）/ N9（UPF↔UPF）/ N6（UPF↔DN）三类数据通道。架构上 upf 是控制面 smf 决策的执行者：smf 通过 N4 下发 PDR/FAR/QER/URR/BAR 规则集，upf 把这些规则翻译为内核 gtp5g 模块可执行的转发动作，并把内核态触发的下行数据通知与用量测量回传给 smf。upf 不持有 UE 注册态/会话决策权（归 amf/smf），不解析用户报文应用层载荷，是用户面隔离边界。

**原设计意图**（意图域）：
无历史方案输入。Pando V1.0版本架构设计说明书未覆盖 upf / 用户面 / N4 / PFCP / GTP-U 相关章节，本节战略意图无法回溯。

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | upf | - |
| 元素名 | upf | - |
| 元素类型 | service（独立部署 NF，对外提供 PFCP/GTP-U 而非 SBI） | - |
| 所属代码仓 | repos/go-upf | - |
| 别名 | go-upf（仓名） | - |
| 战略角色 | 5G 核心网用户面执行点，控制面 smf 决策的下发与上报通道；用户面与控制面边界 | 无历史方案输入 |
| 置信度 | 中 | - |

> 置信度说明：业务能力、接口清单、规则模型、依赖关系、可观测性约定来源于 `.agent/*.md` 高置信度章节归纳，置信度高；性能/容量等量化质量属性仓内无明确声明，从代码结构推断，置信度低；意图域全空，整体置信度评估为中。

## 2. 职责描述

**现状**（事实域）：
upf 承担 5G 核心网的用户面转发与执行职责：终结 N4 PFCP 信令、维护 PFCP 会话与 SMF 关联状态、把会话规则翻译并下发到内核 gtp5g 模块、向 smf 上报下行数据触发（DLDR）与用量测量（USAR）、为下行不可达场景维护 per-PDR 报文缓冲。它不做会话决策（归 smf）、不做接入控制（归 amf）、不在用户态接触用户报文内容（归内核 gtp5g），是控制面与数据面的边界翻译层与上报通道。

**原设计意图**（意图域）：
无历史方案输入。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | PFCP 关联管理 | 维护与 SMF 的 N4 关联状态，是所有会话操作的前置 | 无历史方案输入 |
| CAP-002 | PFCP 心跳保活 | 检测 N4 链路可用性，触发对端节点失活感知 | 无历史方案输入 |
| CAP-003 | PFCP 会话生命周期 | 建立/修改/删除 PFCP 会话，是用户面规则的承载容器 | 无历史方案输入 |
| CAP-004 | 转发规则下发 | 将 PDR/FAR/QER/URR/BAR 翻译为内核 gtp5g 可执行的 netlink 命令 | 无历史方案输入 |
| CAP-005 | 三阶段会话提交 | 校验/执行/应用分离，保证 plan 验证与状态变更原子语义 | 无历史方案输入 |
| CAP-006 | 互斥规则校验 | 拒绝同请求内对同 ID 规则的冲突操作，防止规则集不一致 | 无历史方案输入 |
| CAP-007 | PFCP 事务管理 | 请求重传与响应去重，保障 PFCP 信令在不可靠 UDP 上的可达性 | 无历史方案输入 |
| CAP-008 | 下行数据通知（DLDR） | 内核 gtp5g 检测 UE 不可达时，触发 smf 发起 Paging | 无历史方案输入 |
| CAP-009 | 用量上报（USAR） | URR 触发条件满足时上报流量/时长测量，是计费与策略反馈输入 | 无历史方案输入 |
| CAP-010 | URR 周期触发调度 | 在用户态维护 PERIO 定时器，弥补内核 gtp5g 不维护周期上报 | 无历史方案输入 |
| CAP-011 | 报文缓冲队列 | per-PDR 下行缓冲，配合 BUFF/NOCP 动作支撑 UE 不可达场景 | 无历史方案输入 |
| CAP-012 | GTP-U 链路与路由 | 在系统中创建 gtp5g 网络设备并按 DNN 配置加路由，使内核可承接数据面 | 无历史方案输入 |
| CAP-013 | 内核模块版本约束 | 启动时校验 gtp5g 内核模块版本范围，拒绝不兼容环境 | 无历史方案输入 |
| CAP-014 | PFCP 报文边界校验 | 头部长度与会话 ID 校验，防御畸形输入 | 无历史方案输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | 用户面数据路径全量下沉内核 gtp5g 避免内核↔用户态拷贝；用户态 PFCP 控制面单 goroutine 主循环串行处理避免锁竞争；channel 容量预设（rcvCh=512 / srCh=128 / trToCh=64）应对突发；netlink 通过 ModificationPlan 一次 batch 下发避免逐条 RTT 放大 | 无历史方案输入 |
| 可靠性 | PFCP 请求重传（maxRetrans 可配） + 响应去重缓存（msgBuf）；会话建立阶段 fail-fast 完全回滚（DeleteSess）；会话修改阶段 best-effort 保持尽可能多规则生效；所有顶层 goroutine recover 防 panic；SessionReport 收到 SEID=0 响应时自动清理本地会话 | 无历史方案输入 |
| 可用性 | 优雅关停（SIGTERM/SIGINT → context cancel → 停 PFCP server → 关 driver）；Association 重建按 TS 29.244 删除旧关联与全部会话；UPF 是 PFCP 被动方，启动不阻塞于 SMF 可达 | 无历史方案输入 |
| 可扩展性 | Forwarder 通过 Driver 接口抽象，生产用 gtp5g、UT 用 Empty 替身；目前不支持横向扩缩（单实例 + N9 串联）；PFCP 主循环单 goroutine 是高 SMF 数量场景潜在瓶颈 | 无历史方案输入 |
| 安全性 | 关联 NodeID 校验拒绝未关联 SMF 的会话请求；PFCP IE 强校验（NodeID/F-SEID/RecoveryTimeStamp 缺失即拒绝）；报文长度校验防畸形；SEID 范围边界校验；不持久化 UE IP（仅 Sess 内存）；用户面在内核态隔离；**PFCP N4 当前不启用 TLS/IPSec，依赖网络隔离**（已知技术债） | 无历史方案输入 |
| 可测试性 | Driver 接口允许注入 forwarder.Empty 零值实现，CI 环境无需加载 gtp5g 内核模块；嵌入式 Mock 模式（XxxMock struct { Xxx }）暴露内部字段；CI 走 `go test -v -short ./...`；详见 `repos/go-upf/.agent/DTFrame.md` | 无历史方案输入 |
| 可观测性 | 7 类命名 logger（NF/Main/CFG/PFCP/BUFF/Perio/FWD） + 9 字段结构化（含 NodeID/CPSEID/UPSEID/PFCPTx/PFCPRx 等） + 7 级可配日志；事务必带 trID 字段；无 prometheus 指标端口；无 otel 追踪；健康检查由 PFCP HeartbeatRequest 承担 | 无历史方案输入 |

历史方案未覆盖本节，"原目标值 + 策略原因"列全部标注「无历史方案输入」。

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途。**注意：upf 不提供 SBI HTTP 接口**，所有对外接口为 PFCP（N4）或 GTP-U（N3/N9）协议层接口。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | HeartbeatRequest/Response | PFCP (N4, UDP/8805) | N4 链路保活 |
| IF-002 | AssociationSetupRequest/Response | PFCP (N4) | SMF↔UPF 关联建立，是所有会话操作前置 |
| IF-003 | AssociationUpdateRequest/Response | PFCP (N4) | 关联更新（本元素未实现，仅响应不支持） |
| IF-004 | AssociationReleaseRequest/Response | PFCP (N4) | 关联释放（本元素未实现） |
| IF-005 | SessionEstablishmentRequest/Response | PFCP (N4) | 会话建立，承载 PDR/FAR/QER/URR/BAR 规则下发 |
| IF-006 | SessionModificationRequest/Response | PFCP (N4) | 会话修改，规则增删改查 + 互斥校验 |
| IF-007 | SessionDeletionRequest/Response | PFCP (N4) | 会话删除 + 终态用量上报 |
| IF-008 | SessionReportRequest/Response | PFCP (N4) | UPF 主动上报：下行数据触发（DLDR）+ 用量上报（USAR） |
| IF-009 | GTP-U Data (N3) | GTP-U (UDP/2152) | gNB↔UPF 用户面隧道（内核 gtp5g 实现） |
| IF-010 | GTP-U Data (N9) | GTP-U (UDP/2152) | UPF↔UPF 用户面隧道（内核 gtp5g 实现） |
| IF-011 | N6 IP Output | Raw IP | UPF↔DN 出口（内核路由直出，无 GTP 封装） |

**契约详情**（PFCP MessageType/IE 字段/Cause 错误码/事务序号管理）：见 `repos/go-upf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| smf | PFCP 对端，下发 PDR/FAR/QER/URR/BAR 规则；接收 UPF 上报的 DLDR/USAR；upf 是 PFCP 被动方，是 upf 唯一的 NF 上游 |
| upf（自反） | N9 GTP-U 隧道对端（多 UPF 串联场景，可选） |
| gtp5g 内核模块 | 用户面数据转发引擎（外部 Linux 内核模块，非系统 NF），承担 N3/N9 GTP-U 收发与 N6 路由，启动时强校验版本 [0.9.5, 0.11.0) |
| RAN (gNB) | N3 GTP-U 隧道对端（外部系统，通过内核 gtp5g 交互） |
| DN (Data Network) | N6 路由出口（外部系统，通过内核路由直出） |

**详细依赖清单与调用时机**：见 `repos/go-upf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| PFCP 会话（Sess） | 维护 PDR/FAR/QER/URR/BAR ID 集合与 per-PDR 缓冲队列，是用户面规则在控制面的容器 | 内存，非持久化，重启丢失 |
| 本地节点（LocalNode） | 维护本端 SEID 分配池与会话集合（slice + free 列表复用 SEID） | 内存 |
| 远端节点（RemoteNode） | 维护远端 SMF NodeID 与关联会话集，是关联状态承载 | 内存 |
| Tx/Rx 事务 | 请求重传与响应去重的事务对，保障 PFCP 在 UDP 不可靠通道上的可达性 | 内存，带超时清理 |
| ModificationPlan | 一次会话操作的完整规则操作清单（已校验 + 已翻译为 netlink Attrs），是 PFCP↔forwarder 边界数据 | 内存，单次操作生命周期 |
| URR 引用计数（refPdrNum） | PDR↔URR 关联计数，归零时触发去关联终态上报 | 内存 |
| 缓冲队列 | per-PDR 下行报文 ring buffer（BUFFQ_LEN=512），支撑 BUFF/NOCP 场景 | 内存，溢出丢弃 |
| UPF 配置 | Config.Version="1.0.3"、NodeID、PFCP 监听、GTP-U 接口表（N3/N9）、DNN CIDR 列表 | YAML 配置文件 |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立进程（Go 二进制，二进制名 `upf`），仓内无 Dockerfile，由 free5gc 顶层统一打包；运行于 Linux 主机且**必须加载兼容版本的 gtp5g 内核模块** | 无历史方案输入 |
| 副本策略 | 单实例部署；多 UPF 场景通过 SMF 选择不同 UPF NodeID + N9 串联实现，本元素自身不做集群协调与服务发现 | 无历史方案输入 |
| 启动依赖 | (1) gtp5g 内核模块已加载且版本在 [0.9.5, 0.11.0)；(2) YAML 配置就绪（Config.Version="1.0.3"，Gtpu.Forwarder="gtp5g"，IfInfo.Type∈{N3,N9}，DnnList.Cidr 合法 CIDR，pfcp.nodeID 可 ResolveIPAddr）；(3) SMF 后续主动发起 PFCP AssociationSetup（启动时不主动连接 SMF） | 无历史方案输入 |
| 可观测出口 | logrus 分模块日志（7 级可配，9 个结构化字段） + 启动时 spew.Sdump 完整配置；**本元素未集成 Prometheus 指标端口** ；**未集成 OpenTelemetry 追踪**；健康靠 PFCP Heartbeat | 无历史方案输入 |
| 终止行为 | SIGINT/SIGTERM → context cancel → 停 PFCP server → 关 driver；本元素不向 SMF 主动注销关联（PFCP 协议层无注销动作，由 SMF 通过心跳超时感知） | 无历史方案输入 |
| 容量规格 | 无明确量化目标。已知上限：rcvCh=512 个待处理报文、srCh=128、trToCh=64、per-PDR BUFFQ_LEN=512 包（溢出丢弃）、最大 PFCP 报文 65536 字节；Session 数量受内存限制 | 无历史方案输入 |

历史方案未覆盖本节，"原规划"列全部标注「无历史方案输入」。

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| 无历史方案输入 | - |

`intent_source_count` 为 0，本元素意图域章节均已标注降级。事实域来源详见 `repos/go-upf/.agent/spec.md` / `interfaces.md` / `design.md` / `rules/_index.md` / `rules/约束/可观测性.md` / `rules/约束/性能.md` / `DTFrame.md`。
