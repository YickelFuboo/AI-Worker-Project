# 5GC Network Functions 详解

> 14 个网元的功能、对外接口、关键流程、与 free5GC 代码的对应位置。
> 规范条款：TS 23.501 §6.2（NF 描述）、TS 29.5xx 系列（SBI Stage 3）。
> 代码位置以 free5GC v3.4.x 为参照，本仓库 `repos/<nf>/` 即对应镜像。

## AMF — Access and Mobility Management Function

**职责**（TS 23.501 §6.2.3）：
- 终结 N1（NAS 信令）、N2（NGAP）。
- 注册/连接/可达性/移动性管理。
- 鉴权流程的发起方与 NAS 安全上下文持有者。
- UE 与 SMF 间 NAS 5GSM 消息的中转。
- 切换时跨 AMF 上下文转移（N14）。
- 与 PCF 建立 AM Policy 关联（N15）。
- 与 NSSF 协商 Allowed NSSAI（N22）。

**SBI 服务**（TS 29.518）：
- `Namf_Communication`：N1/N2 消息传递、UE 上下文通知。
- `Namf_EventExposure`：UE 事件订阅（注册态、可达性、位置）。
- `Namf_MT`：Mobile Terminated 服务。
- `Namf_Location`：位置服务。

**关键流程触发点**：
- NAS 5GMM 消息入口：`internal/nas/nasmessage` 解码。
- NGAP 入口：`internal/sbi/consumer`、`internal/ngap`。
- AMF 维护的 UE Context：`internal/context`。

**本仓库对应**：`repos/amf/`，~42.6K 行 Go，是规模最大的 NF。包含 NAS 协议处理、NGAP 处理、fuzz 测试数据（`internal/nas/testdata/fuzz/`）。

## SMF — Session Management Function

**职责**（TS 23.501 §6.2.2）：
- 终结 N4（PFCP），管理 UPF。
- PDU 会话建立/修改/释放（含 IP/Prefix 分配）。
- UPF 选择（基于 DNN、S-NSSAI、UPF 的容量与拓扑）。
- 与 PCF 建立 SM Policy 关联（N7）。
- 与 CHF 建立计费会话（N40）。
- SSR (Session Management Subscription Data) 从 UDM 拉取。
- 触发 UPF 计费报告与 Usage Reporting。

**SBI 服务**（TS 29.502）：
- `Nsmf_PDUSession`：Create/Update/Release SM Context、上下文同步。
- `Nsmf_EventExposure`：会话事件订阅。
- `Nsmf_NIDD`：Non-IP Data Delivery。

**关键交互**：
- 接收 AMF `Nsmf_PDUSession_CreateSMContext` 后，启动 PDU 会话建立流程。
- 通过 N4 (PFCP) 在 UPF 上建立 PFCP Session：PDR/FAR/QER/URR/BAR。
- 通过 N7 (Npcf_SMPolicyControl) 与 PCF 协商 QoS / 计费键。
- 通过 N40 (Nchf) 上报 Usage Report。

**本仓库对应**：`repos/smf/`，~23.4K 行。代码主要在 `internal/pfcp`（PFCP 编解码与消息构造）、`internal/sbi`（HTTP2 服务端）、`internal/context`（SM Context）。

## UPF — User Plane Function

**职责**（TS 23.501 §6.2.3）：
- 与 (R)AN 间 N3 用户面（GTP-U）。
- 与 DN 间 N6（IP/以太网）。
- 与其它 UPF 间 N9（GTP-U）。
- N4 终结（PFCP Agent）。
- QoS 执行（流分类、限速、丢弃）。
- Usage 上报（流量/时长）。
- ULCL（Uplink Classifier）：按 S-NSSAI/DNN/流量过滤器分流到不同 PDU 会话。
- Branching Point：多播/HR-LBO。

**协议接口**：
- N3/N9：GTP-U（TS 29.281）。
- N4：PFCP（TS 29.244）。
- N6：IP/以太网（取决于 DN）。

**free5GC go-upf 实现**（`repos/go-upf/`，~8.4K 行）：
- 用 Go + Linux 内核 `nftables` / `xprog` 实现快速路径。
- PFCP Agent 在 `internal/pfcp`，处理 PFCP Association/Session Modification。
- 隧道封装在 `internal/forwarder`。
- 多 UPF + ULCL + SSC mode 1 + 多 S-NSSAI/DNN 全部支持。

## UDM — Unified Data Management

**职责**（TS 23.501 §6.2.7）：
- 生成 5G 鉴权向量（5G-AKA / EAP-AKA'）。
- SUPI 隐藏机制（SUCI 解密）。
- 用户签约数据管理（接入/会话/SMS/策略）。
- UE Context 管理（当前服务 AMF/SMF）。
- ECID / Routing Indicator 数据。

**SBI 服务**（TS 29.503）：
- `Nudm_UECM`：UE Context Management（注册当前服务 NF）。
- `Nudm_SDM`：Subscriber Data Management（签约数据查询）。
- `Nudm_AU`：Authentication（生成鉴权向量）。
- `Nudm_PP`：Parameter Provision（外部参数提供）。
- `Nudm_NIDDAU`：NIDD Authorization。

**存储后端**：UDR（Nudr）。UDM 自身无状态，是 UDR 的业务逻辑封装。

**本仓库对应**：`repos/udm/`，~8.4K 行。代码主要在 `internal/sbi/producer` 与 `internal/subscription`。

## UDR — Unified Data Repository

**职责**（TS 23.501 §6.2.8）：
- 存储签约数据、策略数据、应用数据、计费数据。
- 对 UDM/PCF/NEF 暴露统一 CRUD。

**SBI 服务**（TS 29.504）：
- `Nudr_SubscriberDataManagement`
- `Nudr_PolicyData`
- `Nudr_ApplicationData`
- `Nudr_ExposureData`
- `Nudr_DataRepository`

**存储后端**：MongoDB（free5GC 默认）。

**本仓库对应**：`repos/udr/`，~9.2K 行。每条记录对应一个集合（subscriptionData / policyData / ...）。

## AUSF — Authentication Server Function

**职责**（TS 23.501 §6.2.6）：
- 终结 AMF 的鉴权请求，向 UDM 请求鉴权向量。
- 5G-AKA：确认 UE 的 MAC；EAP-AKA'：作为 EAP Server。
- 鉴权结果返回 AMF，并可用作 SBI 调用的 authorization token。

**SBI 服务**（TS 29.509）：
- `Nausf_UEAuthentication`：鉴权流程。
- `Nausf_SoRProtection`：Steering of Roaming 信息保护。
- `Nausf_UPUProtection`：UE Parameter Update 保护。

**本仓库对应**：`repos/ausf/`，~3.3K 行，最小的 NF 之一。

## PCF — Policy Control Function

**职责**（TS 23.501 §6.2.9）：
- 统一策略决策（AM Policy / SM Policy / UE Policy）。
- 与 AMF 建立 AM Policy 关联（N15）。
- 与 SMF 建立 SM Policy 关联（N7）。
- 从 UDR 取策略数据，从 BSF 做 PCC Session Binding。
- 提供 Charging Key、QoS 决策、URR 触发条件。

**SBI 服务**（TS 29.507 / 29.512 / 29.525）：
- `Npcf_AMPolicyControl`
- `Npcf_SMPolicyControl`
- `Npcf_PolicyAuthorization`（AF 触发）
- `Npcf_UEPolicyControl`
- `Npcf_BDTPolicyControl`

**本仓库对应**：`repos/pcf/`，~9.5K 行。

## NRF — Network Repository Function

**职责**（TS 23.501 §6.2.5）：
- NF 注册/去注册/心跳/更新。
- NF Discovery（按 NF type、PLMN、Slice、DNN、TAI 等过滤）。
- NF Status Notification（订阅 NF 状态变化）。
- OAuth2 授权服务器（如启用 SBI 安全）。

**SBI 服务**（TS 29.510）：
- `Nnrf_NFManagement`：注册、更新、去注册、心跳、订阅。
- `Nnrf_NFDiscovery`：发现其它 NF。
- `Nnrf_AccessToken`：OAuth2 token service。

**心跳模型**：NF 每 30s 调 `Nnrf_NFManagement_NFUpdate` 续约；过期 NRF 标记为不可用。

**本仓库对应**：`repos/nrf/`，~6.4K 行。维护内存 NF Registry，可选 MongoDB 持久化。

## NSSF — Network Slice Selection Function

**职责**（TS 23.501 §6.2.4）：
- 为 UE 选择 Allowed NSSAI 与服务 AMF Set（基于 Configured/Requested NSSAI、TAI、漫游协议）。
- 返回候选 AMF Set、Allowed/NSSAI、Configured NSSAI（for Serving PLMN）。
- 与 UDR 同步 NSSF 数据（NSI Information、Slice info）。

**SBI 服务**（TS 29.531）：
- `Nnssf_NSSelection`：切片选择。
- `Nnssf_NSSAIAvailability`：NSI 可用性更新与查询。

**本仓库对应**：`repos/nssf/`，~3.8K 行。

## NEF — Network Exposure Function

**职责**（TS 23.501 §6.2.10）：
- 对外（AF、第三方应用）暴露 5GC 能力，做鉴权与转译。
- 内部调用 UDR/PCF/UDM/AMF/SMF 等。
- 安全隐藏外部敏感信息（如 GPSI 映射、外部 ID ↔ SUPI）。
- AF 对流量路由的影响（Traffic Influence）。
- Capability Exposure Parameter Provision。

**SBI 服务**（TS 29.591 / 29.522）：
- `Nnef_EventExposure`
- `Nnef_PFDManagement`
- `Nnef_ParameterProvision`
- `Nnef_Trigger`
- `Nnef_TrafficInfluence`

**本仓库对应**：`repos/nef/`，~8.1K 行。

## CHF — Charging Function

**职责**（TS 32.240 / 32.255）：
- 在线计费：信用控制（Credit Control Request/Answer）、配额管理。
- 离线计费：CDR 生成。
- 包含 ABMF (Account Balance Management Function) 与 RF (Rating Function)。
- CGF (Charging Gateway Function) 接到 Billing Domain。
- Converged Charging：与 SMF 经 N40 交互，做基于流的计费 (FBC)。

**SBI 服务**（TS 29.594）：
- `Nchf_ConvergedCharging`：ChargingDataRequest/Response/Notify。

**关键 IE**：
- Rating Group、Charging Key、Service Identifier：流计费标识。
- Quota：配额（volume/time）。
- MeasurementMethod：volume/time/event。

**本仓库对应**：`repos/chf/`，~10.9K 行（文件最多，272 个 Go 文件）。子目录 `ccs_diameter`（Diameter 兼容）、`cdr`（CDR 编解码）。

## BSF — Binding Support Function

**职责**（TS 23.501 §6.2.10A）：
- PCC Session Binding：把 AF 触发的会话（IP/Prefix/MAC）绑定到 SUPI + DNN + S-NSSAI + IPv4/IPv6。
- PCF 通过 BSF 查询：给定 UE IP，找到对应的 PCF ID。
- 支持 Binding 创建/更新/释放/查询。

**SBI 服务**（TS 29.521）：
- `Nbsf_Management`：PCF Binding CRUD。

**触发场景**：AF → PCF 直接调用要求 UE IP；若 AF 不知道 PCF，先问 BSF。

**本仓库对应**：`repos/bsf/`，~3.8K 行。附 `test-bsf-implementation.sh`（790 行）做端到端验证。

## N3IWF — Non-3GPP InterWorking Function

**职责**（TS 23.501 §6.2.11）：
- 不可信非 3GPP 接入（如公共 Wi-Fi）的网关。
- 与 UE 之间建立 IKEv2/IPSec 隧道，传输 N1 NAS。
- 在 5GC 侧伪装成 (R)AN，向 AMF 发 NGAP。
- 用户面经 IPSec → N3 GTP-U 转换。

**协议**：
- UE ↔ N3IWF：IKEv2 (RFC 7296) + IPSec ESP。
- N3IWF ↔ AMF：NGAP (N2) + GTP-U (N3)。

**本仓库对应**：`repos/n3iwf/`，~14.4K 行。配套 `N3IWUE`（客户端模拟器）见 free5GC 主仓 `test/`。

## TNGF — Trusted Non-3GPP Gateway Function

**职责**（TS 23.501 §6.2.12）：
- 可信非 3GPP 接入网关。
- 与 UE 间同样用 IKEv2/IPSec，但接入网本身可信。
- 功能上类似 N3IWF 但信任域不同。

**本仓库对应**：`repos/tngf/`，~16.3K 行。配套 `TNGFUE` 模拟器。

## NF 间交互对照速查

| 调用方 | 被调方 | 服务 | 场景 |
|---|---|---|---|
| AMF | SMF | Nsmf_PDUSession_CreateSMContext | PDU 会话建立 |
| AMF | UDM | Nudm_UECM_Registration | 注册当前 AMF |
| AMF | AUSF | Nausf_UEAuthentication_Authenticate | 鉴权 |
| AMF | PCF | Npcf_AMPolicyControl_Create | AM 策略关联 |
| AMF | NSSF | Nnssf_NSSelection_Get | 切片选择 |
| SMF | UDM | Nudm_SDM_Get | 取 DNN 签约 |
| SMF | PCF | Npcf_SMPolicyControl_Create | SM 策略关联 |
| SMF | CHF | Nchf_ConvergedCharging | 计费会话 |
| SMF | UPF | PFCP (N4) | Session 建立/修改 |
| PCF | BSF | Nbsf_Management_Register | PCC Binding |
| PCF | UDR | Nudr_PolicyData | 取策略数据 |
| NEF | UDR | Nudr_ApplicationData | 应用数据暴露 |
| 任意 NF | NRF | Nnrf_NFDiscovery | NF 发现 |
| 任意 NF | NRF | Nnrf_NFManagement_Register | NF 注册 |

## NF 代码规模对照（来自本仓库统计）

| NF | Go 文件数 | 代码行 |
|---|---:|---:|
| amf | 89 | 42,609 |
| smf | 91 | 23,375 |
| tngf | 44 | 16,261 |
| n3iwf | 44 | 14,412 |
| chf | 272 | 10,931 |
| pcf | 37 | 9,466 |
| udr | 69 | 9,191 |
| go-upf | 34 | 8,415 |
| udm | 42 | 8,400 |
| nef | 35 | 8,130 |
| nrf | 29 | 6,405 |
| nssf | 26 | 3,836 |
| bsf | 22 | 3,783 |
| ausf | 21 | 3,301 |
| **合计** | **855** | **168,515** |

> AMF 与 SMF 因承载 NAS/NGAP/PFCP 多协议编解码，规模显著高于其它 NF。
> CHF 文件数最多，因为 CDR/AVP/CC-Request 等 IE 拆得极细。
