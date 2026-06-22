---
element_id: nssf
element_name: nssf
element_type: service
repo_path: repos/nssf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：nssf

> 本文件是**架构层抽象**，描述 nssf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/nssf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
nssf 是 3GPP 5G 核心网控制面的网络切片选择网元（Network Slice Selection Function），承担"切片选择决策点"角色。它对接入侧 AMF 提供两类 SBI 服务：在 UE 注册与 PDU 会话建立流程中输出 Allowed/Configured NSSAI 与目标 AMF Set / NRF AMF Set；在 AMF 侧汇聚切片可用性信息（按 PLMN+TA 维度上报与订阅）。在架构上，nssf 把"切片→AMF/NRF"的路由策略与"切片可用性"的运维事实从 AMF 中抽离，是切片维度的策略中心，**不持有 UE 状态、不持有会话状态、不直连 UE/RAN**。

| 项目 | 内容 |
|------|------|
| 元素ID | nssf |
| 元素名 | nssf |
| 元素类型 | service（对外提供 Nnssf SBI，独立部署 NF） |
| 所属代码仓 | repos/nssf |
| 置信度 | 高 |

## 2. 职责描述
nssf 承担 5G 核心网的切片选择控制面职责：基于静态切片配置（PLMN/TA/HPLMN 映射、NSI/AMF Set 拓扑）与动态切片可用性（AMF 上报的 TA 内 S-NSSAI 支持情况），为 AMF 输出注册与 PDU 会话流程的切片决策结果；同时为运维侧提供切片可用性变更的订阅通道。它不承担 UE 鉴权（归 ausf）、不承担订阅数据存储（归 udm）、不承担 NF 注册中心职责（归 nrf），是切片维度的查表/决策者而非会话编排者。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | 注册流程切片选择 | 在 UE 注册阶段为 AMF 输出 Allowed/Configured NSSAI 与候选 AMF/AMF Set，是接入选片决策入口 |
| CAP-002 | PDU 会话切片选择 | 在 PDU 会话建立时校验 S-NSSAI 可达性并指派 NSI，路由会话到正确切片 |
| CAP-003 | HPLMN 漫游映射 | 在漫游场景下将 Subscribed/Requested S-NSSAI 映射到 Serving PLMN，是跨 PLMN 切片互通的策略点 |
| CAP-004 | 切片可用性管理 | 接收 AMF 全量/增量上报某 TA 内支持的 S-NSSAI，作为切片可用性运维事实 |
| CAP-005 | 切片可用性订阅 | 向订阅方推送 PLMN+TA 范围内的切片可用性变更，解耦运维事件消费 |
| CAP-006 | AMF/AmfSet 选择 | 基于切片可用性矩阵为 UE 选出可服务的 AMF Set 与候选 AMF |
| CAP-007 | NRF 注册与发现协同 | 启动时声明本 NF 可达性，关闭时优雅注销 |
| CAP-008 | 服务消费者鉴权 | 限定切片选择接口仅对 AMF/NSSF 开放，是切片决策入口的访问控制 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | 切片决策走全内存查表，无外部 IO；SBI 入站与 NRF 出站互不阻塞 |
| 可靠性 | 启动期阻塞重试 NRF 注册直至成功或 ctx 取消；停机优雅注销 NRF 并 2 秒内关闭 SBI；panic 路径强制注销避免 NRF 残留 |
| 可用性 | NSSF 不持久化，崩溃后依赖 AMF 重新 PUT 重建可用性状态；运行时配置写入受 RWMutex 保护避免读写撕裂 |
| 可扩展性 | SBI 路由按 ServiceNameList 按需装配；NSSelection / NSSAIAvailability 两服务相互独立 |
| 安全性 | 对外 SBI 强制 HTTPS（HTTP/2+TLS）；OAuth2 启用由 NRF 注册响应动态决定；切片选择接口业务白名单仅放行 AMF/NSSF |
| 可测试性 | NssfApp 接口隔离实现，mockgen 已生成 MockNssfApp；UT 不依赖真实 NRF 与磁盘 |
| 可观测性 | 11 类分模块 logrus 日志（级别可热改） + 可选 Prometheus 指标独立端口 + SBI 入站/NRF 出站埋点 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | NSSelectionGet | SBI (Nnssf_NSSelection) | UE 注册/PDU 会话流程的切片选择查询入口 |
| IF-002 | NSSAIAvailabilityPut | SBI (Nnssf_NSSAIAvailability) | AMF 全量上报本 NF 在某 TA 支持的 S-NSSAI |
| IF-003 | NSSAIAvailabilityPatch | SBI (Nnssf_NSSAIAvailability) | AMF 增量更新切片可用性（RFC6902 JSON Patch） |
| IF-004 | NSSAIAvailabilityDelete | SBI (Nnssf_NSSAIAvailability) | 删除 AMF 上报的切片可用性数据 |
| IF-005 | NSSAIAvailabilitySubscribe | SBI (Nnssf_NSSAIAvailability) | 订阅 PLMN+TA 范围内的切片可用性变更 |
| IF-006 | NSSAIAvailabilityUnsubscribe | SBI (Nnssf_NSSAIAvailability) | 取消切片可用性订阅 |
| IF-007 | HealthCheck | SBI REST | 健康检查（服务前缀根路径） |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/nssf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与注销，是本元素加入服务网格与优雅退出的必经路径 |
| amf | 反向依赖：AMF 是本元素 SBI 接口的唯一授权调用方与切片可用性上报方（架构上 AMF→NSSF 调用关系；本元素声明对 AMF 的语义依赖以支持双向校验） |
| prometheus | 指标 scrape（外部监控系统，可选） |

**详细依赖清单与调用时机**：见 `repos/nssf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| 切片支持配置（PLMN/TA/Nssai） | 描述 PLMN 与 TA 内支持/受限的 S-NSSAI，是切片决策的静态事实 | YAML 配置，启动加载到内存 |
| 切片漫游映射 | HPLMN ↔ Serving PLMN 的 S-NSSAI 映射表，是漫游场景的策略事实 | YAML 配置，内存 |
| NSI 拓扑 | S-NSSAI → NSI 列表，是 PDU 会话路径的实例索引 | YAML 配置，内存 |
| AMF/AmfSet 拓扑 | AMF Set 与下挂 AMF + NrfAmfSet 关系，是 AMF 选择的事实基础 | YAML 配置，内存 |
| 切片可用性数据 | AMF 运行时上报的 TA 内 S-NSSAI 支持情况，是动态决策事实 | 内存（运行时修改 Config），非持久化，重启丢失 |
| 切片可用性订阅 | 订阅 ID → 订阅条件（TaiList/Expiry），是事件消费的注册表 | 内存，非持久化 |
| NSSFContext | NF 实例运行时上下文（NfId/UriScheme/NrfUri/OAuth2Required/NfService 映射） | 内存 + YAML 配置 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化（free5gc 上层项目统一打包 Docker 镜像）
- **副本策略**：单副本部署；NSSF 不持有 UE/会话状态，但持有运行时上报的切片可用性数据，多副本需配合 AMF 重传或上层一致性方案
- **启动依赖**：NRF 必须可达（启动期阻塞重试至成功或 ctx 取消）；TLS 证书就绪；YAML 配置文件就绪（含 PLMN/TA/Nssai/AmfSet 拓扑）
- **可观测出口**：Prometheus 指标（可配置启用，独立端口；默认 9091 https）+ logrus 11 类分模块日志（级别可热改）+ SBI 入站/NRF 出站埋点
- **终止行为**：计划性终止时向 NRF 注销 NF 实例，SBI 在 2 秒优雅 Shutdown 超时内关闭；panic 路径同样通过 defer recover 强制注销
