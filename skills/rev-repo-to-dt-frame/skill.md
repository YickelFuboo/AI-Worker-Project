# 代码仓 DT 框架信息提取

## 功能描述

从存量代码仓中逆向提取 DT（Development Test，开发自验/单元测试）框架相关信息，生成 `repos/{仓名}/.agent/DTFrame.md`。该文件集中记录测试框架、DT 代码存放位置、Mock 框架与 Mock 要求、测试数据组织、执行命令、覆盖率统计方式等，供 `fwd-ut-generate` / `fwd-ut-execute-coverage` / `fwd-test-script-convert` 等正向 Skill 在生成与执行 UT 时作为输入约束，避免每个 Skill 重复扫描仓内测试基础设施。

## 所属 Agent

实现逆向 Agent

## 适用场景

- 存量项目逆向还原时，需明确仓内 DT 基础设施以指导后续 UT 增量生成
- 多仓服务统一 UT 规范时，需对比各仓 DT 框架差异（不同仓可能用不同测试库/Mock 库）
- 现有 spec.md 头部仅记录测试框架名称版本，不足以指导 UT 生成，需独立产物承载详细 DT 信息
- 作为 `rev-repo-to-spec-and-design` 的补充，在仓级 `spec.md` / `design.md` 生成后触发

## 工作方式

### 执行步骤

**模式判定**：检查 `repos/{仓名}/.agent/DTFrame.md` 是否存在且 YAML 头部有 `last_modified`。存在 → 进入增量更新模式；不存在 → 进入首次生成模式。

#### 首次生成模式

1. **前置检查**：确认 `repos/{仓名}/.agent/spec.md` 已生成，识别语言与构建系统
2. **扫描测试基础设施**：
   - 依赖声明文件（`go.mod` / `package.json` / `requirements.txt` / `pom.xml`）→ 识别测试框架、断言库、Mock 框架、覆盖率工具
   - 测试文件分布（`*_test.go` / `*.test.ts` / `test_*.py` / `*Test.java`）→ 识别 DT 代码存放位置与命名约定
   - Mock 生成产物（`*_mock.go` / `*.mock.ts` / `mocks/` 目录）→ 识别 Mock 框架与生成方式（代码生成 vs 手写）
   - 测试数据目录（`testdata/` / `__fixtures__/` / `resources/test/`）→ 识别测试数据组织方式
   - CI 配置（`.github/workflows/` / `.gitlab-ci.yml` / `Jenkinsfile`）→ 识别测试执行命令、覆盖率阈值、上报方式
   - Makefile / scripts/ 中的 test target → 识别本地执行入口
3. **提取 Mock 要求**：从既有测试代码中归纳"必须 Mock 的依赖"（外部 NF 调用、数据库、文件 IO 等）、Mock 生成方式（接口级 vs 函数级）、Mock 文件归属目录
4. **提取覆盖率规则**：识别覆盖率统计命令、阈值（CI 中是否阻断）、上报目标（Codecov / 内部 Sonar）
5. **生成产物**：按模板输出 `repos/{仓名}/.agent/DTFrame.md`
6. **更新仓级 spec.md**：将 spec.md 头部 `test_framework` 字段保留为简短摘要（框架名+版本），详细 DT 信息以"详见 DTFrame.md"指引
7. **更新逆向报告**：记录 DT 框架识别结论与置信度

#### 增量更新模式

1. **解析时间锚**：读取 `DTFrame.md` YAML 头部 `last_modified`
2. **定位锚点提交**：`git log --before="<last_modified>" -1 --format=%H`
3. **变更探测**：`git diff <锚点提交>..HEAD --name-status`，过滤测试相关文件
4. **变更分类与章节映射**：
   - 依赖声明文件变更（测试/Mock 库新增或版本变更）→ 测试框架表、Mock 框架小节
   - 新增/删除测试文件 → DT 代码存放位置（若命名约定扩展）、Mock 要求（若引入新 Mock 边界）
   - CI 配置变更 → 执行命令、覆盖率统计、CI 集成
   - Makefile/scripts test target 变更 → 执行命令
   - 新增 testdata 目录或 fixture 文件 → 测试数据组织
   - 删除测试文件 → 若对应 Mock 边界已消失，同步从 Mock 要求表中移除
   - 纯业务源码变更（非测试相关）→ 跳过
5. **刷新决策**：
   - 无变更 → 不刷新，仅更新 `last_modified` 为检查时间并记录"无变更"
   - 局部变更 → 仅重读受影响测试相关文件，刷新对应章节
   - 测试框架/Mock 框架整体替换 → 触发首次生成式全量刷新
6. **刷新执行**：按模板比对现有内容，合并更新
7. **更新时间戳与报告**：更新 `last_modified`，输出差异摘要

### 注意事项

- DTFrame.md 聚焦"如何写 UT / 如何执行 UT / 如何 Mock"，不重复 spec.md 的业务功能与 design.md 的设计细节
- Mock 要求需明确"必须 Mock 的边界"（如外部 SBI 调用必须 Mock、内部纯函数不得 Mock），避免 UT 沦为集成测试
- 测试执行命令需区分"全量执行 / 单包执行 / 覆盖率执行"三种场景
- 仓内若无任何测试代码，DTFrame.md 仍需生成，记录"无存量 UT，建议框架为 X"并在置信度标注 low
- 置信度评估：依赖声明与 CI 配置中明确的为高，依据文件命名约定推断的为中，无存量测试代码的为低
- 增量模式下，业务源码变更不触发 DTFrame.md 刷新；仅测试基础设施相关变更触发
- 删除测试文件若导致某 Mock 边界不再有使用方，应标注"待人工确认是否废弃"而非直接删除

### 输出要求

- 输出路径：`repos/{仓名}/.agent/DTFrame.md`
- 严格按模板格式输出：`templates/dt_frame_template.md`
- YAML 元数据头部包含 `repo_id`、`language`、`last_modified`、`last_modified_by`（写入执行 skill 名，如 `rev-repo-to-dt-frame` / `fwd-doc-sync`）、`confidence`
- `last_modified` 格式为 ISO 8601 带时区（如 `2026-06-21T14:30:00+08:00`），用于增量模式下 `git log --before="<last_modified>"` 精确定位锚点提交；仅日期精度会导致同日内多次提交无法区分
- 正文分节：测试框架 / DT 代码存放位置与用例组织约定 / Mock 框架与 Mock 要求（含已有 Mock 清单）/ 测试数据组织 / 测试环境依赖 / 执行命令 / 覆盖率统计 / CI 集成 / 已知问题
- 每节给出具体的代码证据（文件路径::符号名格式，如 `go.mod::require testify`、`.github/workflows/ci.yml::test job`；不使用行号）
- 同步更新仓级 spec.md：将 `test_framework` 字段保留为摘要形式（如 "go testing + testify + goconvey + gomock"），正文技术栈表的测试框架行改为"详见 DTFrame.md"
