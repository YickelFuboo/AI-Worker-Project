---
element_id: udm
element_name: udm
element_type: service
repo_path: repos/udm
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: high
---

# 架构元素规格：udm

## 1. 元素定位

**现状**（事实域）：
udm 是 3GPP 5G 核心网的统一数据管理网元，作为 UDR（统一数据仓库）之上的**无状态业务封装层**存在。它对 AUSF/AMF/SMF/SMSF/NEF 等控制面 NF 提供 3GPP TS 29.503 定义的 Nudm 系列服务化接口，将原始订阅数据加工为业务可消费的视图：执行 Milenage 5G-AKA 鉴权向量生成与 AUTS 重同步、SUCI→SUPI 反隐藏、订阅数据查询与变更订阅、UE 注册上下文管理、事件暴露与参数注入。架构上 udm 是「业务语义层」，与 UDR「数据存储层」严格分层，自身不持久化任何业务数据。

**原设计意图**（意图域）：
-

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | udm | - |
| 元素名 | udm | - |
| 元素类型 | service | - |
| 所属代码仓 | repos/udm | - |
| 战略角色 | UDR 之上的业务语义封装层 + 5G-AKA 鉴权材料计算者 + SUCI 隐私去隐藏点 | - |
| 置信度 | 高 | - |

## 2. 职责描述

**现状**（事实域）：
udm 承担 5G 核心网的用户数据业务封装与鉴权材料生成职责：将 UDR 的原始订阅数据按服务语义透传或加工后对外暴露，执行 5G-AKA 鉴权向量计算与 SQN 重同步，完成 SUCI 解隐藏以保护用户身份隐私，维护 UE 注册上下文与事件订阅关系，并接收 UDR 数据变更通知后转发给已订阅的上游 NF。它不持久化业务数据（归 udr）、不直接终结 UE 信令（归 amf）、不做策略决策（归 pcf）；是数据语义的加工者与分发者，而非存储者。

**原设计意图**（意图域）：
-

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | UE 鉴权数据生成 | 为 AUSF 生成 5G-AKA 鉴权向量，是 UE 主认证的密钥源 | - |
| CAP-002 | SQN 重同步 | 处理 UE 上报的 AUTS，恢复鉴权序列号一致性 | - |
| CAP-003 | 鉴权事件确认 | 落库鉴权结果，闭环鉴权生命周期 | - |
| CAP-004 | SUCI 反隐藏 | 在 UDM 内部解出 SUPI，隔离用户永久标识与无线侧 | - |
| CAP-005 | 订阅数据查询 | 向 AMF/SMF 提供 AM/SM/NSSAI/SMF 选择/Trace 等订阅视图 | - |
| CAP-006 | 订阅数据变更订阅 | 建立数据变更通知通道，驱动 NF 侧状态刷新 | - |
| CAP-007 | UE 上下文注册管理 | 维护 UE 在 AMF/SMF 的注册关系，是控制面归属表 | - |
| CAP-008 | 事件暴露订阅 | 为 NEF/AF 提供 UE 事件订阅入口，解耦事件消费 | - |
| CAP-009 | 参数注入 | 为 NEF 提供 PP-Data/5G-VN/5G-MBS/AF 参数写入通道 | - |
| CAP-010 | 数据变更转发 | 接收 UDR 推送的数据变更，按订阅关系扇出给上游 NF | - |
| CAP-011 | GPSI/SUPI 反解析 | 提供身份标识翻译入口，支撑跨标识业务编排 | - |
| CAP-012 | NRF 注册与发现 | 声明本 NF 可达性，发现下游 UDR 实例 | - |
| CAP-013 | SBI 服务能力声明 | 通过白名单声明本元素实际支持的 Nudm 服务子集 | - |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | SBI 出站客户端按目标 URI 复用，避免每请求重建 TLS；UE 上下文池采用免单点锁的并发结构 + UE 内字段级锁降低锁粒度 | - |
| 可靠性 | 计划性终止须向 NRF 反注册并优雅关闭 SBI/Metrics 端点；NRF 注册失败降级运行不退出进程；裸 panic 捕获后退出栈打印；HTTP server shutdown 有固定超时上限 | - |
| 可用性 | UDR 不可达时如实返回错误码，不本地兜底造数据；NRF 暂态故障不阻断本元素启动；多实例水平扩展依赖外层探活与重启 | - |
| 可扩展性 | 自身无业务数据持久化，天然支持多副本水平扩展；多 UDR 实例按 ueId 前缀分流；NfInstanceId 支持环境变量覆盖以适应容器化注入 | - |
| 安全性 | 对外 SBI 强制 mTLS；按 ServiceName 独立 OAuth2 路由鉴权；SUCI 解码在 UDM 内部完成，SUPI 不外泄；鉴权根密钥 K/OPC 仅运行时内存中流转，不落盘日志；私钥/公钥启动期强制 hex 格式校验 | - |
| 可测试性 | UT 通过接口 mock + HTTP 拦截隔离所有外部 NF 与 HTTP 出站调用；提供 App 接口与 mock 实现作为依赖反转点；CI 无覆盖率门禁（已知约束） | - |
| 可观测性 | 分模块分类日志（18 个业务分类，运行时可热修改级别与开关）+ 独立可选 Prometheus 指标端口（默认禁用，命名空间 free5gc）+ OpenTelemetry 追踪（间接依赖）；敏感字段强制脱敏；NRF/UDR 故障 Error 级告警不退出 | - |

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | GenerateAuthData | SBI (Nudm_UEAuthentication) | 为 AUSF 生成 5G-AKA 鉴权向量（含 AUTS 重同步分支） |
| IF-002 | ConfirmAuth | SBI (Nudm_UEAuthentication) | 落库 AUSF 鉴权完成事件 |
| IF-003 | GetAmData | SBI (Nudm_SDM v2) | 向 AMF 提供 AM 订阅数据 |
| IF-004 | GetSmData | SBI (Nudm_SDM v2) | 向 SMF 提供 SM 订阅数据 |
| IF-005 | GetNssai | SBI (Nudm_SDM v2) | 提供 UE 订阅 NSSAI |
| IF-006 | GetSmfSelectData | SBI (Nudm_SDM v2) | 提供 SMF 选择辅助数据 |
| IF-007 | GetTraceData | SBI (Nudm_SDM v2) | 提供 Trace 配置 |
| IF-008 | GetUeContextInSmfData | SBI (Nudm_SDM v2) | 提供 SMF 侧 UE 上下文视图 |
| IF-009 | GetSupi | SBI (Nudm_SDM v2) | 多数据集合并查询入口 |
| IF-010 | GetSharedData | SBI (Nudm_SDM v2) | 提供共享订阅数据 |
| IF-011 | SubscribeSdm | SBI (Nudm_SDM v2) | 订阅 UE 订阅数据变更 |
| IF-012 | UnsubscribeSdm | SBI (Nudm_SDM v2) | 取消订阅数据变更 |
| IF-013 | ModifySdmSubscription | SBI (Nudm_SDM v2) | 修改订阅数据变更 |
| IF-014 | SubscribeSharedData | SBI (Nudm_SDM v2) | 订阅共享数据变更 |
| IF-015 | GetIdTranslationResult | SBI (Nudm_SDM v2) | GPSI→SUPI 反解析 |
| IF-016 | RegistrationAmf3gppAccess | SBI (Nudm_UECM) | AMF 3GPP 接入注册写入 |
| IF-017 | GetAmf3gppAccess | SBI (Nudm_UECM) | AMF 3GPP 注册查询 |
| IF-018 | UpdateAmf3gppAccess | SBI (Nudm_UECM) | AMF 3GPP 注册更新 |
| IF-019 | RegistrationAmfNon3gppAccess | SBI (Nudm_UECM) | AMF Non-3GPP 接入注册 |
| IF-020 | GetAmfNon3gppAccess | SBI (Nudm_UECM) | AMF Non-3GPP 注册查询 |
| IF-021 | UpdateAmfNon3gppAccess | SBI (Nudm_UECM) | AMF Non-3GPP 注册更新 |
| IF-022 | RegistrationSmfRegistrations | SBI (Nudm_UECM) | SMF PDU 会话级注册写入 |
| IF-023 | DeregistrationSmfRegistrations | SBI (Nudm_UECM) | SMF PDU 会话级反注册 |
| IF-024 | CreateEeSubscription | SBI (Nudm_EE) | 创建 UE 事件暴露订阅 |
| IF-025 | UpdateEeSubscription | SBI (Nudm_EE) | 更新事件暴露订阅 |
| IF-026 | DeleteEeSubscription | SBI (Nudm_EE) | 删除事件暴露订阅 |
| IF-027 | UpdatePpData | SBI (Nudm_PP) | NEF 参数注入 PP-Data |
| IF-028 | Create5GMBSGroup | SBI (Nudm_PP) | 5G MBS 组参数创建 |
| IF-029 | Create5GVNGroup | SBI (Nudm_PP) | 5G VN 组参数创建 |
| IF-030 | CreatePPDataEntry | SBI (Nudm_PP) | AF 实例级 PP 参数条目写入 |
| IF-031 | DataChangeNotificationToNF | HTTP-Callback (Nudm Callback) | 接收 UDR 数据变更并转发给已订阅 NF |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/udm/.agent/interfaces.md`

> 备注：除上述已实现接口外，本元素仍保留 Nudm_MT / Nudm_NIDDAU / Nudm_RSDS / Nudm_SSAU / Nudm_UEID 五组路由前缀作为架构占位，对应路由当前返回 501 NotImplemented，不在 ServiceNameList 中声明，因此不进入架构层已实现接口清单。

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 实例注册/反注册 + 下游 UDR 实例发现，是所有跨 NF 调用的前置 |
| udr | 所有订阅/鉴权/UECM 注册数据的实际持久化下游，是 udm 业务数据的唯一来源 |
| udm（自反） | 多 UDM 集群内部互通的 SDM/UECM 客户端通道（已初始化，业务尚未广泛使用） |
| prometheus | 指标 scrape（外部监控基础设施，可选） |

**详细依赖清单与调用时机**：见 `repos/udm/.agent/spec.md §4` 与 `dependencies.yaml`

> 被依赖说明（反向）：本元素被 amf / ausf / smf / nef 调用，对应入站接口见 §5；这些反向关系在各调用方的 `dependencies.yaml` 中声明，不在本节展开。

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| UDM 全局上下文 | 维护 NF 实例元数据、SUCI 解码私钥、OAuth2 开关、服务能力声明 | 内存 + YAML 配置，重启从配置重建 |
| UE 运行时上下文 | 按 SUPI 缓存订阅数据视图、订阅通知列表、AMF 状态订阅列表 | 内存，非持久化，重启丢失 |
| SUCI 解密配置 | Profile A/B 公私钥对，是用户身份隐私保护的根 | YAML 配置（静态） |
| 事件订阅 ID 池 | 单调递增 ID 发号器，用于 EE 订阅资源标识 | 内存，重启重置 |
| SBI 客户端连接池 | 按目标 URI 缓存的 UDR/NRF/UDM 出站客户端 | 内存（运行期复用） |
| 鉴权根密钥（K/OPC） | 单次 AV 生成请求中从 UDR 取出并使用，不在 UDM 缓存 | 不在 udm 持久化（归 udr） |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 独立进程（Go 二进制），可容器化；仓内不自带 Dockerfile，由 free5gc 顶层统一构建 | - |
| 副本策略 | 因无业务数据本地化，天然支持多副本水平扩展；多副本需注册不同 NfInstanceId（支持环境变量覆盖） | - |
| 启动依赖 | NRF 可达（不可达降级运行不退出）；UDR 可达（业务请求级要求）；mTLS 证书与 SUCI 公私钥就绪；YAML 配置 schema 版本严格匹配 | - |
| 可观测出口 | 18 个分类日志（运行时可热修改级别与开关）+ Prometheus 指标（独立端口，默认禁用需显式开启）+ OpenTelemetry 追踪（间接依赖） | - |
| 终止行为 | 捕获 SIGINT/SIGTERM 后向 NRF 反注册本实例、关闭 SBI 与 Metrics HTTP 服务器、等待 in-flight 请求完成（固定 shutdown 超时） | - |
| 容量规格 | 单 UDM 实例 EE 订阅 ID 池上限约 21 亿；UE 上下文池受进程内存约束；多 UDR 实例按 ueId 前缀路由 | - |

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| - | - |

`intent_source_count`：0。
