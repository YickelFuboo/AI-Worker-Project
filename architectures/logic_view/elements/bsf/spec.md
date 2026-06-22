---
element_id: bsf
element_name: bsf
element_type: service
repo_path: repos/bsf
last_modified: "2026-06-22T12:00:00+08:00"
last_modified_by: rev-arch-element-extract
confidence: high
---

# 架构元素规格：bsf

> 本文件是**架构层抽象**，描述 bsf 元素在 5G 核心网架构中的角色、能力、质量要求与部署形态。
> 实现细节（具体业务功能点、接口契约签名、数据结构字段、代码位置）归 `repos/bsf/.agent/*.md`，本文件不重复抄写，仅在必要处用节末指引方式引用。

## 1. 元素定位
bsf 是 3GPP 5G 核心网控制面的绑定支持网元（Binding Support Function），是 PCF 实例与 UE PDU 会话之间绑定关系的权威目录。它在架构上充当"PCF 发现的事实源"：PCF 在会话建立时向 bsf 登记绑定，SMF/NEF/AF 通过多维度（UE 标识/UE 地址/DNN/S-NSSAI/MBS 会话标识）反查所属 PCF。bsf 不参与策略决策、不持有会话用户面状态，仅承担映射查询与生命周期管理职责，是策略平面跨 NF 路由解耦的关键基础设施。

| 项目 | 内容 |
|------|------|
| 元素ID | bsf |
| 元素名 | bsf |
| 元素类型 | service（对外提供 Nbsf_Management SBI，独立部署 NF） |
| 所属代码仓 | repos/bsf |
| 置信度 | 高 |

## 2. 职责描述
bsf 承担 PCF 绑定关系的存储、查询与生命周期管理职责：为 PDU 会话级、UE 级、MBS 会话级三类 PCF 绑定提供 CRUD 入口；为绑定事件提供订阅注册入口；按 TTL 与不活跃阈值清理陈旧绑定；按 SUPI/PcfId 维度批量回收绑定。它是查询中枢而非决策中枢，不参与 PCF 的策略计算。

## 3. 业务能力
> 架构层能力清单，每项一句话讲清该能力的架构用途。

| 能力ID | 能力名 | 架构用途 |
|--------|--------|----------|
| CAP-001 | PCF 会话绑定管理 | 维护 PDU 会话级 UE↔PCF 映射，是策略平面路由的事实源 |
| CAP-002 | PCF 绑定多维查询 | 按 UE 标识/UE 地址/DNN/S-NSSAI 等组合反查 PCF，是 SMF/NEF/AF 发现 PCF 的统一入口 |
| CAP-003 | PCF UE 级绑定管理 | 维护 UE 级 PCF 关联，区别于会话级粒度，服务 UE 整体策略关联场景 |
| CAP-004 | PCF MBS 绑定管理 | 维护多播广播会话与 PCF 的关联，服务 MBS 策略路由 |
| CAP-005 | 绑定事件订阅 | 接收绑定变更订阅注册，为消费方追踪 PCF 切换提供登记入口 |
| CAP-006 | 绑定生命周期清理 | 周期回收过期与不活跃绑定，约束陈旧绑定无限累积 |
| CAP-007 | 按主体批量清理 | UE 去注册或 PCF 不可达时按 SUPI/PcfId 维度回收绑定 |
| CAP-008 | NRF 注册与发现 | 声明本 NF 可达性，使协作 NF 发现 bsf |

## 4. 质量属性
> 架构层质量要求（WHAT），非实现手段（HOW）。

| 属性 | 架构要求 |
|------|----------|
| 性能 | 查询路径走内存优先，写路径同步持久化；读写并发由读写锁保护避免互相阻塞 |
| 可靠性 | NRF 注册具备无限重试以容忍 NRF 临时不可达；持久化失败时绑定数据可重启回载；优雅终止顺序化避免资源泄漏 |
| 可用性 | 持久化层不可达时降级为纯内存运行不阻断启动；周期清理任务带 panic 恢复防中断 |
| 可扩展性 | 业务逻辑无状态，状态集中在持久化层；多副本部署的全局一致性由持久化层兜底（当前实现存在弱一致缺口） |
| 安全性 | 对外 SBI 支持 TLS，证书路径配置化；指标端口独立 TLS；当前 OAuth2 鉴权与 PII 字段加密为缺口项 |
| 可测试性 | UT 隔离 MongoDB 与 NRF 外部依赖；Handler 层与持久化层解耦便于桩替换 |
| 可观测性 | Prometheus 业务指标（绑定计数/事件/时延/发现）+ 分模块分级日志 + 指标独立端口 |

## 5. 提供的接口
> 架构层接口清单：接口名 + 协议 + 架构用途。

| 接口ID | 接口名 | 协议 | 架构用途 |
|--------|--------|------|----------|
| IF-001 | CreatePCFBinding | SBI (Nbsf_Management) | PCF 在 PDU 会话建立时登记绑定 |
| IF-002 | GetPCFBindings | SBI (Nbsf_Management) | SMF/NEF/AF 按多维条件反查 PCF |
| IF-003 | GetIndPCFBinding | SBI (Nbsf_Management) | 按 bindingId 查询单条绑定 |
| IF-004 | UpdateIndPCFBinding | SBI (Nbsf_Management) | 部分更新会话级绑定 |
| IF-005 | DeleteIndPCFBinding | SBI (Nbsf_Management) | 会话释放时删除绑定 |
| IF-006 | CreatePCFforUEBinding | SBI (Nbsf_Management) | PCF 登记 UE 级绑定 |
| IF-007 | GetPCFForUeBindings | SBI (Nbsf_Management) | 按 SUPI/GPSI 反查 UE 级绑定 |
| IF-008 | UpdateIndPCFforUEBinding | SBI (Nbsf_Management) | 部分更新 UE 级绑定 |
| IF-009 | DeleteIndPCFforUEBinding | SBI (Nbsf_Management) | 删除 UE 级绑定 |
| IF-010 | CreatePCFMbsBinding | SBI (Nbsf_Management) | PCF 登记 MBS 会话绑定 |
| IF-011 | GetPCFMbsBinding | SBI (Nbsf_Management) | 按 MBS Session ID 反查 PCF |
| IF-012 | ModifyIndPCFMbsBinding | SBI (Nbsf_Management) | 部分更新 MBS 绑定 |
| IF-013 | DeleteIndPCFMbsBinding | SBI (Nbsf_Management) | 删除 MBS 绑定 |
| IF-014 | CreateIndividualSubcription | SBI (Nbsf_Management) | 注册绑定事件订阅 |
| IF-015 | ReplaceIndividualSubcription | SBI (Nbsf_Management) | 整体替换订阅 |
| IF-016 | DeleteIndividualSubcription | SBI (Nbsf_Management) | 删除订阅 |
| IF-017 | Index | HTTP | 根路径健康检查 |

**契约详情**（method/path/请求响应模型/错误码）：见 `repos/bsf/.agent/interfaces.md`

## 6. 依赖的外部接口
> 架构层依赖声明：依赖哪个元素 + 架构用途。

| 依赖元素 | 架构用途 |
|----------|----------|
| nrf | NF 注册与反注册，使本元素可被 PCF/SMF/NEF/AF 发现 |
| MongoDB | 绑定数据持久化与启动回载，重启可恢复（外部基础设施） |
| prometheus | 业务指标 scrape（外部监控系统） |

**详细依赖清单与调用时机**：见 `repos/bsf/.agent/spec.md §4` 与 `dependencies.yaml`

## 7. 关键架构数据
> 仅列架构层显著的数据概念，用于理解元素的状态规模与持久化边界。

| 数据概念 | 架构作用 | 持久化 |
|----------|----------|--------|
| PCF 会话绑定 | PDU 会话↔PCF 映射的事实记录，是策略平面路由依据 | MongoDB（持久化）+ 内存缓存（启动回载） |
| PCF UE 绑定 | UE↔PCF 映射，服务 UE 级策略关联 | MongoDB + 内存缓存 |
| PCF MBS 绑定 | MBS 会话↔PCF 映射，服务 MBS 策略路由 | MongoDB + 内存缓存 |
| 绑定订阅 | 绑定变更事件订阅登记 | 内存（当前实现未持久化通知回调） |
| NF Profile | 本元素向 NRF 上报的实例信息（服务名/版本/PLMN） | 内存 + 配置 |

## 8. 部署与运行
> 架构层部署形态：进程/容器/副本策略 + 启动依赖 + 可观测出口。

- **部署形态**：独立进程（Go 二进制），可容器化（由 free5gc 顶层镜像打包）
- **副本策略**：单副本部署；多副本需依赖持久化层强一致与跨实例缓存失效机制（当前实现"内存 miss 不回查持久化层"对多副本一致性偏弱）
- **启动依赖**：NRF 可达（不可达将无限重试，不阻断本进程）、MongoDB 可达（不可达降级为纯内存运行）、配置文件与 TLS 证书就绪
- **可观测出口**：Prometheus 指标（独立端口，默认 mTLS）+ 分类别分级日志 + 业务指标四类（绑定计数/事件/时延/发现）
- **终止行为**：计划性终止时顺序停清理任务 → 关闭 SBI 服务 → 向 NRF 反注册 → 断开持久化连接，子任务带超时兜底防僵死
