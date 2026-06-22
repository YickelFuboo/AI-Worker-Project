---
element_id: upf
element_name: upf
element_type: service
repo_path: repos/go-upf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
aliases: ["go-upf"]
confidence: medium
---

# 架构元素规格：upf

> 本文件是**架构层抽象**，描述 upf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（PFCP 消息字段、PDR/FAR/QER/URR/BAR 规则模型、netlink 属性、代码位置）归 `repos/go-upf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。
>
> **NF 特殊性说明**：upf 是 3GPP 5G 核心网**用户面网元**，**不提供 SBI HTTP/REST 接口**。对外接口为 PFCP（N4 控制信令，UDP/8805）与 GTP-U（N3/N9 用户面隧道，UDP/2152），与控制面 NF（amf/smf/...）的 SBI 接口形态完全不同。此外，本元素的用户面数据转发**不在用户态实现**，而是下沉到内核 `gtp5g` 模块，本元素仅在用户态承担 PFCP 信令处理与规则翻译下发的职责。

## 1. 元素定位

upf 是 3GPP 5G 核心网的用户面接入网元，是 UE 数据流的转发与执行点。它在控制面侧终结 N4 PFCP 接口（被动方，响应 SMF 下发的会话规则），在用户面侧终结 N3（gNB↔UPF）/ N9（UPF↔UPF）/ N6（UPF↔DN）三类数据通道。架构上 upf 是控制面 smf 决策的执行者：smf 通过 N4 下发 PDR/FAR/QER/URR/BAR 规则集，upf 把这些规则翻译为内核 gtp5g 模块可执行的转发动作，并把内核态触发的下行数据通知与用量测量回传给 smf。upf 不持有 UE 注册态/会话决策权（归 amf/smf），不解析用户报文应用层载荷，是用户面隔离边界。

| 项目 | 内容 |
|------|------|
| 元素ID | upf |
| 元素名 | upf |
| 元素类型 | service（独立部署 NF，对外提供 PFCP/GTP-U 而非 SBI） |
| 所属代码仓 | repos/go-upf |
| 别名 | go-upf（仓名） |
| 置信度 | 中 |

> 置信度说明：业务能力、接口清单、规则模型来源于 `.agent/*.md` 高置信度章节归纳，置信度高；性能/容量等量化质量属性仓内无明确声明，从代码结构推断，置信度低。

## 2. 职责描述

upf 承担 5G 核心网的用户面转发与执行职责：终结 N4 PFCP 信令、维护 PFCP 会话与 SMF 关联状态、把会话规则翻译并下发到内核 gtp5g 模块、向 smf 上报下行数据触发（DLDR）与用量测量（USAR）、为下行不可达场景维护 per-PDR 报文缓冲。它不做会话决策（归 smf）、不做接入控制（归 amf）、不在用户态接触用户报文内容（归内核 gtp5g），是控制面与数据面的边界翻译层与上报通道。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | PFCP 关联管理 | 维护与 SMF 的 N4 关联状态，是所有会话操作的前置 |
| CAP-002 | PFCP 心跳保活 | 检测 N4 链路可用性，触发对端节点失活感知 |
| CAP-003 | PFCP 会话生命周期 | 建立/修改/删除 PFCP 会话，是用户面规则的承载容器 |
| CAP-004 | 转发规则下发 | 将 PDR/FAR/QER/URR/BAR 翻译为内核 gtp5g 可执行的 netlink 命令 |
| CAP-005 | 三阶段会话提交 | 校验/执行/应用分离，保证 plan 验证与状态变更原子语义 |
| CAP-006 | 互斥规则校验 | 拒绝同请求内对同 ID 规则的冲突操作，防止规则集不一致 |
| CAP-007 | PFCP 事务管理 | 请求重传与响应去重，保障 PFCP 信令在不可靠 UDP 上的可达性 |
| CAP-008 | 下行数据通知（DLDR） | 内核 gtp5g 检测 UE 不可达时，触发 smf 发起 Paging |
| CAP-009 | 用量上报（USAR） | URR 触发条件满足时上报流量/时长测量，是计费与策略反馈输入 |
| CAP-010 | URR 周期触发调度 | 在用户态维护 PERIO 定时器，弥补内核 gtp5g 不维护周期上报 |
| CAP-011 | 报文缓冲队列 | per-PDR 下行缓冲，配合 BUFF/NOCP 动作支撑 UE 不可达场景 |
| CAP-012 | GTP-U 链路与路由 | 在系统中创建 gtp5g 网络设备并按 DNN 配置加路由，使内核可承接数据面 |
| CAP-013 | 内核模块版本约束 | 启动时校验 gtp5g 内核模块版本范围，拒绝不兼容环境 |
| CAP-014 | PFCP 报文边界校验 | 头部长度与会话 ID 校验，防御畸形输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | 用户面数据路径全量下沉内核，避免用户态↔内核态拷贝；用户态 PFCP 控制面单循环串行处理，避免锁竞争；用户面线速依赖内核 gtp5g 能力 |
| 可靠性 | PFCP 请求重传 + 响应去重缓存；会话建立阶段 fail-fast 完全回滚；会话修改阶段 best-effort 保持尽可能多的规则生效；goroutine 顶层 recover 防 panic |
| 可用性 | 优雅关停（SIGTERM → 停 PFCP server → 关 driver）；Association 重建按 TS 29.244 删除旧关联与全部会话 |
| 可扩展性 | Forwarder 通过 Driver 接口抽象，便于替换转发引擎（gtp5g/Empty 测试桩，未来可扩 DPDK/eBPF） |
| 安全性 | 关联 NodeID 校验拒绝未关联 SMF 的会话请求；PFCP IE 强校验；不持久化 UE IP；用户面隔离（内核态处理，不暴露给用户态进程） |
| 可测试性 | Driver 接口允许注入 Empty 实现，CI 环境无需加载 gtp5g 内核模块；详见 `repos/go-upf/.agent/DTFrame.md` |
| 可观测性 | 7 类分类 logger（NF/Main/CFG/PFCP/BUFF/Perio/FWD）+ 9 字段结构化（含 NodeID/SEID/PFCP Tx/Rx）+ 7 级可配日志 |

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途。**注意：upf 不提供 SBI HTTP 接口**，所有对外接口为 PFCP（N4）或 GTP-U（N3/N9）协议层接口。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | HeartbeatRequest/Response | PFCP (N4, UDP/8805) | N4 链路保活 |
| IF-002 | AssociationSetupRequest/Response | PFCP (N4) | SMF↔UPF 关联建立，是所有会话操作前置 |
| IF-003 | AssociationUpdateRequest/Response | PFCP (N4) | 关联更新（本元素未实现，仅响应） |
| IF-004 | AssociationReleaseRequest/Response | PFCP (N4) | 关联释放（本元素未实现，仅响应） |
| IF-005 | SessionEstablishmentRequest/Response | PFCP (N4) | 会话建立，承载 PDR/FAR/QER/URR/BAR 规则下发 |
| IF-006 | SessionModificationRequest/Response | PFCP (N4) | 会话修改，规则增删改查 + 互斥校验 |
| IF-007 | SessionDeletionRequest/Response | PFCP (N4) | 会话删除 + 终态用量上报 |
| IF-008 | SessionReportRequest/Response | PFCP (N4) | UPF 主动上报：下行数据触发（DLDR）+ 用量上报（USAR） |
| IF-009 | GTP-U Data (N3) | GTP-U (UDP/2152) | gNB↔UPF 用户面隧道（内核 gtp5g 实现） |
| IF-010 | GTP-U Data (N9) | GTP-U (UDP/2152) | UPF↔UPF 用户面隧道（内核 gtp5g 实现） |
| IF-011 | N6 IP Output | Raw IP | UPF↔DN 出口（内核路由直出，无 GTP 封装） |

**契约详情**（PFCP 消息类型/IE 字段/Cause 错误码/事务序号管理）：见 `repos/go-upf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| smf | PFCP 对端，下发 PDR/FAR/QER/URR/BAR 规则；接收 DLDR/USAR 上报；本元素是 PFCP 被动方 |
| gtp5g 内核模块 | 用户面数据转发引擎，承担 N3/N9 GTP-U 收发与 N6 路由（外部内核模块，非系统 NF） |
| RAN (gNB) | N3 GTP-U 隧道对端（外部系统，通过内核 gtp5g 交互） |
| DN (Data Network) | N6 路由出口（外部系统，通过内核路由直出） |
| 其他 upf 实例 | N9 GTP-U 隧道对端（可选，多 UPF 串联场景） |

**详细依赖清单与调用时机**：见 `repos/go-upf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| PFCP 会话（Sess） | 维护 PDR/FAR/QER/URR/BAR ID 集合与 per-PDR 缓冲队列，是用户面规则在控制面的容器 | 内存，非持久化，重启丢失 |
| 本地节点（LocalNode） | 维护本端 SEID 分配池与会话集合（slice + free 列表复用 SEID） | 内存 |
| 远端节点（RemoteNode） | 维护远端 SMF NodeID 与关联会话集，是关联状态承载 | 内存 |
| Tx/Rx 事务 | 请求重传与响应去重的事务对，保障 PFCP 可靠性 | 内存，带超时清理 |
| ModificationPlan | 一次会话操作的完整规则操作清单（已校验 + 已翻译为 netlink Attrs） | 内存，单次操作生命周期 |
| 缓冲队列 | per-PDR 下行报文 ring buffer（BUFFQ_LEN=512），支撑 BUFF/NOCP 场景 | 内存，溢出丢弃 |
| UPF 配置 | NodeID、PFCP 监听、GTP-U 接口表、DNN CIDR 列表 | YAML 配置文件 |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制，无 Dockerfile，由 free5gc 顶层统一打包），运行于 Linux 主机且**必须加载兼容版本的 gtp5g 内核模块**（[0.9.5, 0.11.0)）
- **副本策略**：单实例部署；多 UPF 场景通过 SMF 选择不同 UPF NodeID + N9 串联实现，本元素自身不做集群协调
- **启动依赖**：
  - gtp5g 内核模块已加载且版本在兼容区间（校验失败拒绝启动）
  - SMF 后续发起 PFCP AssociationSetup（本元素是被动方，启动时不主动连接 SMF）
  - YAML 配置文件就绪（强制 Config.Version="1.0.3"、强制 Gtpu.Forwarder="gtp5g"、IfInfo.Type∈{N3,N9}、DnnList.Cidr 为合法 CIDR）
- **可观测出口**：logrus 分模块日志（7 级可配，9 个结构化字段）+ 启动配置 spew.Sdump；**本元素未集成 Prometheus 指标端口**（与 amf 不同）
- **终止行为**：SIGINT/SIGTERM → context cancel → 停 PFCP server → 关 driver；本元素不向 SMF 主动注销关联（PFCP 协议层无注销动作，由 SMF 通过心跳超时感知）

