---
element_id: n3iwf
element_name: n3iwf
element_type: service
repo_path: repos/n3iwf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：n3iwf

> 本文件是**架构层抽象**，描述 n3iwf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（协议帧、Handler 列表、XFRM 配置、代码位置）归 `repos/n3iwf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
n3iwf 是 3GPP 5G 核心网的**非 3GPP 接入安全网关**（Non-3GPP Interworking Function），是非可信非 3GPP 网络（典型为公共 WiFi）中的 UE 接入 5GC 的唯一信任边界。它在 UE 与 5GC 之间承担**双面互通**职责：UE 侧以 IKEv2/IPsec 建立加密隧道并通过 EAP-5G 嵌入 5GS NAS 完成注册鉴权；核心网侧以 NG-RAN 节点身份与 AMF（NGAP/N2）、UPF（GTP-U/N3）协同。架构上 n3iwf 解耦了"非 3GPP 物理接入"与"5GC 控制/用户面协议"，使非 3GPP 接入在 5GC 视角下等同于一个特殊的 RAN 节点。**与控制面 SBI 类 NF 不同，n3iwf 不暴露任何 SBI HTTP 服务接口**，对外接口全部为协议级（IKEv2/NGAP/GTP-U/GRE）。

| 项目 | 内容 |
|------|------|
| 元素ID | n3iwf |
| 元素名 | n3iwf |
| 元素类型 | service（协议级安全网关 NF，独立部署，非 SBI） |
| 所属代码仓 | repos/n3iwf |
| 置信度 | 高 |

## 2. 职责描述
n3iwf 承担**非 3GPP 接入的协议适配与安全终结**职责：终结 UE 侧 IKEv2/IPsec 与 EAP-5G，将 5GS NAS 透明转发到 AMF；作为 NG-RAN 节点终结 N2 NGAP 信令；建立并维护 UE 用户面的 IPsec Child SA 与 N3 GTP-U 隧道，完成 GRE↔GTP-U 的双向桥接。它不解析 NAS 业务语义、不参与鉴权/订阅/策略决策（全部经 AMF 中转），是协议网关与安全边界，不是控制面决策者。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | IKEv2 安全关联建立 | 在非可信网络上建立 UE↔n3iwf 的加密信任通道 |
| CAP-002 | EAP-5G 注册鉴权封装 | 在 IKE_AUTH 阶段承载 5GS NAS，完成非 3GPP 接入下的 UE 主认证 |
| CAP-003 | IPsec/XFRM 隧道管理 | 通过内核 XFRM 卸载加解密，建立 CP 与 per-PDU UP 双类 SA |
| CAP-004 | NAS over IPsec 中继 | UE↔AMF NAS 信令的协议网关，隔离非 3GPP 链路与 N2 |
| CAP-005 | NGAP 信令处理 | 以 NG-RAN 节点身份终结 N2，承担 RAN 行为责任 |
| CAP-006 | PDU 会话用户面建立 | 为每个 PDU 会话分配 Child SA + GTP-U 隧道 + TEID 映射 |
| CAP-007 | GTP-U 用户面隧道 | 与 UPF 建立 N3 用户面，承载下行/上行 G-PDU |
| CAP-008 | GRE 封装/解封装 | UE 侧用户面承载，通过 GRE Key 传递 5G QFI |
| CAP-009 | 用户面双向转发 | GRE↔GTP-U 桥接，是非 3GPP 接入的用户面数据通路 |
| CAP-010 | UE 三视图上下文管理 | IKE UE / RAN UE / N3IWF UE 三视图映射，串联协议域 |
| CAP-011 | 多 AMF SCTP 协同 | 支持 AMF Pool、Overload、NG Reset、AMF Configuration Update |
| CAP-012 | Liveness 检测（DPD） | IKEv2 Informational 心跳，及时清理半死 UE 连接 |
| CAP-013 | Prometheus 指标暴露 | 向运维系统暴露 NGAP 指标 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | IKE/NGAP 异步流水线，收包与处理解耦；用户面加解密下沉内核 XFRM；数据面零拷贝转发 |
| 可靠性 | 多 AMF 容灾（AMF Pool）；支持 NG Reset / AMF Overload Start/Stop；优雅退出时拆除 XFRM 接口 |
| 可用性 | AMF 连接断开不阻塞元素启动；单 UE 故障经 panic 隔离（goroutine defer recover）不传播 |
| 可扩展性 | per-PDU 独立 XFRM 接口（id 偏移分配）；UE/会话/SPI/TEID 池化；safe_channel 背压保护 |
| 安全性 | 非 3GPP 流量必须经 IPsec ESP 承载；IKEv2 双向证书认证 + EAP-5G 主认证；IPsec replay window 启用；GRE/IKE 解码强制边界校验；NAS 安全上下文强制建立 |
| 可测试性 | 协议处理与 IO 分层（Dispatch / Handler / Send），便于在不依赖内核 XFRM 的条件下做协议层 UT |
| 可观测性 | 分模块 logger（IKE/NGAP/NWuCP/NWuUP/Cfg）+ 独立 Metrics HTTPS 端口（可选 mTLS）+ pprof（debug） |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。**n3iwf 不提供 SBI**，所有对外接口均为协议级。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | IKEv2 (UE↔N3IWF) | IKEv2/UDP 500,4500 | 在非可信网络建立 IKE SA 与 IPsec Child SA |
| IF-002 | EAP-5G over IKE_AUTH | EAP 载荷 in IKEv2 | 在 IKE_AUTH 阶段承载 5GS NAS 完成注册鉴权 |
| IF-003 | NAS over IPsec (NWuCP) | TCP in IPsec | UE 注册后承载后续 NAS 信令，TCP 内嵌于 IPsec 隧道 |
| IF-004 | NGAP (N3IWF→AMF) | NGAP/SCTP 38412 | n3iwf 作为 NG-RAN 节点向 AMF 发起的 N2 程式码 |
| IF-005 | NGAP (AMF→N3IWF) | NGAP/SCTP 38412 | 接收 AMF 主导的 N2 程式码（注册响应/会话/释放/流控） |
| IF-006 | GRE (UE↔N3IWF) | GRE over IPsec | 承载 UE 用户面 IP 报文，Key 字段携带 5G QFI |
| IF-007 | GTP-U (N3IWF↔UPF) | GTP-U/UDP 2152 | N3 接口承载 PDU 会话用户面（含 QFI 扩展头） |
| IF-008 | Metrics HTTP(S) | HTTP/HTTPS | Prometheus 拉取 NGAP 指标，可选 mTLS |

**契约详情**（协议字段/操作列表/报文格式/错误码）：见 `repos/n3iwf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。**n3iwf 不依赖任何 SBI 类 NF（NRF/AUSF/UDM/PCF/NSSF/UDR 等）**，所有控制面交互均经 AMF 中转。

| 依赖元素 | 架构用途 |
|----------|----------|
| amf | N2/NGAP 控制面对端，承载 EAP-5G 注册、NAS 中继、PDU 会话编排、UE 上下文管理 |
| upf | N3/GTP-U 用户面对端，承载 PDU 会话用户面数据双向转发 |
| UE（WiFi 接入设备） | IKEv2/IPsec/EAP-5G/NAS over IPsec/GRE 的协议对端（外部系统） |
| Linux 内核（XFRM） | IPsec SA 安装与卸载，加解密内核态卸载（运行环境依赖） |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/n3iwf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| IKE UE 上下文 | 维护 IKE SA、Child SA、SPI、密钥材料、NAT-T 状态 | 内存，非持久化，重启丢失 |
| RAN UE 上下文 | 维护 RAN_UE_NGAP_ID/AMF_UE_NGAP_ID 与 NGAP 状态 | 内存 |
| N3IWF UE 上下文 | 维护 UE 三视图聚合状态与 PDU 会话集合 | 内存 |
| AMF Pool | 多 AMF SCTP 连接池与按 AMF 的容量/Overload 状态 | 内存 + YAML 配置 |
| UE 内网 IP 池 | UE 在 IPsec 隧道内分配的内网 IP，由 ueIpAddressRange CIDR 限定容量 | 内存 |
| SPI / TEID 分配表 | IKE SA SPI 与 GTP-U TEID 的分配与映射 | 内存（sync.Map） |
| XFRM 接口表 | 控制面默认 XFRM 接口（id=7） + per-PDU 用户面 XFRM 接口（id=7+N） | 内核 XFRM 状态（进程外） |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化但需 host network + root 权限（绑 UDP 500/4500 + netlink 操作 XFRM）
- **副本策略**：单实例部署；横向扩展需 UE→n3iwf 入口的 LB（IKEv2 + IPsec 难以无状态分流，通常按 n3iwf 实例划分 UE 池或 IP 段）
- **启动依赖**：AMF SCTP 端口可达（至少一个 AMF 在 AMFPool）；Linux 内核 XFRM 模块就绪；IKEv2 证书/私钥/CA 文件就绪；YAML 配置就绪（config version 严格校验 1.0.5）
- **可观测出口**：Prometheus Metrics HTTPS（默认 9091，可选 mTLS）+ logrus 分模块日志（IKE/NGAP/NWuCP/NWuUP/Cfg/Main）+ pprof HTTP（:6061，仅 -debug 启用）
- **终止行为**：SIGINT/SIGTERM 触发 context cancel；按子服务 wg 等待 NGAP/IKE/NWuCP/NWuUP/Metrics 退出；调用 removeIPsecInterfaces 清理所有 XFRM 接口；NGAP SCTP 关联自然断开（不主动 NG Reset）
