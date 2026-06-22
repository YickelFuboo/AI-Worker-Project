---
element_id: pcf
element_name: pcf
element_type: service
repo_path: repos/pcf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：pcf

> 本文件是**架构层抽象**，描述 pcf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/pcf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
pcf 是 3GPP 5G 核心网控制面的中心策略决策点，作为系统内策略治理的唯一权威源。它通过 SBI 向 SMF/AMF/AF/NEF 暴露多类策略服务（SM/AM/UE/BDT/Policy Authorization），承担会话级、接入移动性级与应用会话级的策略下发与动态更新；同时通过 UDR 获取订阅策略数据、与 BSF 协同完成多 PCF 部署下的会话绑定。在架构上，pcf 是策略的**决策与编排者**——不持有用户面状态、不存订阅原始数据，只在策略语义层把订阅、订阅事件与应用会话状态映射为 PCC 规则/QoS 决策/Charging Trigger。

| 项目 | 内容 |
|------|------|
| 元素ID | pcf |
| 元素名 | pcf |
| 元素类型 | service（对外提供 Npcf SBI，独立部署 NF） |
| 所属代码仓 | repos/pcf |
| 置信度 | 高 |

## 2. 职责描述
pcf 承担 5G 核心网控制面的策略决策与下发职责：维护 SM Policy/AM Policy/AppSession/BDT Policy 上下文，按订阅数据与应用会话状态生成 PCC 规则与 QoS 决策，主动向消费方推送策略变更与终止通知，并响应 UDR/AMF 的状态变更回调。它不承担用户面策略执行（归 SMF/UPF）、不承担订阅数据存储（归 UDR）、不承担会话生命周期（归 SMF），是策略层面的决策中枢与跨 NF 编排点。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | SM 策略控制 | 为 PDU 会话提供 PCC/QoS/Charging 决策入口，是用户面策略的源头 |
| CAP-002 | AM 策略控制 | 为接入移动性流程提供策略关联与事件触发器约束 |
| CAP-003 | UE 策略控制 | 管理 UE 路由选择策略关联（含 stub 演化点） |
| CAP-004 | BDT 策略控制 | 后台数据传输窗口与速率策略的生成与下发 |
| CAP-005 | Policy Authorization | 接受 AF/NEF 应用会话请求，转换为 SM 策略变更，是应用层影响入口 |
| CAP-006 | 主动策略通知 | 向 SMF/AMF/AF 推送策略更新与终止，使消费方收敛策略 |
| CAP-007 | 回调入口 | 接收 UDR 策略数据/影响数据变更与 AMF 状态变更通知 |
| CAP-008 | UDR 策略数据获取 | 从 UDR 拉取 SM/AM/BDT/Influence 订阅数据驱动决策 |
| CAP-009 | BSF 绑定 | 在多 PCF 部署下注册 PCF Binding，保障会话定位一致性 |
| CAP-010 | AMF 状态订阅 | 订阅 AMF 状态变更，感知接入侧可用性以驱动策略收敛 |
| CAP-011 | NRF 注册与发现 | 声明本 NF 可达性，发现协作 NF（UDR/BSF/AMF） |
| CAP-012 | 会话绑定查询 | 按 SUPI/GPSI/IPv4/IPv6 反查 SM Policy，供 AF/NEF 应用会话挂接 |
| CAP-013 | OAM 查询 | 为运维提供 AM Policy 运行态可见性 |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | 全部上下文池并发可读写；策略下发与回调互不阻塞；ID 分配线程安全 |
| 可靠性 | 优雅终止须先停 SBI 再注销 NRF；策略数据持久化以容忍重启；NRF 注册失败不阻断启动 |
| 可用性 | NRF/UDR/BSF 不可达时按"可选优先、必需告警"分级处置，BSF 缺失降级而非失败 |
| 可扩展性 | SBI 服务按路由组解耦；新增 NF 类型只需扩展独立鉴权中间件与 consumer |
| 安全性 | 对外 SBI 强制 mTLS；7 个服务路由组分别独立 AuthorizationCheck；callback 路由独立鉴权；可选 NRF OAuth2 |
| 可测试性 | UT 隔离所有外部 NF 与 MongoDB；HTTP Mock 框架可拦截 SBI 出站 |
| 可观测性 | 分模块日志（7 级可配）+ 独立 Prometheus 指标端口 + OTel 分布式追踪 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途（不是契约签名）。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | Npcf_SMPolicyControl | SBI (HTTP/2 + JSON + mTLS) | 为 SMF 提供 SM 策略创建/查询/更新/删除入口 |
| IF-002 | Npcf_AMPolicyControl | SBI | 为 AMF 提供 AM 策略关联与事件触发器上报入口 |
| IF-003 | Npcf_UEPolicyControl | SBI | 为 AMF 提供 UE 路由选择策略关联入口（演化中） |
| IF-004 | Npcf_BDTPolicyControl | SBI | 为 AF/NEF 提供后台数据传输策略协商入口 |
| IF-005 | Npcf_PolicyAuthorization | SBI | 为 AF/NEF 提供应用会话上下文与事件订阅入口 |
| IF-006 | Npcf_Callback (UDR) | SBI Callback | 接收 UDR 策略数据/影响数据变更通知 |
| IF-007 | Npcf_Callback (AMF) | SBI Callback | 接收 AMF 状态变更通知 |
| IF-008 | Npcf_EventExposure | SBI | 事件暴露接口（路由组占位） |
| IF-009 | Npcf_OAM | HTTP（无鉴权） | 运维查询 AM Policy 状态 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/pcf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途（不是调用时机/代码证据）。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与发现，是所有跨 NF 调用的前置 |
| udr | 策略订阅数据与影响数据获取，驱动策略决策 |
| bsf | 多 PCF 部署下 PCF Binding 注册（可选） |
| amf | AM Policy 更新/终止通知投递；订阅 AMF 状态变更 |
| smf | SM Policy 更新/终止通知投递（反向回调消费者） |
| chf | 计费策略关联与 Charging Trigger 协同（间接，按 PCC 规则编排） |
| af / nef | App Session 事件与终止通知投递（反向回调消费者） |
| MongoDB | 策略数据持久化（外部存储系统） |
| prometheus | 指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/pcf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| UE 上下文（UePool） | 按 SUPI 索引 UE 级策略集合（SM/AM/AppSession 子上下文锚点） | 内存 sync.Map |
| SM Policy 子上下文 | 维护 PDU 会话级策略关联，是会话绑定查询的核心索引 | 内存 + MongoDB 策略数据 |
| AM Policy 子上下文 | 维护接入移动性策略关联与事件触发器订阅 | 内存 + MongoDB 策略数据 |
| AppSession 池 | 维护 AF/NEF 应用会话上下文 | 内存 sync.Map |
| BDT Policy 池 | 维护 BDT 策略实例，BdtPolicyId 由 idgenerator 分配（1~MaxInt64） | 内存 + MongoDB |
| AMFStatusSubsData | 缓存 AMF 状态订阅，感知接入侧可用性 | 内存 sync.Map |
| 策略订阅数据（PCC/QoS/Charging） | 决策输入，从 UDR 拉取后投影到上下文 | MongoDB（mongoapi） |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化（由 free5gc 顶层统一构建，仓内无 Dockerfile）
- **副本策略**：通常单副本；多副本部署需配合 NRF NFInstance 负载均衡与 BSF 完成 PCF 选择绑定
- **启动依赖**：NRF 可达（不可达降级，仅 Error 日志不退出）、MongoDB 必须可达、mTLS 证书就绪、YAML 配置就绪；UDR/BSF/AMF 后挂动态发现
- **可观测出口**：Prometheus 指标（独立 metrics 端口，默认 9091，可关闭）+ logrus 分模块日志（7 级可配）+ OpenTelemetry 分布式追踪（间接依赖）
- **终止行为**：计划性终止时按序取消 context → 停 SBI server → 停 metrics server → 向 NRF 注销 NF 实例，等待子 goroutine 退出
