---
element_id: ausf
element_name: ausf
element_type: service
repo_path: repos/ausf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：ausf

> 本文件是**架构层抽象**，描述 ausf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/ausf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
ausf 是 3GPP 5G 核心网控制面的鉴权服务器网元（Authentication Server Function），承担 UE 主鉴权的密钥派生与结果裁决职责。它对 AMF 终结 `Nausf_UEAuthentication` 服务，按 UDM 下发的 AuthType 分发到 5G-AKA 或 EAP-AKA' 算法子流程，向下游 UDM 调用 `Nudm_UEAuthentication` 获取鉴权向量并上报鉴权事件。在架构上，ausf 是 AMF 与 UDM 之间的鉴权算法编排者：将订阅数据（UDM）与服务网络鉴权请求（AMF）解耦，是 NAS 安全上下文建立的密钥源（Kausf/Kseaf）。

| 项目 | 内容 |
|------|------|
| 元素ID | ausf |
| 元素名 | ausf |
| 元素类型 | service（对外提供 Nausf SBI，独立部署 NF） |
| 所属代码仓 | repos/ausf |
| 置信度 | 高 |

## 2. 职责描述
ausf 承担 5G 核心网主鉴权的算法终结与裁决职责：按 3GPP TS 33.501 完成 5G-AKA / EAP-AKA' 的密钥派生（HXRES*/Kseaf/Kausf/MSK/EMSK），裁决 UE 上送的 RES* 或 EAP 响应，并将鉴权结果上报 UDM。它不持有长期订阅数据（归 udm）、不承担接入与移动性控制（归 amf）、不直接与 UE/RAN 通信，是位于鉴权链路中枢的无状态算法服务（运行态仅维护短生命周期的 AusfUeContext）。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | UE 主鉴权编排 | 接受 AMF 鉴权请求，按 UDM 返回的 AuthType 分发到 5G-AKA 或 EAP-AKA' 子流程，是鉴权算法路由入口 |
| CAP-002 | 5G-AKA 算法执行 | 派生 HXRES* 与 Kseaf，裁决 AMF 上送的 RES*，建立 NAS 安全上下文的密钥源 |
| CAP-003 | EAP-AKA' 算法执行 | 通过 PRF' 派生 K_encr/K_aut/K_re/MSK/EMSK，构造与裁决 EAP 报文，支撑非 3GPP 接入鉴权 |
| CAP-004 | AUTS 重同步处理 | 处理 SQN 失步场景，向 UDM 转发 AUTS 重新拉取鉴权向量，并限制重试次数防御重放 |
| CAP-005 | 鉴权结果上报 | 鉴权成功/失败均上报 UDM AuthEvent，是订阅数据侧的鉴权审计入口 |
| CAP-006 | 服务网络授权校验 | 按 PLMN 白名单正则校验 ServingNetworkName，拒绝非授权服务网络 |
| CAP-007 | SUPI/SUCI 入参校验 | 拒绝非法 UE 标识，前置防御非法请求进入算法链 |
| CAP-008 | NRF 注册与发现 | 启动期注册本 NF 实例，鉴权时按服务名发现 UDM 实例，是跨 NF 协作的前置 |
| CAP-009 | AusfUe 上下文管理 | 维护按 SUPI/SUCI 索引的短生命周期鉴权上下文，跨 5G-AKA 两次 RTT / EAP 多次交互 |
| CAP-010 | OAuth2 接入控制 | 由 NRF 下发开关，对入站 SBI 调用做 Bearer Token 校验 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | 鉴权请求以 goroutine-per-request 并发；UE 上下文池采用无锁映射降低竞争；下游 UDM/NRF 客户端按 URL 缓存复用，避免每请求重建 HTTP/2 连接 |
| 可靠性 | 启动期 NRF 注册无限期退避重试（NRF 未就绪不接客户）；终止时主动注销 NRF；UDM 调用失败兜底为 500 UPSTREAM_SERVER_ERROR；HTTP server panic 由 recover 兜底并触发 Terminate |
| 可用性 | 鉴权服务无状态可重启；活动鉴权上下文丢失会导致正在进行的鉴权失败但不影响后续新请求 |
| 可扩展性 | SBI 处理与 Metrics 端口物理隔离；无共享磁盘状态，理论上可水平扩展（需配合 NRF NFInstance 发现） |
| 安全性 | 对外 SBI 强制 mTLS；NRF 可下发 OAuth2 开关启用 Bearer Token 校验；ServingNetworkName 强制 PLMN 白名单正则；EAP-AKA' 连续 2 次同步失败拒绝以防重放；AT_MAC 完整性校验 |
| 隐私 | SUPI/密钥（K_aut/Kausf/Kseaf）仅内存驻留无落盘；EAP-AKA' Identity 前缀策略可配置以符合 TS 33.501 v15.9.0+ |
| 可测试性 | App 接口抽象支持 mock；HTTP 出站调用支持 gock 拦截；processor/consumer 分层便于单元隔离 |
| 可观测性 | 12 个分类 logger（Main/Init/CFG/CTX/SBI/GIN/Consumer/UeAuth/5gAka/Eap/Util）；独立 Prometheus Metrics 端口暴露入站/出站 SBI 指标；运行时日志级别可调 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | UeAuthenticationsPost | SBI (Nausf_UEAuthentication) | UE 鉴权发起入口，AMF 提交 SUPI/SUCI 触发鉴权 |
| IF-002 | UeAuthentications5gAkaConfirmation | SBI (Nausf_UEAuthentication) | 5G-AKA 鉴权确认，AMF 上送 RES* 由 AUSF 裁决 |
| IF-003 | EapAuthMethod | SBI (Nausf_UEAuthentication) | EAP-AKA' 会话推进，承载多轮 EAP 交互 |
| IF-004 | UeAuthenticationsDeregister | SBI (Nausf_UEAuthentication) | 鉴权去注册（路由占位，未实现） |
| IF-005 | ProseAuthentications | SBI (Nausf_UEAuthentication) | ProSe 鉴权（路由占位，未实现） |
| IF-006 | RgAuthentications | SBI (Nausf_UEAuthentication) | RG（Residential Gateway）鉴权（路由占位，未实现） |
| IF-007 | SupiUeSorPost | SBI (Nausf_SoRProtection) | SoR 保护数据生成（路由占位，未实现） |
| IF-008 | SupiUeUpuPost | SBI (Nausf_UPUProtection) | UPU 保护数据生成（路由占位，未实现） |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/ausf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册/注销与 UDM 服务发现，是所有跨 NF 调用与本元素启动的前置 |
| udm | 获取鉴权向量（GenerateAuthData）与上报鉴权事件（ConfirmAuth），是订阅数据侧锚点 |
| amf | 入站调用方（被调用方向），承载 UE 鉴权请求 |
| prometheus | 指标 scrape（外部监控系统） |
| OpenTelemetry | 分布式追踪（间接依赖，外部系统） |

**详细依赖清单与调用时机**：见 `repos/ausf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| AusfUeContext | 维护单 UE 短生命周期鉴权上下文（密钥/RAND/AUTN/EAP 子状态/Resynced 标志），跨 5G-AKA 两次 RTT 或 EAP 多轮 | 内存（sync.Map），非持久化 |
| UePool（按 SUPI 索引） | AusfUeContext 全局池，鉴权裁决与去重的根索引 | 内存 |
| suciSupiMap（SUCI→SUPI 映射） | EAP/5G-AKA 跨步骤通过 SUCI 反查上下文 | 内存 |
| AUSFContext 全局上下文 | 维护 NF 实例信息、OAuth2 开关、Serving Network 正则、NRF 客户端 | 内存 + YAML 配置 |
| 鉴权密钥（K_aut/Kausf/Kseaf/MSK/EMSK） | 短期会话密钥，鉴权结束后随上下文释放 | 内存 hex 字符串，非落盘 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），由 free5gc 顶层统一容器化构建
- **副本策略**：单副本部署；多副本需配合 NRF NFInstance 负载均衡（多实例需共用 NfInstanceId 注入策略）
- **启动依赖**：NRF 可达（启动期阻塞 2s 退避重试至成功）、UDM 可达（鉴权时按需发现）、mTLS 证书就绪、YAML 配置（Info.Version 精确匹配 1.0.3）就绪
- **可观测出口**：Prometheus 指标（独立端口，默认 9091，可独立 TLS）+ logrus 12 类分模块日志（7 级可配）+ OpenTelemetry 分布式追踪（间接依赖）
- **终止行为**：计划性终止时停止 SBI server（2 秒优雅 shutdown 超时），向 NRF 注销 NF 实例，再退出进程
