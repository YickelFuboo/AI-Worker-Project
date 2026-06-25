---
element_id: udr
element_name: udr
element_type: service
repo_path: repos/udr
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: medium
---

# 架构元素规格：udr

## 1. 元素定位

**现状**（事实域）：
udr 是 3GPP 5G 核心网的统一数据仓库（Unified Data Repository），实现 3GPP TS 29.504/29.519 定义的 Nudr_DataRepository 服务，在系统架构中承担**数据持久化与统一访问层**角色。它向上以 SBI（HTTP/2+JSON+TLS）对 UDM/PCF/NEF/CHF 等数据消费侧 NF 暴露 SubscriptionData/PolicyData/ApplicationData/ExposureData/AuthenticationData 等数据集的 CRUD 与变更订阅通知能力；向下封装 MongoDB 作为后端存储，屏蔽存储实现细节。架构上 udr 将"业务数据存放在哪里"这一关注点从数据消费 NF 中剥离，是 5GC 控制面数据的"单一事实源"承载者，与 UDM「业务语义层」严格分层。

**原设计意图**（意图域）：
-

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | udr | - |
| 元素名 | udr | - |
| 元素类型 | service | - |
| 所属代码仓 | repos/udr | - |
| 战略角色 | 5GC 控制面数据的统一持久化与访问层；UDM/PCF/NEF/CHF 的数据后端 | - |
| 置信度 | 中（事实域 high，意图域无输入致整体降级） | - |

## 2. 职责描述

**现状**（事实域）：
udr 承担 5GC 控制面数据的集中存取职责：以标准化 SBI 提供订阅/策略/应用/暴露/鉴权数据集的 CRUD，维护数据变更订阅并向订阅方异步推送变更通知，将持久化策略（MongoDB）与上游 NF 的业务语义解耦。它不承担业务决策（归 UDM/PCF/NEF）、不承担鉴权材料生成（归 UDM）、不承担数据语义加工（归 UDM），是数据中介与状态汇聚点，不是业务计算节点；自身近似无状态（运行时上下文仅含 NfInstanceId、NRF URI、订阅 ID 生成器与 Influence 订阅缓存），业务状态全部下沉到 MongoDB。

**原设计意图**（意图域）：
-

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | 订阅数据存取 | 集中托管 UE 订阅档案（AM/SM/SMS/Trace/Operator Specific/Identity 等），是 UDM 的数据后端 | - |
| CAP-002 | 上下文登记管理 | 持久化 AMF/SMF/SMSF 接入与会话登记，支撑跨 NF 协同与归属查询 | - |
| CAP-003 | 鉴权数据存取 | 集中托管鉴权凭据、Authentication Status、Auth SoR，是 AUSF/UDM 主认证数据源 | - |
| CAP-004 | 策略数据存取 | 集中托管 UE/AM/SM/BDT/Sponsor Connectivity 等策略数据，是 PCF 的数据后端 | - |
| CAP-005 | 应用数据存取 | 集中托管 PFD/Influence/IPTV/Service Parameter 等数据，是 NEF 的数据后端 | - |
| CAP-006 | 暴露数据订阅 | 维护 Event Exposure 订阅集合与组订阅，连接事件产生方与消费方 | - |
| CAP-007 | SDM 订阅管理 | 维护 Subscriber Data Management 订阅，使 UDM 可级联通知 | - |
| CAP-008 | 数据变更订阅与通知 | 接受订阅方注册变更通知 URL，数据变化时异步推送，解耦读写时序 | - |
| CAP-009 | 共享数据检索 | 提供 PLMN/Slice 级共享配置的统一读取入口 | - |
| CAP-010 | 参数提供数据 | 托管管理面下发的预置参数（Provisioned Parameter），供 NF 查询 | - |
| CAP-011 | 身份与 ODB 查询 | 按 SUPI/GPSI 查询身份与 ODB 数据，支撑跨标识业务编排 | - |
| CAP-012 | NRF 注册与发现 | 声明本 NF 实例可达性，使数据消费 NF 可定位 udr | - |
| CAP-013 | OAuth2 入站鉴权 | 对入站请求按 ServiceName 进行 token 校验，保障数据访问权限边界 | - |
| CAP-014 | Metrics 暴露 | 通过独立端口暴露 Prometheus 指标，供监控系统采集 SBI 入站与出站统计 | - |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | SBI 走 HTTP/2 + Gin 并发处理；高频读多写少的订阅集合采用并发安全 map；NRF 出站客户端按目标 URI 缓存避免每请求重建 TLS；持久化操作单跳直达 MongoDB，避免中间层放大；仓内无显式量化指标声明 | - |
| 可靠性 | NRF 不可达时启动期持续重试直至成功（间隔 2 秒，受 ctx 取消兜底）；panic 时 recover 后自动反注册避免脏实例残留；订阅方不可达不阻塞主写入流程（通知尽力而为，不重试）；优雅停机有固定 shutdown 超时上限 | - |
| 可用性 | NRF 暂态故障不阻断本元素启动；MongoDB 不可达时进程存活但服务不可用，等待后端恢复；多副本水平扩展依赖外层探活与重启 | - |
| 可扩展性 | 自身近似无状态（业务状态全在 MongoDB），天然支持多副本水平扩展；DbConnector 接口抽象，理论上支持替换存储后端；路由按 ServiceName 分组，可独立扩展鉴权与限流策略 | - |
| 安全性 | 对外 SBI 强制 HTTPS（HTTP/2 + TLS），可选 mTLS；按 ServiceName 独立 OAuth2 路由鉴权（NRF 注册响应下发开关）；NfInstanceId 支持环境变量注入避免硬编码；TLS Key Log 可选用于抓包调试；敏感字段不在日志中明文输出（具体脱敏策略未在仓内显式体现） | - |
| 可测试性 | UDR App 接口通过 gomock 生成 mock 实现作为依赖反转点；UT 在 Procedure 层通过依赖注入隔离；涉 DB 用例需要本地 MongoDB（CI 用 services.mongo 提供）；CI 无覆盖率阈值门禁（已知约束） | - |
| 可观测性 | 分模块分类日志（MainLog/SBILog/DataRepoLog/ConsumerLog/DbLog/InitLog/CfgLog/UtilLog/GinLog）；独立可选 Prometheus 指标端口（默认 9091，命名空间 free5gc，与 SBI 端口启动期 fail-fast 校验不冲突）；所有路由强制挂入站指标中间件，错误响应前写入 cause 使指标标签可读；NRF 注册/反注册等里程碑日志保留；仓内无 OpenTelemetry 追踪接入 | - |

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | Nudr_DR Subscription Data | SBI (Nudr_DataRepository, HTTP/2 + JSON + TLS) | UE 订阅档案 CRUD（AM/SM/SMS/Trace/Operator Specific/Identity 等子集合） |
| IF-002 | Nudr_DR AMF Context | SBI (Nudr_DataRepository) | AMF 3GPP/Non-3GPP 接入登记上下文 PUT/PATCH/GET |
| IF-003 | Nudr_DR SMF Registration | SBI (Nudr_DataRepository) | SMF 登记上下文集合与单文档 CRUD |
| IF-004 | Nudr_DR SMSF Registration | SBI (Nudr_DataRepository) | 3GPP/Non-3GPP SMSF 登记上下文 CRUD |
| IF-005 | Nudr_DR Authentication Data | SBI (Nudr_DataRepository) | 鉴权数据查询/更新、Authentication Status、Auth SoR |
| IF-006 | Nudr_DR Policy Data | SBI (Nudr_DataRepository) | 策略数据 CRUD（UE/AM/SM/BDT/Sponsor Connectivity/Plmn UE Policy 等） |
| IF-007 | Nudr_DR Application Data | SBI (Nudr_DataRepository) | 应用数据 CRUD（PFD/Influence Data/BDT/Service Parameter/IPTV 等） |
| IF-008 | Nudr_DR Exposure Data | SBI (Nudr_DataRepository) | EE 订阅集合与单文档、AMF Subscription Info、组订阅 |
| IF-009 | Nudr_DR SDM Subscription | SBI (Nudr_DataRepository) | Subscriber Data Management 订阅集合与文档 |
| IF-010 | Nudr_DR Subs-to-Notify | SBI (Nudr_DataRepository) | 数据变更订阅注册入口（POST/PUT/DELETE） |
| IF-011 | Nudr_DR Shared Data | SBI (Nudr_DataRepository) | 共享数据读取入口 |
| IF-012 | Nudr_DR Parameter Provision | SBI (Nudr_DataRepository) | 参数提供文档 CRUD（Provisioned Parameter Data） |
| IF-013 | Nudr_DR Identity/ODB Query | SBI (Nudr_DataRepository) | 按 SUPI/GPSI 查询身份与 ODB 数据 |
| IF-014 | Data Change Notification | HTTP-Callback (UDR → 订阅方 notification URI) | 数据变更时异步向订阅方推送 Data Change / Policy Data Change / Influence Data Change 通知 |
| IF-015 | Nudr_GroupId-Map | SBI (Nudr_GroupId-Map) | NF Group ID 映射（架构占位，handler 返回 501 Not Implemented） |
| IF-016 | Nhss_IMS_SDM | SBI (Nhss_IMS_SDM) | HSS IMS SDM 数据查询/订阅（架构占位，handler 返回 501 Not Implemented） |
| IF-017 | Metrics Scrape | HTTP scrape (Prometheus) | 指标暴露（独立 metrics server 端口，默认 9091；configuration.metrics.enable 控制） |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/udr/.agent/interfaces.md`

> 备注：IF-015 / IF-016 当前仅保留路由前缀作为架构占位，所有 handler 返回 501，注册到 NRF 的 SupportedDataSets 当前仅声明 SUBSCRIPTION（APPLICATION/EXPOSURE/POLICY 在源码中被注释保留），便于未来按需打开。

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 实例注册/反注册、NF 发现（备用）、OAuth2 token issuer；是 udr 被上游 NF 定位的前置 |
| MongoDB | 数据持久化后端，是所有数据集（订阅/策略/应用/暴露/鉴权）的最终存储载体（外部基础设施） |
| prometheus | 指标 scrape 目标（外部监控基础设施，可选） |

**详细依赖清单与调用时机**：见 `repos/udr/.agent/spec.md §4` 与 `dependencies.yaml`

> 被依赖说明（反向）：本元素被 udm / pcf / nef / chf 调用，对应入站接口见 §5；这些反向关系在各调用方的 `dependencies.yaml` 中声明，不在本节展开。

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| Subscription Data | UE 订阅档案（AM/SM/SMS/Trace/Identity 等），5GC 用户身份核心数据 | MongoDB（持久化） |
| Policy Data | UE/AM/SM/BDT/Sponsor 等策略数据，策略决策的数据源 | MongoDB（持久化） |
| Application Data | PFD/Influence/IPTV/Service Parameter，业务暴露面数据 | MongoDB（持久化） |
| Exposure Data 订阅 | EE 订阅集合与组订阅，连接事件产生方与消费方 | MongoDB（持久化） |
| Authentication Data | 鉴权凭据、Authentication Status、Auth SoR | MongoDB（持久化） |
| NF 登记上下文 | AMF/SMF/SMSF 的接入与会话登记快照 | MongoDB（持久化） |
| Influence Data 订阅缓存 | 内存级订阅索引（sync.Map），加速变更通知分发 | 内存（重启丢失，可由持久层重建） |
| UDR 全局上下文 | NfInstanceId、NrfUri、订阅 ID 生成器、UE 订阅 map | 内存 + YAML 配置 |
| 订阅 ID 生成器 | 单调递增（PolicyData/EeSubscription 为 int，AppDataInfluData 为 uint64） | 内存，重启重置（已知容量风险见 §8） |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立进程（Go 二进制），可容器化；仓内不自带 Dockerfile，由 free5gc 顶层统一构建 | - |
| 副本策略 | 因业务状态全在 MongoDB，进程本身近似无状态，天然支持多副本水平扩展；多副本需注册不同 NfInstanceId（支持环境变量 `UDR_NF_INSTANCE_ID` 覆盖） | - |
| 启动依赖 | MongoDB 可达（不可达进程存活但服务不可用）；NRF 可达（不可达持续重试至成功，间隔 2 秒）；TLS 证书与私钥就绪（默认 ./cert/udr.{pem,key}）；YAML 配置 schema 版本严格 1.1.0；DbConnectorType 仅支持 mongodb | - |
| 可观测出口 | 9 类子 logger 分模块日志（trace/debug/info/warn/error/fatal/panic 7 级可配）+ 独立 Prometheus 指标端口（默认 9091，默认禁用需显式 enable，命名空间 free5gc）+ TLS Key Log（可选，默认 ./log/udrsslkey.log） | - |
| 终止行为 | 捕获 SIGINT/SIGTERM → ctx 取消 → 停 SBI/Metrics server（shutdown 超时 2 秒）→ 向 NRF 反注册本实例 → 等待子 goroutine 退出；panic 时 recover 后亦尝试反注册避免 NRF 脏实例 | - |
| 容量规格 | 无显式容量上限声明；订阅 ID 池受类型约束（uint64 实际无限，int 在 32 位平台约 21 亿）；UE 订阅缓存受进程内存约束；仓内置信度低 | - |

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| - | - |

`intent_source_count`：0。
