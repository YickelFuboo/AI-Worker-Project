---
repo_id: {repo_id}
language: {language}
last_modified: "{YYYY-MM-DD}"
last_modified_by: {skill_name}
confidence: {high|medium|low}
---

# {repo_id} DT 框架信息（逆向还原）

> 本文档集中记录本仓 DT（开发自验/单元测试）基础设施，供 `fwd-ut-generate` / `fwd-ut-execute-coverage` / `fwd-test-script-convert` 等正向 Skill 作为输入约束。首次由 `rev-repo-to-dt-frame` skill 逆向生成，后续可由 `fwd-doc-sync` 等正向 skill 增量刷新。

## 1. 测试框架

| 类别 | 库/工具 | 版本 | 用途 | 代码证据 |
|------|---------|------|------|----------|
| 测试运行器 | {如 go testing / pytest / jest / junit} | {版本} | 测试入口与执行 | {依赖声明位置} |
| 断言库 | {如 testify / should / expect} | {版本} | 断言 | {依赖声明位置} |
| BDD 库 | {如 goconvey / cucumber} | {版本} | BDD 风格用例（无则写"无"） | {依赖声明位置} |
| Mock 框架 | {如 gomock / mockgen / jest.mock} | {版本} | Mock 生成 | {依赖声明位置} |
| 覆盖率工具 | {如 go cover / coverage.py / istanbul} | {版本} | 覆盖率统计 | {依赖声明位置} |

## 2. DT 代码存放位置

| 类别 | 路径约定 | 命名规则 | 示例 | 备注 |
|------|----------|----------|------|------|
| 单元测试 | {如 internal/**/*_test.go} | {如 *_test.go} | {具体示例} | 与源码同包同目录 |
| 集成测试 | {如 tests/integration/} | {如 *_integration_test.go} | {具体示例} | 若无写"无" |
| 测试辅助 | {如 testutil/ / testhelpers/} | {如 helper.go} | {具体示例} | 公共 fixture / 工具 |

## 3. Mock 框架与 Mock 要求

### 3.1 Mock 框架
- **Mock 生成工具**：{如 go.uber.org/mock 的 mockgen / mockery}
- **生成命令**：{如 `go generate ./...` 或 `make mock`}
- **Mock 文件存放**：{如 `pkg/app/mock.go`、`pkg/service/mock.go`、`*_mock.go` 同目录}
- **Mock 生成模式**：{如 reflect 模式 / source 模式}

### 3.2 必须 Mock 的依赖（边界）

| 依赖类别 | 是否必须 Mock | Mock 方式 | 代码证据 |
|----------|---------------|-----------|----------|
| 外部 NF SBI 调用（如 AUSF/UDM/SMF） | 是 | 接口 mock | {接口路径 / mock 文件} |
| 数据库 / 文件 IO | 是 | 接口 mock / 内存实现 | {路径} |
| 时间 / 随机数 | 视场景 | 注入 Clock 接口 | {路径} |
| 内部纯函数 | 否 | 不 Mock | - |
| 内部有状态对象 | 视场景 | 接口抽象或测试替身 | {路径} |

### 3.3 Mock 使用约束
- {如：所有 SBI consumer 必须通过 `consumer/*.go` 中定义的接口调用，禁止直接调用 HTTP 客户端}
- {如：Mock 文件生成后必须提交到版本库，禁止 CI 中动态生成}

## 4. 测试数据组织

| 类别 | 路径 | 用途 | 代码证据 |
|------|------|------|----------|
| 测试 fixture | {如 testdata/} | {输入数据/期望输出} | {路径} |
| 测试工厂 | {如 testutil/factory.go} | {构造测试对象} | {路径} |
| 黄金文件 | {如 testdata/golden/} | {回归基线} | {路径} |

## 5. 执行命令

| 场景 | 命令 | 备注 |
|------|------|------|
| 全量执行 | {如 `go test ./...`} | 所有包 |
| 单包执行 | {如 `go test ./internal/gmm/...`} | 指定包 |
| 单用例执行 | {如 `go test -run TestHandleRegistrationRequest ./internal/gmm/`} | 指定函数 |
| 覆盖率执行 | {如 `go test -coverprofile=coverage.out ./...`} | 生成覆盖率文件 |
| Mock 生成 | {如 `go generate ./...`} | 生成 mock 文件 |
| Benchmark | {如 `go test -bench=. ./internal/gmm/`} | 性能基准 |

## 6. 覆盖率统计

| 项目 | 配置 | 代码证据 |
|------|------|----------|
| 统计命令 | {命令} | {Makefile / CI 配置位置} |
| 输出格式 | {如 coverprofile / lcov / cobertura} | - |
| 阈值 | {如 ≥ 70% 阻断 / 无阻断仅上报} | {CI 配置位置} |
| 上报目标 | {如 Codecov / Sonar / 内部} | {CI 配置位置} |
| 排除规则 | {如排除 generated_*.go / cmd/} | {CI 配置位置} |

## 7. CI 集成

| CI 平台 | 配置文件 | 测试阶段 | 触发条件 | 备注 |
|---------|----------|----------|----------|------|
| {如 GitHub Actions} | {如 .github/workflows/ci.yml} | {如 test job} | {如 push / PR} | - |

CI 中关键步骤片段（如有）：
```yaml
{粘贴 CI 配置中测试相关片段}
```

## 8. 已知问题与约束

| 问题/约束 | 影响 | 建议处理 | 代码证据 |
|-----------|------|----------|----------|
| {如部分包无 UT，覆盖率低于阈值} | {影响} | {建议} | {路径} |
| {如 Mock 文件与接口不同步} | {影响} | {建议} | {路径} |
