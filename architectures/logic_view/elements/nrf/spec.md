---
element_id: nrf
element_name: nrf
element_type: service
repo_path: repos/nrf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：nrf

## 1. 元素定位
nrf 是 3GPP 5G 核心网控制面的**服务注册中心 + OAuth2 授权服务器**，是 SBI 域的强依赖中枢。它对所有其他 NF（amf/smf/udm/ausf/pcf/nssf/udr/nef/upf 等）提供 NF 注册、NF 发现、状态订阅与访问令牌签发能力——**任何 NF 启动前都必须先向 nrf 注册并通过 nrf 发现对端**，否则跨 NF 服务调用无法建立。架构上 nrf 同时承担"服务目录"与"信任根"双重角色：以自签 root CA 体系为每个 NF 签发证书，并以同一根信任签发 OAuth2 JWT，将服务发现与服务间鉴权信任链同源收敛。

| 项目 | 内容 |
|------|------|
| 元素ID | nrf |
| 元素名 | nrf |
| 元素类型 | service（对外提供 Nnrf SBI，独立部署 NF） |
| 所属代码仓 | repos/nrf |
| 置信度 | 高 |

## 2. 职责描述
nrf 承担 5G 核心网 SBI 域的服务治理职责：维护全网 NF Profile 仓库（注册/更新/反注册/查询）；为依赖方提供按 NF 类型/服务名/切片/PLMN 等多维过滤的 NF 发现能力；提供 OAuth2 token endpoint 签发并校验 NF 间访问令牌；提供 NF 证书签发以承载 mTLS 信任根；推送 NF Profile 变更通知以解耦服务发现的时效性。它不承担任何业务面控制（接入/会话/策略/鉴权数据），是纯粹的服务治理与信任锚定元素。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | NF 注册管理 | 维护全网 NF Profile 仓库，是所有 NF 可见性的来源 |
| CAP-002 | NF 反注册 | 移除离线 NF Profile 并广播下线事件，避免依赖方调用失效实例 |
| CAP-003 | NF Profile 更新 | 接受 NF 状态/能力增量变更，保持服务目录新鲜度 |
| CAP-004 | NF 发现 | 按 NF 类型/服务名/切片/PLMN/位置等多维过滤定位实例，是跨 NF 调用的前置 |
| CAP-005 | NF 状态订阅 | 为依赖方提供 NF 生命周期事件订阅通道，支持事件驱动的服务发现 |
| CAP-006 | NF 状态推送 | 在 NF 注册/反注册/变更时主动通知订阅方，缩短服务发现收敛时间 |
| CAP-007 | OAuth2 令牌签发 | 为 NF 间 SBI 调用签发 JWT 访问令牌，承载授权决策 |
| CAP-008 | Scope 与身份校验 | 校验请求方 NF 类型、证书 SAN URI 与目标服务 scope，防止越权 |
| CAP-009 | NF 证书签发 | 作为自签 CA 为每个 NF 签发证书，建立 mTLS 信任根 |
| CAP-010 | 服务目录健康暴露 | 通过 Index 接口提供存活探测入口 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | NF 发现查询走持久层过滤；出站通知客户端按目标 URI 缓存复用；并发计数与缓存以读写锁保护 |
| 可靠性 | NF Profile 持久化以容忍进程重启；优雅终止须等待依赖 NF 完成反注册再退出；出站通知在更新流程允许部分失败不阻塞主流程 |
| 可用性 | nrf 不可用将导致全网服务发现停摆，是系统关键路径；自身启动不依赖任何其他 NF 可达 |
| 可扩展性 | SBI 路由按服务组隔离（注册/发现/订阅/令牌/启动信息），各组可独立扩展处理链；持久层可水平扩容 |
| 安全性 | OAuth2 启用时强制 mTLS；自签 CA 体系签发 NF 证书；令牌请求方证书 SAN URI 与 nfInstanceId 强绑定校验；NF 身份标识不可变（禁止 JSON Patch 修改）；NfRegister 路由对 OAuth 豁免但仍受 mTLS 保护 |
| 可测试性 | UT 隔离持久层与出站 HTTP 依赖；配置校验与转换工具具备独立单测 |
| 可观测性 | 分模块日志（按业务域分组）+ 独立 Prometheus 指标端口 + 入站 SBI 指标埋点 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | RegisterNFInstance | SBI (Nnrf_NFManagement) | 接受 NF 注册，承载服务目录写入 |
| IF-002 | DeregisterNFInstance | SBI (Nnrf_NFManagement) | 接受 NF 反注册，承载服务目录清理 |
| IF-003 | UpdateNFInstance | SBI (Nnrf_NFManagement) | 接受 NF Profile 增量变更（JSON Patch） |
| IF-004 | GetNFInstance | SBI (Nnrf_NFManagement) | 按 ID 查询单个 NF Profile |
| IF-005 | GetNFInstances | SBI (Nnrf_NFManagement) | 按 NF 类型枚举 NF URI 集合 |
| IF-006 | CreateSubscription | SBI (Nnrf_NFManagement) | 接受依赖方对 NF 状态变更的订阅 |
| IF-007 | UpdateSubscription | SBI (Nnrf_NFManagement) | 修改订阅条件与回调 |
| IF-008 | RemoveSubscription | SBI (Nnrf_NFManagement) | 取消 NF 状态变更订阅 |
| IF-009 | SearchNFInstances | SBI (Nnrf_NFDiscovery) | 多维过滤定位 NF 实例，是跨 NF 调用的前置 |
| IF-010 | AccessTokenRequest | SBI (Nnrf_AccessToken / OAuth2) | 为 NF 间 SBI 调用签发 JWT 访问令牌 |
| IF-011 | BootstrappingInfoRequest | SBI | 启动信息查询入口（占位） |
| IF-012 | NFStatusNotify | SBI (出站回调) | 向订阅方推送 NF 注册/反注册/Profile 变更事件 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/nrf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| MongoDB | NF Profile / Subscriptions / urilist 持久化，是服务目录与订阅的存储底座（外部系统） |
| 订阅方 NF（动态：amf/smf/udm/...） | NF 状态变更事件回调投递目标；订阅时由依赖方声明回调 URI，nrf 主动出站推送 |
| prometheus | 指标 scrape（外部监控系统） |

> nrf 不依赖任何其他 5GC NF 元素（无前置 NF）。**作为服务治理中枢，nrf 是被所有 NF 依赖的元素，自身仅依赖持久层与监控基础设施**。

**详细依赖清单与调用时机**：见 `repos/nrf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| NF Profile 仓库 | 全网 NF 实例画像集合，是服务发现与令牌签发的事实来源 | MongoDB（NfProfile 集合，进程重启保留；计划性终止时主动清空） |
| NF 状态订阅集合 | 依赖方对 NF 生命周期事件的订阅条目（回调 URI + 过滤条件） | MongoDB（Subscriptions 集合） |
| NF URI 索引 | 按 NF 类型聚合的 NF URI 二级索引，加速集合查询 | MongoDB（urilist 集合） |
| NRF 自身上下文 | 自身 NF Profile、root CA 密钥与证书、注册 NF 计数 | 内存 + 文件系统（证书 PEM 文件） |
| NF 证书库 | OAuth 启用时为每个注册 NF 签发的证书 | 文件系统（cert 目录） |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化
- **副本策略**：单副本部署；多副本需配合外部共享持久层与前置负载均衡协调（架构层未原生支持多活）
- **启动依赖**：MongoDB 可达（启动连接失败仅记日志不退出，后续 API 将失败）、TLS 证书与 OAuth root CA 就绪（缺失时自动生成）、YAML 配置文件就绪；**无任何 NF 前置依赖**
- **可观测出口**：Prometheus 指标（独立端口，可选 TLS）+ 分模块日志（10+ 子 logger，7 级可配，运行时可调）+ SBI 入站指标埋点
- **终止行为**：计划性终止时等待全网 NF 完成反注册（最长 5s）→ 清空 NF Profile 集合 → 关闭 SBI 与 Metrics server；nrf 终止将导致全网服务发现停摆，部署侧须保证高可用
