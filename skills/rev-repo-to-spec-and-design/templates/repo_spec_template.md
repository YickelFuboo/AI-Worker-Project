---
repo_id: {repo_id}
language: {language}
build_system: {build_system}
template_version: "1.0"
last_modified: {last_modified}
last_modified_by: {skill_name}
confidence: high | medium | low
---

> 本文档为仓级规格说明（小模块场景，模块信息融合到仓级文档）。首次由 `rev-repo-to-spec-and-design` skill 逆向生成，后续可由 `fwd-doc-sync` 等正向 skill 增量刷新，由 `qa-artifact-auto-verify` skill 做一致性校验。
>
> **代码定位约定**：所有"代码证据"列使用 `文件路径::符号名` 格式（如 `internal/gmm/handler.go::HandleRegistrationRequest`、`go.mod::require gin-gonic/gin`），不使用行号。
>
> **分节置信度**：低置信章节末尾标注"本节置信度：低"，供后续校验优先复核。

## 1. 概述
{一段话描述本仓整体定位与核心功能}

## 2. 功能规格

### 2.1 业务功能

| 功能名称 | 功能说明 | 代码证据 |
|----------|----------|----------|
| {功能1} | {说明} | {文件路径}::{入口函数名} |

**关键规格与指标**
| 功能项 | 规格项 | 目标值 | 备注 | 代码证据 |
|--------|--------|--------|------|----------|
| {功能项1} | {规格项1} | {值} | {说明} | {文件路径}::{常量名/配置字段名} |

### 2.2 DFX 功能
{介绍本项目相关的非业务功能。spec 只写"有什么能力+目标指标"，设计手段归 design.md，编码约束归 rules.md。若某项不涉及，写"不涉及"}

#### 2.2.1 安全韧性
{能力说明}

**关键规格与指标**
| 指标 | 目标值 | 备注 | 代码证据 |
|------|--------|------|----------|
| {指标1} | {值} | {说明} | {文件路径}::{符号名} |

#### 2.2.2 可靠性
{同上}

#### 2.2.3 可维护性
{同上}

#### 2.2.4 隐私
{同上}

#### 2.2.5 性能
{同上}

#### 2.2.6 容量
{同上}

## 3. 对外接口契约
> 索引式清单，完整契约（通用格式/错误码/每接口 Request/Response/示例/接口映射）详见 `.agent/interfaces.md`。

| 接口名 | 类型 | 方法/操作 | 路径/签名 | 一句话说明 | interfaces.md 章节 |
|--------|------|-----------|-----------|------------|---------------------|
| {如 Communication-RegistrationStatusSubscribe} | SBI REST | POST | {/namf-comm/v1/...} | {一句话} | §2.{N} |

## 4. 外部依赖与跨仓协作
> 既有"外部依赖清单"，也有"调用方向+接口名+时机+对应仓 spec 引用"，供 fwd-cross-repo-impact 做跨仓变更分析。

### 4.1 外部依赖清单
| 依赖 NF/系统 | 协议 | 版本 | 用途 | 代码证据 |
|--------------|------|------|------|----------|
| {如 AUSF} | SBI REST | {3GPP R16} | {鉴权服务调用} | {internal/sbi/consumer/ausf_service.go::AusfService} |

### 4.2 跨仓调用关系
| 调用方向 | 接口/操作 | 调用时机 | 触发场景 | 对应仓 spec 引用 |
|----------|-----------|----------|----------|------------------|
| 本仓 → {AUSF} | {如 POST /nausf-auth/v1/ue-authentications} | {UE 注册鉴权流程} | {InitialRegistration} | `repos/ausf/.agent/spec.md` §3 |
| {SMF} → 本仓 | {如 POST /namf-comm/v1/...} | {N1N2 消息转发} | {PDUSessionEstablishment} | `repos/smf/.agent/spec.md` §3 |

## 5. 技术栈
| 类别 | 技术/库 | 版本 | 说明 | 代码证据 |
|------|---------|------|------|----------|
| 语言 | {语言} | {版本} | | {go.mod::go} |
| 构建系统 | {构建系统} | {版本} | | {构建文件路径} |
| 核心框架 | {框架1} | {版本} | | {go.mod::require 段} |
| 测试框架 | 详见 `.agent/DTFrame.md` | - | DT 框架信息独立产物 | - |

## 6. 构建与部署
> 供 fwd-version-packaging / fwd-env-topology-modeling 使用。

### 6.1 构建与运行
| 项目 | 内容 | 代码证据 |
|------|------|----------|
| 构建命令 | {如 `go build -o amf ./cmd/`} | {Makefile::build target} |
| 构建产物 | {如 bin/amf} | - |
| Dockerfile | {如 Dockerfile::多阶段构建} | {Dockerfile 路径} |
| 运行时依赖 | {如 依赖 NRF 启动、依赖 mongodb 存订阅} | {配置项位置} |
| 启动顺序 | {如 NRF → 本仓 → 其他 NF} | - |
| 配置文件 | {如 ./amfcfg.yaml} | {pkg/factory/config.go::Config} |

### 6.2 发布版本管理
| 项目 | 内容 | 代码证据 |
|------|------|----------|
| 版本号规则 | {如 SemVer vX.Y.Z} | {git tag 规范} |
| 发布分支 | {如 main / release/*} | - |
| 版本包产物 | {如 docker image / tar.gz} | {Makefile::release target} |
| 发布流程 | {如 tag → CI 构建 → 推镜像} | {.github/workflows/release.yml} |

### 6.3 安全配置
| 项目 | 内容 | 代码证据 |
|------|------|----------|
| TLS 配置 | {如 SBI 双向 TLS} | {pkg/factory/config.go::Sbi.Tls} |
| 证书管理 | {如证书路径/轮换机制} | {cmd/main.go::initLogFile} |
| 鉴权配置 | {如 NRF OAuth2} | {consumer/nrf_service.go} |
| 敏感信息处理 | {如密钥来源/环境变量} | {配置项位置} |

## 7. 目录概览
- `{目录1}/` - {一句话功能摘要}（{文件数} 文件）
- `{目录2}/` - {一句话功能摘要}（{文件数} 文件）

## 8. 模块清单
> 索引式清单，详细职责与设计归 design.md。

| 模块 | 一句话职责 | 详细设计位置 |
|------|-----------|--------------|
| {模块1} | {职责摘要} | design.md §6.{N} 或 `modules/{模块1}/design.md`（>800 文件阈值） |
