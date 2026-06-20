# Go 编码规范知识库

> 收录范围：Go 官方 + Google + Uber + 社区主流实践。
> 形式：每份规范上方中文简要 + 下方全文（原始或忠实整理）。
> 来源：仅取自 Go 官方（go.dev / golang.org）、Google（google.github.io/styleguide）、Uber（github.com/uber-go/guide）、golang-standards（github.com/golang-standards/project-layout）、golangci-lint 官方（golangci-lint.run）。

## 目录

| 文件 | 来源 | 主题 |
|---|---|---|
| `01_Effective_Go.md` | go.dev/doc/effective_go | Go 官方地道写作指南 |
| `02_Go_Code_Review_Comments.md` | go.dev/wiki/CodeReviewComments | 代码评审常见意见速查 |
| `03_Google_Go_Style_Guide.md` | google.github.io/styleguide/go/ | Google 内部 Go 风格规范（含 guide + decisions + best-practices 三份） |
| `04_Uber_Go_Style_Guide.md` | github.com/uber-go/guide | Uber 工程实践指南（社区企业级参考） |
| `05_项目布局约定.md` | github.com/golang-standards/project-layout | Go 项目目录布局约定（社区，非官方） |
| `06_静态检查工具规则.md` | gofmt/go vet/golangci-lint 官方 | 静态检查工具能力、规则清单、配置示例 |

## 推荐阅读顺序

1. **入门**：`01_Effective_Go.md`——建立 Go 地道写作直觉。
2. **评审**：`02_Go_Code_Review_Comments.md`——掌握评审术语与常见反模式。
3. **风格**：`03_Google_Go_Style_Guide.md`——理解五条优先级与具体规则。
4. **实战**：`04_Uber_Go_Style_Guide.md`——避开工程陷阱。
5. **结构**：`05_项目布局约定.md`——组织项目目录。
6. **工具**：`06_静态检查工具规则.md`——把规范变成 CI 门禁。

## 关键原则交叉对照

| 主题 | Effective Go | Code Review Comments | Google Style | Uber Style |
|---|---|---|---|---|
| 格式化 | 用 gofmt | 跑 gofmt/goimports | 必须匹配 gofmt 输出 | — |
| 命名 | 短、小写包名 | 不重复包名、缩写一致 | 五优先级 + receiver 一致 | — |
| 错误处理 | error 值返回 | 不丢弃 error、小写开头 | error 作为最后返回值 | 包装用 %w、Handle Once |
| 接口 | 隐式实现 | 消费者侧定义 | accept interfaces return concrete | 编译期断言 |
| 并发 | channel 通信 | goroutine 生命周期明确 | 优先同步 API | channel size 0/1 |
| 注释 | doc 注释完整句 | 完整句、以对象名开头 | 导出顶级名必须有 doc | — |
| Receiver | 指针 vs 值规则 | 不混用、不用 me/this/self | 按正确性/可变性选择 | — |

## 工具落地

```bash
# 编辑器：保存时跑 goimports
# 提交前：go vet + golangci-lint run
# CI：golangci-lint run + go test -race -coverprofile
```

详见 `06_静态检查工具规则.md` 中的 `.golangci.yml` 推荐配置与 Makefile/CI 集成示例。

## 维护说明

- 本目录于 2026-06-20 一次性抓取构建。
- 各规范均为最新主分支版本（截至抓取日）。
- 升级时重新从对应官方源拉取即可——URL 已列在每份文档顶部。
