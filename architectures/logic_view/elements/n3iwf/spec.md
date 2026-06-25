---
element_id: n3iwf
element_name: n3iwf
element_type: service
repo_path: repos/n3iwf
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: high
---

# 架构元素规格：n3iwf

## 1. 元素定位

**现状**（事实域）：
n3iwf 是 5G 核心网中的**非可信非 3GPP 接入网关**（Non-3GPP Interworking Function，TS 23.501）。它对 UE 侧充当 IKEv2/IPsec 安全网关并嵌入 EAP-5G 完成 NAS 注册鉴权，对核心网控制面侧以 NG-RAN 角色经 NGAP/SCTP 与 AMF 协同，对用户面侧经 GTP-U（N3）与 UPF 互联。在 5GC 拓扑中处于**接入域与核心域之间的协议边界**，使 WiFi 等非 3GPP 接入能透明纳入 5G 控制面与用户面。

**原设计意图**（意图域）：
-

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | n3iwf | - |
| 元素名 | n3iwf | - |
| 元素类型 | service | - |
| 所属代码仓 | repos/n3iwf | - |
| 战略角色 | 非 3GPP 接入安全网关（双面：UE 侧 IKEv2/IPsec + 核心网侧 NG-RAN 角色） | - |
| 置信度 | 高 | - |

## 2. 职责描述

**现状**（事实域）：
承担三类架构职责：
1. **接入安全边界**：在 UE 与 5GC 之间维持 IKEv2/IPsec 安全隧道，保证非可信链路上的机密性、完整性与抗重放。
2. **协议适配**：把非 3GPP 接入下的 UE 信令以 EAP-5G 封装 5GS NAS，并在 IKE_AUTH 多轮交换中与 AMF（NGAP）做双向中继，使 UE 表现为标准 NG-RAN 接入者。
3. **用户面转发**：在 UE 侧（GRE over IPsec，携带 QFI）与 UPF 侧（GTP-U/N3，携带 PDU Session Container 扩展头）之间做双向数据面转发，IPsec 加解密由 Linux 内核 XFRM 卸载。

**原设计意图**（意图域）：
-

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | IKEv2 安全关联建立 | 与 UE 建立 IKE SA 与初始 IPsec Child SA，构筑非可信链路上的安全隧道 | - |
| CAP-002 | EAP-5G 注册鉴权封装 | 在 IKE_AUTH 阶段封装 5GS NAS 完成 UE 注册与鉴权（5G-AKA / EAP-AKA'），桥接非 3GPP 接入与 5GC 鉴权域 | - |
| CAP-003 | IPsec/XFRM 隧道生命周期管理 | 通过 Linux XFRM 安装控制面与每会话用户面 Child SA，并在会话终止时回收 XFRM 接口 | - |
| CAP-004 | NAS over IPsec 中继 | 注册成功后在 UE↔AMF 之间双向中继 NAS 信令（NWuCP TCP ↔ NGAP UL/DL NAS Transport） | - |
| CAP-005 | NGAP/N2 信令处理 | 作为 NG-RAN 节点与 AMF 完成 NG Setup、Initial Context Setup、UE Context、PDU Session Resource 等 N2 程序 | - |
| CAP-006 | PDU 会话用户面建立 | 协同 AMF（PDU Session Resource Setup/Modify/Release）建立每会话 Child SA + GTP-U N3 隧道与 TEID 映射 | - |
| CAP-007 | 用户面双向转发 | UE↔UPF 数据面适配：上行 GRE 解封装→GTP-U 封装；下行 GTP-U 解封装→GRE 封装 | - |
| CAP-008 | UE 多视图上下文管理 | 维护 IKE UE / RAN UE / N3IWF UE 三类视图及 SPI ↔ RAN_UE_NGAP_ID ↔ AMF_UE_NGAP_ID 映射 | - |
| CAP-009 | 多 AMF SCTP 协同 | 支持多 AMF 池、AMF Configuration Update、Overload Start/Stop、NG Reset，实现控制面容灾 | - |
| CAP-010 | Liveness 检测（DPD） | 通过 IKEv2 INFORMATIONAL 心跳检测 UE 通路存活，可调 TransFreq / MaxRetryTimes | - |
| CAP-011 | 指标暴露 | 暴露 Prometheus 端点（NGAP 类指标）供监控拉取，可选 mTLS | - |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | 控制面与数据面解耦：协议栈在用户态，IPsec 加解密 + 转发 IO 下沉到 Linux 内核 XFRM；IKE/NGAP 收包通过长度 512 的 SafeCh 与处理解耦，避免协议栈阻塞 | - |
| 可靠性 | 多 AMF 池支持容灾；NG Reset / AMF Overload Start/Stop 自愈；各子服务 WaitGroup 协同优雅退出并反向清理 XFRM 接口 | - |
| 可用性 | 单 AMF 不可达不影响其他 AMF 关联；启动期 NGSetup 失败标记该 AMF 不可用，仍可对其他 AMF 提供服务 | - |
| 可扩展性 | 多 AMF SCTP 关联可水平扩展；UE 内网 IP 池由 CIDR 配置决定单实例容量上限；XFRM 接口按 PDU 会话独立创建（id=default+offset） | - |
| 安全性 | 所有 UE 流量在 IPsec ESP 内承载，启用 Replay Window 抗重放；IKEv2 证书 + EAP-5G 双向身份认证；协议解码严格 bounds check（GRE、IKE Internal IP4 等）；AN-Parameter 四类异常显式拒绝；TLS Key Log 仅 debug 启用 | - |
| 可测试性 | UT 与源码同包 `*_test.go` + testify；XFRM/SCTP/netlink/raw socket 类系统依赖通过接口隔离或手写桩（`internal/context/testing_app.go`）；UT 不依赖网络/磁盘/root | - |
| 可观测性 | 分模块 logger（MainLog/CfgLog/InitLog/IKELog/NgapLog/NWuCPLog/NWuUPLog 等）+ nested-logrus-formatter；Prometheus 默认关闭、启用时强制 https + namespace=free5gc，可选 mTLS；pprof 仅 `-debug` 启用，独占 :6061 | - |

实现细节与代码证据见 `repos/n3iwf/.agent/design.md §11 DFX 设计`、`repos/n3iwf/.agent/rules/约束/可观测性.md`、`repos/n3iwf/.agent/DTFrame.md §2 测试防护网分层`。

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。本章节为**事实纯度章节**，不夹意图。
> **关键差异**：n3iwf 不提供 SBI HTTP 服务接口。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | IKEv2 (UE↔N3IWF) | IKEv2/UDP（500，4500 NAT-T） | 与 UE 建立 IKE SA 与 IPsec Child SA |
| IF-002 | EAP-5G over IKE_AUTH | EAP 载荷嵌入 IKE_AUTH（TS 33.501 Annex T） | 在 IKE_AUTH 多轮交换中承载 5GS NAS 完成注册鉴权 |
| IF-003 | NAS over IPsec (NWuCP) | TCP（端口 `nasTcpPort`）承载于 IPsec 隧道内 | UE 注册成功后承载后续 NAS 信令 |
| IF-004 | NGAP (N3IWF→AMF) | NGAP/SCTP（38412，TS 38.413） | 作为 NG-RAN 节点主动发起的 N2 程序（NG Setup、Initial UE、UL NAS、UE Ctx Release Request、PDU Sess Setup Response 等） |
| IF-005 | NGAP (AMF→N3IWF) | NGAP/SCTP（38412） | 接收 AMF 主导的 N2 程序（Initial Context Setup、DL NAS、PDU Sess Setup/Modify/Release、UE Ctx Release Cmd、AMFConfigurationUpdate、Overload、NG Reset 等） |
| IF-006 | GRE (UE↔N3IWF 用户面) | GRE（IP proto 47）over IPsec ESP | UE 用户面 IP 报文承载，GRE Key 携带 5G QFI |
| IF-007 | GTP-U (N3IWF↔UPF) | GTP-U v1/UDP（2152，TS 29.281） | N3 接口承载 PDU 会话用户面，PDU Session Container 扩展头携带 QFI |
| IF-008 | Metrics HTTP | HTTP/HTTPS（默认 9091，可选 mTLS） | Prometheus 拉取 NGAP 指标，namespace=free5gc |

**契约详情**（exchange/操作清单/报文格式/错误码）：见 `repos/n3iwf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。
> **关键差异**：n3iwf 不依赖任何 SBI 类 NF（NRF/AUSF/UDM/PCF/NSSF/UDR/SMF/CHF 等）；所有 5GC 控制面跨 NF 协作经 AMF（N2/NGAP）中转。

| 依赖元素 | 架构用途 |
|----------|----------|
| amf | 控制面对端，承载 EAP-5G 注册、NAS 中继、PDU 会话编排、UE 上下文管理；n3iwf 作为 NG-RAN 节点与 AMF 完成所有 N2 程序 |
| upf | 用户面 N3 对端，承载 PDU 会话用户面（GTP-U 双向） |

外部基础设施（非 NF 元素，不入 elements_tree）：UE（WiFi 接入设备，协议对端）、Linux 内核 XFRM（netlink，IPsec 卸载与接口管理）、Prometheus（指标 scrape）。

**详细依赖清单与调用时机**：见 `repos/n3iwf/.agent/spec.md §4.1 / §4.2` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| N3IWF 全局上下文 | 维护 UE 池、AMF 池、IP/SPI/TEID 分配池、XFRM 接口映射 | 内存，重启丢失 |
| UE 三视图上下文（IKE UE / RAN UE / N3IWF UE） | 同一 UE 在 IKE / NGAP / 顶层关联三个视图下的状态，建立 SPI ↔ RAN_UE_NGAP_ID ↔ AMF_UE_NGAP_ID 映射 | 内存 |
| AMF 上下文 | 单条 AMF SCTP 关联、AMFName、RelativeAMFCapacity、Overload 状态 | 内存 |
| IKE Security Association | IKE SA 状态、密钥与 SPI | 内存 |
| Child Security Association | IPsec Child SA、SPI、加密 / 完整性算法、XFRM 接口绑定 | 内存（SA 同时安装于 Linux XFRM 内核态） |
| PDU 会话上下文 | TEID、QFI、UPF 地址、对应 IPsec Child SA 与 XFRM 接口 | 内存 |
| UE 内网 IP 池 | 为 UE 在 IPsec 隧道内分配 inner IP，容量由 CIDR 决定 | 内存 |
| Ike/Ngap 事件 | 跨模块解耦的事件载荷，经 SafeCh 单向投递 | 进程内通道，瞬时 |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 单进程二进制（`bin/n3iwf`）；运行在 Linux 主机或具备 CAP_NET_ADMIN 与 XFRM 模块的特权容器中 | - |
| 副本策略 | 单实例为主；多实例需各自绑定独立 IKE/NAS/GTP 监听 IP 并由 UE 侧选择，控制面通过多 AMF SCTP 关联水平协同 | - |
| 启动依赖 | AMF 至少一条 SCTP 关联可达；Linux 内核 XFRM 模块、netlink、root（绑 UDP 500/4500、创建 XFRM 接口）；配置文件 `info.version=1.0.5` 强校验；UPF 可后启 | - |
| 可观测出口 | 分模块 logrus 日志（stdout / 文件）；可选 Prometheus `/metrics`（默认 9091，https，可 mTLS）；可选 pprof `:6061`（`-debug`） | - |
| 终止行为 | SIGINT/SIGTERM → cancel ctx → 各子服务 Stop → WaitGroup 等待 → 删除所有 XFRM 接口；NGAP 子服务 panic 走 Fatalf 退出以便容器编排重启 | - |
| 容量规格 | UE 数受 `ueIpAddressRange` CIDR 决定；TEID/SPI 受 32 位地址空间约束；SafeCh 长度 512 触发背压；SCTP 单包缓冲 65535 | - |
| 监听端口 | UDP 500 / 4500（IKE / NAT-T）、TCP `nasTcpPort`（IPsec 内）、SCTP 38412 出方向（→AMF）、UDP 2152（GTP-U）、HTTPS 9091（Metrics 可选）、HTTP 6061（pprof 可选） | - |

部署细节见 `repos/n3iwf/.agent/spec.md §6 构建与部署` 与 `repos/n3iwf/.agent/design.md §1 设计目标与约束`。

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| - | - |
