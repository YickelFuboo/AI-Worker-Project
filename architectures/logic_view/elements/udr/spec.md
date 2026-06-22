---
element_id: udr
element_name: udr
element_type: service
repo_path: repos/udr
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：udr

> 本文件是**架构层抽象**，描述 udr 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/udr/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
udr 是 3GPP 5G 核心网的统一数据仓库（Unified Data Repository），在系统架构中承担用户/策略/应用/暴露数据的**统一持久化与统一访问层**角色，实现 3GPP TS 29.504/29.519 定义的 Nudr_DataRepository 服务。它向上以 SBI 暴露 CRUD 与变更订阅通知能力，被 UDM/PCF/NEF/CHF 等数据消费侧 NF 透明依赖；向下封装 MongoDB 后端，屏蔽存储实现细节。在架构上，udr 将"业务数据存放在哪里"这一关注点从数据消费 NF 中剥离，是 5GC 控制面数据"单一事实源"的承载者。

| 项目 | 内容 |
|------|------|
| 元素ID | udr |
| 元素名 | udr |
| 元素类型 | service（对外提供 Nudr_DataRepository SBI，独立部署 NF） |
| 所属代码仓 | repos/udr |
| 置信度 | 高 |

## 2. 职责描述
udr 承担 5GC 控制面数据的集中存取职责：以标准化 SBI 提供 SubscriptionData/PolicyData/ApplicationData/ExposureData 等数据集的 CRUD，维护数据变更订阅并向订阅方推送变更通知，将持久化策略（MongoDB）与上游 NF 的业务语义解耦。它不承担业务决策（归 UDM/PCF/NEF），不承担数据来源生成（归 BSF/PCF/管理面），是数据中介与状态汇聚点，不是业务计算节点。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | 订阅数据存取 | 集中托管 UE 订阅档案（AM/SM/SMS/Trace/Identity 等），是 UDM 数据后端 |
| CAP-002 | 上下文登记管理 | 持久化 AMF/SMF/SMSF 接入与会话登记，支撑跨 NF 协同 |
| CAP-003 | 鉴权数据存取 | 集中托管鉴权凭据与状态，是 AUSF/UDM 主认证数据源 |
| CAP-004 | 策略数据存取 | 集中托管 UE/AM/SM/BDT/Sponsor 等策略数据，是 PCF 数据后端 |
| CAP-005 | 应用数据存取 | 集中托管 PFD/Influence/IPTV/Service Parameter 等数据，是 NEF 数据后端 |
| CAP-006 | 暴露数据订阅 | 维护 Event Exposure 订阅集合，连接事件产生方与消费方 |
| CAP-007 | SDM 订阅管理 | 维护 Subscriber Data Management 订阅，使 UDM 可级联通知 |
| CAP-008 | 数据变更订阅与通知 | 接受订阅方注册变更通知 URL，数据变化时异步推送，解耦读写时序 |
| CAP-009 | 共享数据检索 | 提供 PLMN/Slice 级共享配置的统一读取入口 |
| CAP-010 | 参数提供数据 | 托管管理面下发的预置参数（Provisioned Parameter），供 NF 查询 |
| CAP-011 | NRF 注册与发现 | 声明本 NF 实例可达性，使数据消费 NF 可定位 udr |
| CAP-012 | OAuth2 鉴权 | 对入站请求按 ServiceName 进行 token 校验，保障数据访问权限边界 |
| CAP-013 | Metrics 暴露 | 通过独立端口暴露 Prometheus 指标，供监控系统采集 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | SBI 路由并发处理；高频读多写少场景使用内存级并发结构（订阅缓存）；持久化操作单跳直达后端，避免中间层放大 |
| 可靠性 | NRF 不可达时启动期持续重试直至成功；panic 时自动反注册避免脏实例残留；订阅方不可达不阻塞主写入流程 |
| 可用性 | 无限重试容忍 NRF/启动顺序漂移；MongoDB 不可达时进程存活但服务不可用，等待后端恢复 |
| 可扩展性 | DbConnector 接口抽象，理论上支持替换存储后端；路由按 ServiceName 分组，可独立扩展鉴权策略 |
| 安全性 | SBI 强制 HTTPS（HTTP/2 + TLS），可选 mTLS；OAuth2 入站按 ServiceName 鉴权；NfInstanceId 支持环境变量注入避免硬编码 |
| 可测试性 | 接口契约可 mock（mockgen 生成）；业务流程通过 DbConnector 接口注入桩；UT 不依赖真实 MongoDB |
| 可观测性 | logrus 分子系统日志（MainLog/SBILog/DataRepoLog/ConsumerLog/DbLog 等）；独立 Prometheus metrics 端口（默认 9091）；TLS Key Log 可选 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | Nudr_DR Subscription Data | SBI (Nudr_DataRepository, HTTP/2 + JSON + TLS) | UE 订阅档案 CRUD（AM/SM/SMS/Trace/Identity 等） |
| IF-002 | Nudr_DR AMF Context | SBI (Nudr_DataRepository) | AMF 3GPP/Non-3GPP 接入登记上下文存取 |
| IF-003 | Nudr_DR SMF Registration | SBI (Nudr_DataRepository) | SMF 登记上下文存取，支撑会话管理 |
| IF-004 | Nudr_DR SMSF Registration | SBI (Nudr_DataRepository) | SMSF 3GPP/Non-3GPP 登记上下文存取 |
| IF-005 | Nudr_DR Authentication Data | SBI (Nudr_DataRepository) | 鉴权数据与 Auth Status/Auth SoR 存取 |
| IF-006 | Nudr_DR Policy Data | SBI (Nudr_DataRepository) | 策略数据 CRUD（UE/AM/SM/BDT/Sponsor 等） |
| IF-007 | Nudr_DR Application Data | SBI (Nudr_DataRepository) | 应用数据 CRUD（PFD/Influence/IPTV/Service Parameter） |
| IF-008 | Nudr_DR Exposure Data | SBI (Nudr_DataRepository) | EE 订阅与组订阅存取 |
| IF-009 | Nudr_DR SDM Subscription | SBI (Nudr_DataRepository) | SDM 订阅集合与文档管理 |
| IF-010 | Nudr_DR Subs-to-Notify | SBI (Nudr_DataRepository) | 数据变更订阅注册入口 |
| IF-011 | Nudr_DR Shared Data | SBI (Nudr_DataRepository) | 共享数据读取入口 |
| IF-012 | Nudr_DR Parameter Provision | SBI (Nudr_DataRepository) | 参数提供数据存取 |
| IF-013 | Nudr_DR Identity/ODB Query | SBI (Nudr_DataRepository) | 按 SUPI/GPSI 查询身份与 ODB 数据 |
| IF-014 | Data Change Notification (out) | HTTP-Callback (主动外呼) | 异步向订阅方推送数据变更通知 |
| IF-015 | Nudr_GroupId-Map | SBI (Nudr_GroupId-Map) | NF Group ID 映射（架构占位，未实现） |
| IF-016 | Nhss_IMS_SDM | SBI (Nhss_IMS_SDM) | HSS IMS SDM 数据访问（架构占位，未实现） |
| IF-017 | Metrics Scrape | HTTP scrape | Prometheus 指标暴露 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/udr/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 实例注册/注销/发现，是上游 NF 找到 udr 的前置；启动期持续重试直至可达 |
| MongoDB | 数据持久化后端，是所有数据集的最终存储载体（外部基础设施） |
| OAuth2（NRF 颁发） | 入站请求 token 校验与出站 token 获取，由 NRF 作为 token issuer |
| prometheus | 指标 scrape 目标（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/udr/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| Subscription Data | UE 订阅档案（AM/SM/SMS/Trace/Identity 等），是 5GC 用户身份核心数据 | MongoDB（持久化） |
| Policy Data | UE/AM/SM/BDT/Sponsor 等策略数据，是策略决策的数据源 | MongoDB（持久化） |
| Application Data | PFD/Influence/IPTV/Service Parameter，是业务暴露面数据 | MongoDB（持久化） |
| Exposure Data 订阅 | EE 订阅集合与组订阅，连接事件产生方与消费方 | MongoDB（持久化） |
| Authentication Data | 鉴权凭据、Auth Status、Auth SoR | MongoDB（持久化） |
| NF 登记上下文 | AMF/SMF/SMSF 的接入与会话登记快照 | MongoDB（持久化） |
| Influence Data 订阅缓存 | 内存级订阅索引，加速变更通知分发 | 内存（重启丢失，可由持久层重建） |
| UDR 全局上下文 | NfInstanceId、NrfUri、订阅 ID 生成器 | 内存 + YAML 配置 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化（free5gc 主仓统一打包）
- **副本策略**：单副本部署；多副本需配合 NRF NFInstance 负载均衡，状态完全位于 MongoDB 后端，进程本身近似无状态
- **启动依赖**：MongoDB 可达（不可达进程存活但服务不可用）、NRF 可达（不可达持续重试至成功）、TLS 证书就绪、YAML 配置文件就绪
- **可观测出口**：Prometheus 指标（独立端口，默认 9091，配置 enable）+ logrus 分模块日志（trace/debug/info/warn/error/fatal/panic 7 级可配）+ TLS Key Log（可选）
- **终止行为**：SIGINT/SIGTERM 触发 ctx 取消 → 停 SBI/Metrics server（2s timeout）→ 向 NRF 反注册 NF 实例 → 等待子 goroutine 退出；panic 时 recover 后亦尝试反注册避免 NRF 脏实例
