---
element_id: smf
element_name: smf
element_type: service
repo_path: repos/smf
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: high
---

# 架构元素规格：smf

> 本文件是**架构层抽象**，结合代码逆向（事实域）与历史架构设计文档（意图域）综合生成。
> - **事实域**（接口、依赖、协议、当前 DFX 实现、当前部署形态）：以代码 + `repos/smf/.agent/*.md` 为准，标注"现状"。
> - **意图域**（战略角色、设计目的、原 DFX 目标、原部署规划）：以 `knowledge/历史方案/架构方案/` 为准，标注"原设计意图"。本元素采纳的历史方案候选 `Pando V1.0版本架构设计说明书.md` 内容为空、无 smf 相关章节，意图域各节均标注「无历史方案输入」。
> - 同章节内两类信息并存表达，明示标签。
> - 实现细节（具体功能点、接口契约签名、数据字段、代码位置）归 `repos/smf/.agent/*.md`，本文件不重复抄写，仅在节末以"契约详情见..."指引。

## 1. 元素定位

**现状**（事实域）：
smf 是 3GPP 5G 核心网控制面的会话管理网元，是 PDU 会话生命周期的唯一控制锚点。向上通过 SBI（Nsmf_PDUSession / Nsmf_EventExposure / Nsmf_Callback / Nsmf_OAM）与 amf 协作完成会话建立/修改/释放编排；向下通过 PFCP（N4）协议直接控制 upf 用户面；向侧通过 SBI 与 pcf/chf/udm/bsf/nrf 协同完成策略、计费、订阅数据与服务发现。在架构上 smf 是控制面与用户面解耦（CUPS）模型中的会话控制锚点，将 SBI 域的服务化信令翻译为 N4 域的用户面规则下发（PDR/FAR/QER/URR），并维护 UE IP 与 QoS Flow 的会话级状态。

**原设计意图**（意图域）：
无历史方案输入（参考自 Pando V1.0版本架构设计说明书 §-，文档内无 smf 章节）。

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | smf | - |
| 元素名 | smf | - |
| 元素类型 | service | - |
| 所属代码仓 | repos/smf | - |
| 战略角色 | 5GC 会话控制面锚点，PDU 会话编排者与用户面规则下发者 | 无历史方案输入 |
| 置信度 | 高 | - |

## 2. 职责描述

**现状**（事实域）：
smf 承担 5G 核心网的会话控制面职责：维护 PDU 会话状态机，编排会话建立/修改/释放跨 NF 流程，选择 UPF 并通过 PFCP 下发用户面规则，分配 UE IP 与 QoS Flow 标识，应用 PCF 策略与 CHF 计费触发，向订阅方暴露会话事件。它不承担用户面转发（归 upf 执行 PFCP 规则），不承担接入与移动性控制（归 amf 终结 N1/N2），不承担策略决策（归 pcf 制定 PCC/Session 规则）；定位为会话编排者与用户面规则下发者，不是数据面或策略制定者。

**原设计意图**（意图域）：
无历史方案输入（参考自 Pando V1.0版本架构设计说明书 §-）。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | PDU 会话生命周期管理 | 维护 PDU 会话从建立到释放的状态机，是会话控制锚点 | 无历史方案输入 |
| CAP-002 | GSM NAS 处理 | 终结 N1 SM 子层协议，解耦 UE 会话信令与核心网编排 | 无历史方案输入 |
| CAP-003 | UPF 选择 | 按 DNN/S-NSSAI/DNAI 选择用户面节点，决定数据路径起点 | 无历史方案输入 |
| CAP-004 | PFCP 会话控制 | 通过 N4 接口下发 PDR/FAR/QER/URR，是用户面规则的唯一来源 | 无历史方案输入 |
| CAP-005 | UE IP 地址分配 | 按 DNN 池为 UE 分配/回收 IPv4，是会话可达性基础 | 无历史方案输入 |
| CAP-006 | QoS Flow 与 PCC 规则应用 | 将 PCF 策略翻译为 QoS Flow 与 NAS QoS Rule，落地策略到用户面 | 无历史方案输入 |
| CAP-007 | 用户面拓扑管理 | 维护 UPF/Link 拓扑与默认数据路径，支撑路径计算 | 无历史方案输入 |
| CAP-008 | ULCL 分支路径 | 控制边缘 UPF 上行分流，支持边缘计算流量本地化 | 无历史方案输入 |
| CAP-009 | 计费触发协同 | 协同 CHF 完成在线/离线计费的额度请求与上报 | 无历史方案输入 |
| CAP-010 | 策略关联协同 | 与 PCF 建立 SM Policy Association，驱动会话策略落地 | 无历史方案输入 |
| CAP-011 | BSF 绑定管理 | 注册/解绑 UE-PCF 绑定关系，是同 UE 多会话复用 PCF 的前提 | 无历史方案输入 |
| CAP-012 | 会话事件暴露 | 向订阅方推送会话级事件（如 UpPathChg），解耦事件消费 | 无历史方案输入 |
| CAP-013 | NRF 注册与发现 | 声明本 NF 可达性，发现协作 NF | 无历史方案输入 |
| CAP-014 | OAM 查询 | 为运维提供单会话与用户面拓扑可见性 | 无历史方案输入 |
| CAP-015 | UPI 拓扑动态管理 | 运维侧动态增删 UP Node/Link，支撑非中断拓扑演进 | 无历史方案输入 |
| CAP-016 | 5GSM 重传定时 | 通过 T3591/T3592 保障 NAS 信令可靠投递 | 无历史方案输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | SMContext 查询常数级；PDU 会话操作单会话串行避免并发损坏；SBI 与 PFCP 互不阻塞；DataPath 预生成以避免运行时图搜索 | 无历史方案输入 |
| 可靠性 | PFCP 关联失败可重试 + 失联告警；UPF 失联回收该 UPF 上全部会话资源；NAS 信令具备重传定时（T3591/T3592）；优雅终止序列：先释放 PFCP 再注销 NRF 再停 SBI | 无历史方案输入 |
| 可用性 | NRF/PCF/UPF 部分不可达不阻断本元素启动，关联失败异步重试；PFCP Report 对已释放会话兜底返回 Cause=SessionContextNotFound 不 panic | 无历史方案输入 |
| 可扩展性 | 控制面与用户面解耦（CUPS）；每 UPF 独立 goroutine 关联可水平扩展；SBI 处理链与 PFCP 派发互独立 | 无历史方案输入 |
| 安全性 | 对外 SBI 强制 mTLS；NRF OAuth2 鉴权；callback 路由按资源域独立鉴权（npcf-smpolicycontrol / nsmf-callback / nsmf-oam 三域隔离）；PFCP 强制 IE 防御性校验；入参 SUPI / S-NSSAI / ServingNetwork 必填校验 | 无历史方案输入 |
| 可测试性 | 三层 SBI 调用链解耦（api → processor → consumer）支撑 mock；App 接口抽象与 gomock 产物入库；UT 通过 gomock + h2non/gock 隔离所有外部 NF 与 UPF | 无历史方案输入 |
| 可观测性 | 分模块日志（PduSess/Pfcp/Ctx/SBI/Init/Consumer/Producer/Charging 等 7 级运行时可调）+ 独立 Prometheus 指标端口（可选独立 TLS）+ OpenTelemetry 分布式追踪（间接依赖） | 无历史方案输入 |

历史方案未覆盖的行在"原目标值 + 策略原因"列已标注「无历史方案输入」。

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | CreateSMContext | SBI (Nsmf_PDUSession) | AMF 触发 PDU 会话建立入口 |
| IF-002 | UpdateSMContext | SBI (Nsmf_PDUSession) | PDU 会话修改 / 激活 / 去激活 / 切换入口 |
| IF-003 | ReleaseSMContext | SBI (Nsmf_PDUSession) | PDU 会话释放入口 |
| IF-004 | RetrieveSMContext | SBI (Nsmf_PDUSession) | SM 上下文检索（占位，未实现 501） |
| IF-005 | SendMoData | SBI (Nsmf_PDUSession) | MO 数据发送（占位，未实现 501） |
| IF-006 | PDUSession-H-SMF 族 | SBI (Nsmf_PDUSession) | H-SMF / V-SMF 跨 SMF 会话族（占位族，未实现 501） |
| IF-007 | EventExposure 订阅族 | SBI (Nsmf_EventExposure) | 会话事件订阅创建 / 查询 / 替换 / 删除（占位族） |
| IF-008 | SmPolicyUpdateNotify | SBI (Nsmf_Callback, 独立 OAuth 资源域 npcf-smpolicycontrol) | 接收 PCF 推送的 SM 策略更新 |
| IF-009 | SmPolicyControlTerminate | SBI (Nsmf_Callback) | 接收 PCF 推送的策略终止（占位，未实现 501） |
| IF-010 | ChargingNotification | SBI (Nsmf_Callback, 独立 callback 鉴权域) | 接收 CHF 推送的计费通知 |
| IF-011 | GetUEPDUSessionInfo | SBI (Nsmf_OAM) | 运维查询单会话信息 |
| IF-012 | GetSMFUserPlaneInfo | SBI (Nsmf_OAM) | 运维查询用户面拓扑 |
| IF-013 | UPI-GetUpNodesLinks | REST (Nsmf_UPI, 私有) | 查询用户面拓扑配置 |
| IF-014 | UPI-PostUpNodesLinks | REST (Nsmf_UPI, 私有) | 替换用户面拓扑并触发 PFCP 关联 |
| IF-015 | UPI-DeleteUpNodeLink | REST (Nsmf_UPI, 私有) | 删除 UP Node（ULCL 禁用时） |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/smf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与发现，是所有跨 NF 调用的前置 |
| amf | 下行 NAS/N2 SM 信息投递与 SM 上下文状态通知 |
| pcf | SM Policy Association 与 PCC / Session 规则获取 |
| chf | 在线 / 离线计费的额度请求与用量上报 |
| udm | 订阅数据获取与 SMF 注册（UECM） |
| bsf | UE-PCF 绑定的注册与查询，PCF 选择的权威源 |
| upf | 用户面会话规则下发（PFCP / N4 协议接口，非 SBI） |
| smf（自/他实例） | H-SMF / V-SMF 跨 SMF 会话族（占位） |
| prometheus | 指标 scrape（外部监控系统，非 NF 元素） |

**详细依赖清单与调用时机**：见 `repos/smf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| SM Context | 维护单个 PDU 会话的全量状态（NAS / QoS / UE IP / UPF 路径），是会话控制核心状态 | 内存，三路索引（ref / canonicalRef / seid），重启丢失 |
| UPF 节点与拓扑 | 维护 UPF 实例、链路、默认数据路径与 ULCL 分支，是 UPF 选择与路径计算的输入 | 内存 + YAML 配置（uerouting） |
| UE IP 池 | 按 DNN 分配 / 回收 UE IPv4 地址，是会话可达性基础 | 内存，按 DNN 配置静态切分 |
| QoS Flow 与 PCC 规则 | 维护 QFI / Flow 描述 / PCC 规则与会话的绑定关系，落地策略到用户面 | 内存，会话生命周期内有效 |
| PFCP 会话 SEID 映射 | 维护 SMF 侧与 UPF 侧 SEID 的双向映射，是 N4 消息路由的基础 | 内存（seidSMContextMap） |
| ID 复用池 | TEID / QFI / QoS Rule ID / Packet Filter ID / URR ID / PDR ID 等范围内复用 | 内存 |
| SMF 全局上下文 | NF 实例信息、SnssaiInfo、PFCP 配置、OAuth2 开关等运行配置 | 内存 + YAML 配置 |

## 8. 部署与运行

> 架构层部署形态：进程 / 容器 / 副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立进程（Go 二进制），可容器化；free5gc 顶层统一镜像构建（仓内无独立 Dockerfile） | 无历史方案输入 |
| 副本策略 | 单副本部署；NF 实例 ID 支持环境变量 `SMF_NF_INSTANCE_ID` 覆盖以适配 K8s StatefulSet 固定身份 | 无历史方案输入 |
| 启动依赖 | NRF 可达（不可达降级，异步重试）；至少 1 个 UPF 可关联（关联失败异步重试 + 告警）；mTLS 证书与 NRF 证书就绪；`smfcfg.yaml` 与可选 `uerouting.yaml` 就绪 | 无历史方案输入 |
| 可观测出口 | Prometheus 指标（独立 metrics server 端口，可选独立 TLS）+ logrus 模块分级日志（7 级运行时可调）+ OpenTelemetry 分布式追踪（间接依赖） | 无历史方案输入 |
| 终止行为 | 优雅终止序列：PFCP terminate（通知所有 UPF 释放）→ NRF Deregister → SBI Stop → Metrics Stop | 无历史方案输入 |
| 容量规格 | 无显式硬编码 PDU 会话并发上限；TEID 32 位、SEID 64 位、QFI 2~63（62 个 Flow/会话）；UE IP 池按 DNN 配置上限决定会话上限 | 无历史方案输入 |

历史方案未覆盖的维度在"原规划"列已标注「无历史方案输入」。

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| 无历史方案输入 | — |

`intent_source_count` 为 0：候选 `knowledge/历史方案/架构方案/Pando V1.0版本架构设计说明书.md` 内容为空、不含 smf 章节，全文意图域章节均已标注「无历史方案输入」降级。
