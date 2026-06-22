---
element_id: tngf
element_name: tngf
element_type: service
repo_path: repos/tngf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: medium
---

# 架构元素规格：tngf

> 本文件是**架构层抽象**，描述 tngf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体功能点、协议消息字段、数据结构、代码位置）归 `repos/tngf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
tngf 是 3GPP 5G 系统的**受信非 3GPP 接入网关**（Trusted Non-3GPP Gateway Function，TS 23.501/24.502/33.501），负责将 UE 经由受信 WLAN（TWAN）接入 5G 核心网。它在接入侧终结 RADIUS（承载 EAP-5G 主鉴权）、IKEv2/IPsec（建立 UE↔TNGF 加密通道）、NWt-cp（NAS over TCP）、NWt-up（GRE 用户面）四类协议；在核心网侧通过 NGAP/SCTP（N2）与 AMF 协作，通过 GTP-U（N3）与 UPF 转发用户面。在架构上，tngf 是受信 WLAN 与 5GC 之间的协议网关，承担非 3GPP 接入与 3GPP 服务化域之间的协议/安全/承载转换。tngf 代码栈在 n3iwf 基础上演化，保留完整 IKE/IPsec/XFRM 能力，但接入鉴权主路径改为 RADIUS/EAP-5G。

| 项目 | 内容 |
|------|------|
| 元素ID | tngf |
| 元素名 | tngf |
| 元素类型 | service（**非 SBI 网元**，独立部署，对外为 RADIUS/IKEv2/IPsec/NAS-TCP/GRE/NGAP/GTP-U 协议端点） |
| 所属代码仓 | repos/tngf |
| 置信度 | 中（与 3GPP TS 24.502 trusted 接入语义对齐、n3iwf 演化残留路径定位、与 AMF/UPF 跨仓时序在仓内无明确量化声明） |

## 2. 职责描述
tngf 承担受信非 3GPP 接入的协议网关职责：把 UE 在 WLAN 侧的 RADIUS/EAP-5G/IKEv2 信令转换为 5GC 侧的 NGAP/N2 信令送达 AMF，把 UE 用户面 IP 包经由 IPsec/GRE 通道桥接到 GTP-U/N3 隧道送达 UPF。它不承担订阅鉴权决策（归 AUSF/UDM）、不承担会话决策（归 SMF）、不承担用户面策略（归 UPF/PCF），是协议与承载的转换者。**tngf 不提供 SBI/HTTP 服务接口**，与服务化域的耦合仅经 NGAP。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | 受信 WLAN 接入鉴权 | 经 RADIUS/EAP-5G 触发 UE 主鉴权，是非 3GPP UE 进入 5GC 的入口 |
| CAP-002 | NAS 承载与上送 | 在 EAP-5G 与 NWt-cp 双通道承载 UE↔AMF NAS 信令，是控制面协议桥 |
| CAP-003 | NGAP 信令处理 | 终结 N2 协议，作为 AMF 视角的"RAN 节点"承载 UE 上下文/会话管理 |
| CAP-004 | IPsec 安全通道 | 经 IKEv2 协商 SA，为 UE↔TNGF 控制面与用户面提供加密保护 |
| CAP-005 | 用户面承载桥接 | GRE-over-IPsec ↔ GTP-U 双向转换，是 UE 用户面到 UPF 的数据通路 |
| CAP-006 | UE 上下文管理 | 维护 TNGFUe（NGAP ID/Inner IP/PDU Session/安全密钥）生命周期 |
| CAP-007 | RADIUS 会话管理 | 按 Calling-Station-ID 维护 EAP 状态机，支撑多轮 EAP-5G 交互 |
| CAP-008 | 多 AMF 选择 | 按 UE 提供的 GUAMI 与 PLMN 选择目标 AMF，支撑 AMF 池化部署 |
| CAP-009 | UE 内层 IP 分配 | 从配置 CIDR 池为 UE 分配 inner IP，与 WLAN 外层地址解耦 |
| CAP-010 | TEID 分配与 GTP-U 隧道 | 分配 N3 隧道标识，建立与 UPF 的用户面承载 |
| CAP-011 | XFRM 虚拟接口管理 | 经内核 netlink 创建/清理 IPsec 虚拟接口，是数据面承载基础 |
| CAP-012 | 指标暴露 | 向 Prometheus 暴露 NGAP 与进程指标，供运维拉取 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | NGAP/IKE/RADIUS 消息按 goroutine 并发处理；UE 与 SA 池采用无锁化共享访问；SCTP 单连接处理 N2 流量 |
| 可靠性 | 启动期 SCTP 重试容错；所有分发路径具备 panic 兜底，单连接异常不影响进程；进程退出时清理 XFRM 虚拟接口 |
| 可用性 | AMF 不可达时启动 SCTP 重试；接收非法 PPID/短包静默丢弃不中断服务；信号驱动优雅终止 |
| 可扩展性 | UE/AMF/SA/会话池规模仅受 ID 空间约束（NGAP ID 至 MaxInt64、TEID 至 MaxUint32）；UE inner IP 受配置 CIDR 限制 |
| 安全性 | RADIUS 强制 Message-Authenticator 校验；IKE 强制 DH 公钥与算法白名单（拒绝弱/NULL）；IPsec ESP 加密 NAS 与用户面；密钥与证书走文件系统加载，私钥强类型断言 |
| 可测试性 | dispatcher 与 handler 解耦，便于注入伪 NGAP/IKE/RADIUS 输入；测试基础设施详见 `.agent/DTFrame.md` |
| 可观测性 | 子系统分模块 logger（IKE/Radius/Ngap/GTP/Context/Init/Main/Cfg）；Prometheus 指标独立端口（默认 9091，可 mTLS） |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。tngf **非 SBI**，全部为协议端点而非 HTTP 服务。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | RADIUS 接入鉴权端点 | RADIUS over UDP (RFC 2865/3579) | 接收 TWAN/AP 转发的 Access-Request，承载 EAP-5G 主鉴权 |
| IF-002 | IKEv2 协商端点 | IKEv2 over UDP/500、UDP/4500 (RFC 7296) | 与 UE 协商 IKE_SA 与 Child SA，建立 IPsec 安全通道 |
| IF-003 | IPsec ESP 数据通道 | IPsec ESP (RFC 4303) via XFRM | UE↔TNGF 控制/用户面加密承载 |
| IF-004 | NAS over TCP（NWt-cp） | TCP (经 IPsec 内层) | UE↔TNGF 内层 NAS 信令承载 |
| IF-005 | NWt 用户面 GRE 端点 | GRE + IPv4 (经 IPsec) | UE 上行用户面承载（含 QFI 标记） |
| IF-006 | NGAP / N2 | NGAP over SCTP (TS 38.413, PPID=60) | 与 AMF 控制面交互，承载 NAS/上下文/会话管理 |
| IF-007 | GTP-U / N3 | GTP-U over UDP (TS 29.281, 2152) | 与 UPF 用户面隧道，转发 UE T-PDU |
| IF-008 | Prometheus Metrics | HTTP(S) GET /metrics | 向监控系统暴露 NGAP 与进程指标 |

**契约详情**（协议字段/消息类型/过程码/错误处理）：见 `repos/tngf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| amf | N2/NGAP 控制面下游，承载 UE 注册/鉴权/上下文/会话/移动性所有控制信令 |
| upf | N3/GTP-U 用户面下游，承载 UE 上下行 PDU 隧道 |
| TWAN/AP | 接入侧 RADIUS 转发者，是 UE 进入 tngf 的前置（外部接入网设备） |
| UE | IKEv2/IPsec/NWt 通道对端（外部终端） |
| Linux 内核（XFRM/netlink） | 通过 netlink 创建 IPsec 虚拟接口，是数据面承载的运行时依赖 |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/tngf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| TNGFUe 上下文 | 维护 UE 的 NGAP ID、内层 IP、PDU Session、安全密钥（Ktngf/Ktnap/Ktipsec），是控制面核心状态 | 内存，非持久化，重启丢失 |
| RADIUS 会话 | 按 Calling-Station-ID 维护 EAP 多轮交互状态 | 内存 |
| IKE SA / Child SA | 维护 IKEv2 协商结果与 ESP 加解密参数 | 内存 |
| TNGFAMF 上下文 | 维护多 AMF 实例与 SCTP 连接、AMFReInit 可用列表 | 内存 + YAML 配置 |
| GTP 连接池 | 按 UPF 维护 GTP-U 连接复用 | 内存 |
| UE 内层 IP 池 | 从配置 CIDR 中分配的 UE inner IP 占用表 | 内存 |
| XFRM 接口表 | 已创建的 IPsec 虚拟接口（默认+UP 偏移） | 内存 + 内核 netlink 状态 |
| TNGF 全局配置 | NF 实例信息、接入侧绑定、AMF SCTP 地址、UEIPAddressRange、证书路径 | YAML 配置 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化（由 free5gc-compose 主仓打镜像，本仓无 Dockerfile）
- **副本策略**：单副本部署；多副本需在 TWAN 接入侧做 RADIUS 负载、并由配置区分 IKE/NGAP 绑定地址
- **启动依赖**：AMF SCTP 可达（启动期重试 3 次×1s）、Linux 内核 XFRM 支持与 CAP_NET_ADMIN 权限、RSA 私钥与 X.509 CA/证书就绪、`./config/tngfcfg.yaml` 配置文件就绪、TWAN/AP 配置 RADIUS 共享密钥
- **可观测出口**：Prometheus 指标（默认 9091，scheme 默认 https，命名空间 free5gc，可独立 mTLS）+ 模块分类 logrus 日志（trace/debug/info/warn/error/fatal/panic 七级）
- **终止行为**：SIGINT/SIGTERM → 取消 ctx → 停止 Metrics → 经 netlink LinkDel 清理所有 XFRM 虚拟接口；当前实现未观察到向 AMF 主动发送 NG 注销过程
