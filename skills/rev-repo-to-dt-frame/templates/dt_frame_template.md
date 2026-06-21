---
repo_id: {repo_id}
language: {language}
last_modified: "{YYYY-MM-DDTHH:MM:SS±HH:MM}"
last_modified_by: {skill_name}
confidence: {high|medium|low}
---

# {repo_id} DT 框架信息

> 本文档集中记录本仓 DT（开发自验/单元测试）基础设施，供 `fwd-ut-generate` / `fwd-ut-execute-coverage` / `fwd-test-script-convert` 等正向 Skill 作为输入约束。首次由 `rev-repo-to-dt-frame` skill 逆向生成，后续可由 `fwd-doc-sync` 等正向 skill 增量刷新。
>
> **代码定位约定**：所有"代码证据"列使用 `文件路径::符号名` 格式，不使用行号。

## 1. 测试框架

| 类别 | 库/工具 | 版本 | 用途 | 代码证据 |
|------|---------|------|------|----------|
| 测试运行器 | {如 go testing / pytest / jest / junit} | {版本} | 测试入口与执行 | {go.mod::require 段} |
| 断言库 | {如 testify / should / expect} | {版本} | 断言 | {go.mod::require 段} |
| BDD 库 | {如 goconvey / cucumber} | {版本} | BDD 风格用例（无则写"无"） | {go.mod::require 段} |
| 覆盖率工具 | {如 go cover / coverage.py / istanbul} | {版本} | 覆盖率统计 | {go.mod::require 段} |

## 2. 测试防护网分层
> UT / IT / E2E 分层与门禁，供 fwd-ut-generate 判断用例归属、供 qa-stage-gate-check 判断门禁。

| 层级 | 范围 | 执行环境 | Mock 边界 | 门禁要求 | 代码证据 |
|------|------|----------|-----------|----------|----------|
| UT 单元测试 | {如 单函数/单模块} | {如 本地无依赖} | {如 全部外部依赖 Mock} | {如 覆盖率 ≥ 70% 阻断} | {internal/**/*_test.go} |
| IT 集成测试 | {如 跨模块/单仓内多模块} | {如 本地 + 内存 mock 服务} | {如 仅外部 NF Mock} | {如 必须通过} | {tests/integration/} |
| E2E 端到端 | {如 跨仓/全链路} | {如 独立环境 + 真实依赖} | {如 不 Mock} | {如 版本发布前必须通过} | {tests/e2e/} |

分层原则：
- {如：UT 必须快（< 1s/例），不得依赖网络/磁盘；IT 可启内存服务；E2E 走真实部署}
- {如：新增功能必须先有 UT，IT/E2E 按场景补充}

## 3. DT 代码存放位置与用例组织约定

### 3.1 存放位置
| 类别 | 路径约定 | 命名规则 | 示例 | 备注 |
|------|----------|----------|------|------|
| 单元测试 | {如 internal/**/*_test.go} | {如 *_test.go} | {具体示例} | 与源码同包同目录 |
| 集成测试 | {如 tests/integration/} | {如 *_integration_test.go} | {具体示例} | 若无写"无" |
| 测试辅助 | {如 testutil/ / testhelpers/} | {如 helper.go} | {具体示例} | 公共 fixture / 工具 |

### 3.2 用例组织约定
> fwd-ut-generate 生成 UT 时需遵循仓内既有风格。

| 维度 | 约定 | 代码证据 |
|------|------|----------|
| 用例组织形式 | {如 表驱动 table-driven / 独立函数 / 子测试 t.Run} | {示例 _test.go 文件} |
| 断言风格 | {如 testify/assert / require / convey.So} | {示例} |
| 结构约定 | {如 Arrange-Act-Assert / Given-When-Then} | {示例} |
| 命名约定 | {如 TestXxx_场景_预期结果} | {示例} |
| TestMain 约定 | {如全局 setup/teardown 是否使用} | {文件路径}::TestMain |

## 4. Mock 框架与 Mock 要求

### 4.1 Mock 框架
- **Mock 生成工具**：{如 go.uber.org/mock 的 mockgen / mockery}
- **生成命令**：{如 `go generate ./...` 或 `make mock`}
- **Mock 文件存放**：{如 `pkg/app/mock.go`、`*_mock.go` 同目录}
- **Mock 生成模式**：{如 reflect 模式 / source 模式}

### 4.2 必须 Mock 的依赖（边界）
| 依赖类别 | 是否必须 Mock | Mock 方式 | 代码证据 |
|----------|---------------|-----------|----------|
| 外部 NF SBI 调用 | 是 | 接口 mock | {接口路径}::{接口名} |
| 数据库 / 文件 IO | 是 | 接口 mock / 内存实现 | {路径} |
| 时间 / 随机数 | 视场景 | 注入 Clock 接口 | {路径} |
| 内部纯函数 | 否 | 不 Mock | - |
| 内部有状态对象 | 视场景 | 接口抽象或测试替身 | {路径} |

### 4.3 已有 Mock 清单
> fwd-ut-generate 决定"复用既有 Mock 还是新建"的依据。

| 接口名 | Mock 文件 | 对应模块 | 是否随接口同步 | 代码证据 |
|--------|----------|----------|----------------|----------|
| {如 App} | {pkg/app/mock.go} | {pkg/app} | 是 | {文件路径}::{接口名} |

### 4.4 Mock 使用约束
- {如：所有 SBI consumer 必须通过 `consumer/*.go` 中定义的接口调用，禁止直接调用 HTTP 客户端}
- {如：Mock 文件生成后必须提交到版本库，禁止 CI 中动态生成}

## 5. 测试数据组织

| 类别 | 路径 | 用途 | 代码证据 |
|------|------|------|----------|
| 测试 fixture | {如 testdata/} | {输入数据/期望输出} | {路径} |
| 测试工厂 | {如 testutil/factory.go} | {构造测试对象} | {文件路径}::{函数名} |
| 黄金文件 | {如 testdata/golden/} | {回归基线} | {路径} |

## 6. 测试环境依赖
> fwd-ut-execute-coverage 执行前需检查的环境前提。

| 依赖项 | 是否必须 | 用途 | 准备方式 | 代码证据 |
|--------|----------|------|----------|----------|
| {如 证书文件} | 是/否 | {如 mutual TLS 测试} | {路径或生成命令} | {测试文件}::TestMain |
| {如 端口 X} | 是/否 | {如 mock 服务器监听} | {说明} | {测试文件} |
| {如 外部 mock 服务} | 是/否 | {如 mock NRF} | {启动命令} | {测试文件} |

## 7. 执行命令

| 场景 | 命令 | 备注 |
|------|------|------|
| 全量执行 | {如 `go test ./...`} | 所有包 |
| 单包执行 | {如 `go test ./internal/gmm/...`} | 指定包 |
| 单用例执行 | {如 `go test -run TestHandleRegistrationRequest ./internal/gmm/`} | 指定函数 |
| 覆盖率执行 | {如 `go test -coverprofile=coverage.out ./...`} | 生成覆盖率文件 |
| Mock 生成 | {如 `go generate ./...`} | 生成 mock 文件 |
| Benchmark | {如 `go test -bench=. ./internal/gmm/`} | 性能基准 |

## 8. 覆盖率统计

| 项目 | 配置 | 代码证据 |
|------|------|----------|
| 统计命令 | {命令} | {Makefile::test target} 或 {CI 配置位置} |
| 输出格式 | {如 coverprofile / lcov / cobertura} | - |
| 阈值 | {如 ≥ 70% 阻断 / 无阻断仅上报} | {CI 配置位置} |
| 上报目标 | {如 Codecov / Sonar / 内部} | {CI 配置位置} |
| 排除规则 | {如排除 generated_*.go / cmd/} | {CI 配置位置} |

## 9. CI 集成

| CI 平台 | 配置文件 | 测试阶段 | 触发条件 | 备注 |
|---------|----------|----------|----------|------|
| {如 GitHub Actions} | {如 .github/workflows/ci.yml} | {如 test job} | {如 push / PR} | - |

CI 中关键步骤片段（如有）：
```yaml
{粘贴 CI 配置中测试相关片段}
```

## 10. 已知问题与约束

| 问题/约束 | 影响 | 建议处理 | 代码证据 |
|-----------|------|----------|----------|
| {如部分包无 UT，覆盖率低于阈值} | {影响} | {建议} | {文件路径}::{符号名} |
