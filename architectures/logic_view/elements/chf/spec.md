---
element_id: chf
element_name: chf
element_type: service
repo_path: repos/chf
last_modified: "2026-06-24T16:00:00+08:00"
last_modified_by: rev-arch-element-extract
intent_source_count: 0
confidence: medium
---

# 架构元素规格：chf

> 本文件是**架构层抽象**，结合代码逆向（事实域）与历史架构设计文档（意图域）综合生成。
> - **事实域**（接口、依赖、协议、当前 DFX 实现、当前部署形态）：以代码 + `repos/chf/.agent/*.md` 为准，标注"现状"。
> - **意图域**（战略角色、设计目的、原 DFX 目标、原部署规划）：以 `knowledge/历史方案/架构方案/` 为准，标注"原设计意图"。本次执行历史方案输入为空（Pando V1.0版本架构设计说明书 内容为空，未检出 chf 相关章节），意图域统一标注「无历史方案输入」，置信度由 high 降级为 medium。
> - 实现细节（具体业务功能点、接口契约签名、数据字段、代码位置）归 `repos/chf/.agent/*.md`，本文件不重复抄写，仅在节末以"契约详情见..."指引。

## 1. 元素定位

**现状**（事实域）：
chf 是 3GPP 5G 核心网的融合计费功能网元（Charging Function），是控制面所有计费触发的汇聚点与计费域的网络侧出口。它通过 SBI 接收 SMF/AMF 等消费方上送的 ChargingData 请求，承担在线信用控制（配额预留/实扣/退还）、CDR 生成与编码、CDR 文件向计费域转交三类架构职责。在架构上，chf 将控制面计费触发与计费域 OCS/BSS 解耦，并以单元素内嵌 Rating Function（RF）、Account Balance Management Function（ABMF）、Charging Gateway Function（CGF）三个子角色的形态，独立承担端到端在线计费闭环。

**原设计意图**（意图域）：无历史方案输入。

| 项目 | 现状 | 原设计意图 |
|------|------|-----------|
| 元素ID | chf | - |
| 元素名 | chf | - |
| 元素类型 | service（对外提供 Nchf SBI 的独立部署 NF） | - |
| 所属代码仓 | repos/chf | - |
| 战略角色 | 5GC 控制面计费汇聚点与计费域出口；单进程内嵌 CHF+RF+ABMF+CGF | 无历史方案输入 |
| 置信度 | 中（事实域高，意图域缺失整体降级） | - |

## 2. 职责描述

**现状**（事实域）：
chf 承担 5G 核心网的计费控制面职责：在控制面 NF 触发计费时维护 (UE, RatingGroup) 维度的配额状态机（RESERVE/DEBIT），驱动在线信用控制流程，编码符合 3GPP TS 32.298 规范的 ASN.1 CDR，并将 CDR 文件转交计费域。它不承担用户面流量统计（归 upf 上报）、不承担计费策略决策（归 PCF 与计费域）、不持久化业务订阅数据（仅持久化配额与资费），是计费触发的执行者与 CDR 的生成者。

**原设计意图**（意图域）：无历史方案输入。

## 3. 业务能力

> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途（现状） | 原设计目的（意图域） |
|--------|--------|----------------|--------------------|
| CAP-001 | 计费会话生命周期管理 | 接收消费 NF 的初次/更新/释放请求，维护 ChargingData 会话边界 | 无历史方案输入 |
| CAP-002 | 在线信用控制 | 在 RESERVE/DEBIT 双模式间切换，驱动配额预留、实扣与退还 | 无历史方案输入 |
| CAP-003 | 配额状态机维护 | 在 (UE, RatingGroup) 维度维护配额视图，是在线计费的核心状态 | 无历史方案输入 |
| CAP-004 | 资费计算 | 内嵌 Rating Function，依据资费表计算价格与允许单元 | 无历史方案输入 |
| CAP-005 | 账户余额管理 | 内嵌 ABMF，对持久化账户余额执行扣减与退还 | 无历史方案输入 |
| CAP-006 | CDR 记录生成 | 按 3GPP 32.298 ChargingFunctionRecord 组装并 ASN.1 BER 编码 | 无历史方案输入 |
| CAP-007 | CDR 分片切分 | 单 CDR 超过协议长度上限时切 partial record，保证 wire 格式合规 | 无历史方案输入 |
| CAP-008 | CDR 转交计费域 | 内嵌 CGF FTP 服务，把本地 CDR 文件投递到计费域 | 无历史方案输入 |
| CAP-009 | 充值通知 | 触发 UE 配额恢复并向 SMF 回调重授权事件 | 无历史方案输入 |
| CAP-010 | 离线计费占位 | 注册 Nchf_OfflineOnlyCharging 路由，预留未来扩展点 | 无历史方案输入 |
| CAP-011 | 限额控制占位 | 注册 Nchf_SpendingLimitControl 路由，预留未来扩展点 | 无历史方案输入 |
| CAP-012 | NRF 注册与发现 | 声明本 NF 可达性，发现 SMF 等下游 NF | 无历史方案输入 |
| CAP-013 | SUPI 隐私保护 | CDR 文件名对 SUPI 做哈希，避免明文标识落地文件系统 | 无历史方案输入 |
| CAP-014 | 指标暴露 | 通过独立 metrics 端口对接监控系统 | 无历史方案输入 |

## 4. 质量属性

> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 现状（事实域） | 原目标值 + 策略原因（意图域） |
|------|--------------|---------------------------|
| 性能 | 同一 UE 计费会话写串行避免配额竞态；UE 间 Diameter 通道相互隔离；CDR partial 切分避免单记录溢出；Diameter 客户端无连接池每次新建 TLS，单 UE 多 RatingGroup 串行调用存在累积延迟 | 无历史方案输入 |
| 可靠性 | 启动失败与计划性终止均反注册 NRF；关键链路 panic 恢复；FTP 连接探活与重登；Diameter 5s 超时不阻塞主流程；多处 nil-pointer / 长度守卫 | 无历史方案输入 |
| 可用性 | NRF 不可达不阻断本元素启动；CGF 不可达不阻断 SBI 响应（CDR 暂存本地）；Diameter 不可达跳过当前 RatingGroup 不中断会话；MongoDB 缺资费返回 UnableToComply 避免客户端等待超时 | 无历史方案输入 |
| 可扩展性 | SBI、Diameter Rf、Diameter Ro、FTP 子服务独立 goroutine；Offline/SpendingLimit 路由预占便于后续填充；横向扩 RF/ABMF 受单进程内嵌设计限制 | 无历史方案输入 |
| 安全性 | 对外 SBI 强制 TLS（HTTP/2）；Diameter Rf/Ro 通道强制 TLS；CGF FTP 可选 TLS；可选 OAuth2 Bearer Token 服务鉴权由 NRF 证书验签；SUPI 在文件名层做 SHA-256 哈希 | 无历史方案输入 |
| 可测试性 | UT 隔离 NRF HTTP 依赖（gock 拦截）；App 接口由 mockgen 生成 MockApp；MongoDB/Diameter 客户端缺接口抽象，相关 UT 缺失（已记入技术债） | 无历史方案输入 |
| 可观测性 | 模块化子 logger（CtxLog/SBILog/ChargingdataPostLog/AcctLog/RatingLog/CGFLog 等）+ 独立 metrics 端口 + InboundMetrics 中间件 + ProblemDetails 经 IN_PB_DETAILS_CTX_STR 上报；分布式追踪暂未接 otel | 无历史方案输入 |

历史方案未覆盖的行在"原目标值 + 策略原因"列统一标注「无历史方案输入」。

## 5. 提供的接口

> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。本章节为**事实纯度章节**，不夹意图。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | ChargingDataCreate | SBI (Nchf_ConvergedCharging) | 消费 NF 发起首次计费会话，开 CDR 与首次配额预留入口 |
| IF-002 | ChargingDataUpdate | SBI (Nchf_ConvergedCharging) | 周期/事件用量上报与再授权入口，含 partial CDR 切分 |
| IF-003 | ChargingDataRelease | SBI (Nchf_ConvergedCharging) | 计费会话结束入口，关 CDR 并落盘 |
| IF-004 | RechargeGet | SBI (Nchf_ConvergedCharging 内部) | 充值通道健康探测 |
| IF-005 | RechargePut | SBI (Nchf_ConvergedCharging 内部) | 触发 UE 配额恢复并回调 SMF 重授权 |
| IF-006 | OfflineOnlyCharging（骨架） | SBI (Nchf_OfflineOnlyCharging) | 离线计费协议占位，预留扩展点（501 Not Implemented） |
| IF-007 | SpendingLimitControl（骨架） | SBI (Nchf_SpendingLimitControl) | 限额控制协议占位，预留扩展点（501 Not Implemented） |
| IF-008 | RatingFunction | Diameter Rf (Re_interface) | 内嵌资费计算服务端，处理 Service Usage Request |
| IF-009 | ABMFCreditControl | Diameter Ro (RFC 4006) | 内嵌账户余额管理服务端，处理 Credit Control Request |
| IF-010 | CGF-FTP | FTP (可选 TLS) | CDR 文件接收/转交通道，供计费域 OCS/BSS 拉取 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/chf/.agent/interfaces.md`

## 6. 依赖的外部接口

> 架构层依赖声明：依赖哪个元素 + 架构用途。本章节为**事实纯度章节**，不夹意图。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册、反注册与下游 NF 发现，是所有跨 NF 调用的前置 |
| smf | UE 配额恢复后回调重授权（Recharge 反向通道）；SMF 同时是 chf 的主消费方（语义反向依赖） |
| amf | AMF 作为消费方触发注册计费（语义反向依赖） |
| mongodb | 持久化配额（quota）与资费（tariff），使配额状态跨进程重启不丢失（外部数据系统） |
| 计费域 OCS/BSS | 通过 CGF FTP 拉取 CDR 文件（外部业务系统） |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/chf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据

> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。事实纯度章节。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| CHF 全局上下文 | 维护 NF 实例信息、NRF URI、UE 池索引、会话 ID 生成器 | 内存 + YAML 配置 |
| CHF UE 会话上下文 | 每 UE 维护 CDR、Records、Diameter 客户端、ReservedQuota、UnitCost、RatingType 状态 | 内存，重启丢失 |
| 配额（Quota） | (UE, RatingGroup) 维度的剩余账户余额，是在线计费决策核心数据 | MongoDB 持久化 |
| 资费（Tariff） | RatingGroup 单价表，驱动价格计算 | MongoDB 持久化 |
| ChargingFunctionRecord | 符合 3GPP 32.298 的 ASN.1 CDR 主结构 | 落盘为 .cdr 文件，FTP 转交后可清理 |
| CDR 文件 | 哈希命名的本地 .cdr 文件，是计费域消费的输出物 | 本地文件系统暂存 + FTP 转交 |

## 8. 部署与运行

> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

| 维度 | 现状（事实域） | 原规划（意图域） |
|------|--------------|----------------|
| 部署形态 | 单进程内嵌 SBI / Rating Function（Diameter）/ ABMF（Diameter）/ CGF（FTP）四角色的 Go 二进制，可容器化 | 无历史方案输入 |
| 副本策略 | 默认单副本；多副本需配合 NRF NFInstance 负载均衡，并由 MongoDB 承担跨副本配额一致性 | 无历史方案输入 |
| 启动依赖 | NRF 可达、MongoDB 可达、TLS 证书与 YAML 配置就绪；可选外部计费域 FTP 接收端 | 无历史方案输入 |
| 可观测出口 | Prometheus 指标（独立 metrics 端口，默认 9091）+ 模块化子 logger（logrus）+ ProblemDetails 结构化错误统一上报 | 无历史方案输入 |
| 终止行为 | 计划性终止时先向 NRF 反注册，再停 SBI 服务，最后清理 CDR 暂存文件，等待各子服务 goroutine 退出 | 无历史方案输入 |
| 容量规格 | UePool 使用 sync.Map 无显式上限；本仓未给出明确单实例容量目标 | 无历史方案输入 |

历史方案未覆盖的维度在"原规划"列统一标注「无历史方案输入」。

## 参考源

本元素采纳的历史方案：

| solution_name | 主要采纳章节 |
|---------------|------------|
| 无历史方案输入 | — |

`intent_source_count: 0`。全文意图域章节均已标注「无历史方案输入」；事实域内容置信度高，意图域整体降级，综合 confidence=medium。
