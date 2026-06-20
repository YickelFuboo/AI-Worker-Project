# Google Go Style Guide

> 来源：https://google.github.io/styleguide/go/  （含三份子文档：guide / decisions / best-practices）
> 形式：上方中文简要 + 下方分章全文（基于官方页面整理）。
> 适用：Google 内部 Go 代码规范，社区广泛引用作为权威参考。

---

## 中文简要

Google Go Style 由三份文档组成：
- **Style Guide**（canonical，规范级）：五条优先级——清晰 > 简单 > 简洁 > 可维护 > 一致。
- **Style Decisions**（normative，决策级）：命名、注释、import、error、格式、测试等具体规则。
- **Best Practices**（non-canonical，实践级）：实用建议，如命名、错误处理、日志、初始化、文档、变量声明、CLI、测试。

核心要点：
- **清晰是首要目标**：代码为读者写，不为作者写；用名字、注释、组织让意图明确。
- **最小机制原则**：先 core Go（channel/slice/map/loop/struct）→ 标准库 → 内部库 → 新依赖。
- **简洁**：高信噪比；表驱动测试减少重复；常见 idiom 让读者快速理解。
- **可维护**：API 可演进、文档化假设、接口与抽象需明确收益；名字可预测。
- **一致性**：不凌驾于清晰/简单之上，但可打破平局；包级一致性最重要。
- **格式化**：所有文件必须匹配 `gofmt` 输出；生成的代码也应格式化。
- **MixedCaps**：camelCase 而非下划线；导出 `MaxLength`，未导出 `maxLength`，禁止 `MAX_LENGTH`/`max_length`。
- **行长**：无固定上限；过长优先重构而非硬换行；不在缩进变化前断行；不拆 URL 等长字符串。
- **命名**：包名短小写无下划线，避免 `util`/`helper`/`common`；receiver 名短、与类型相关、一致、不用则省；常量用 MixedCaps 不用 ALL_CAPS 或 `k` 前缀；缩写一致大小写；避免 `Get` 前缀；名字长度随作用域/歧义增长；避免重复包/类型/函数/局部上下文。
- **注释**：导出顶级名必须有 doc 注释；完整句子、以被注释名开头；包注释紧邻 `package` 子句，每包一个；无固定列宽，保持可读；尽量提供可运行 example。
- **Import**：仅在冲突/生成 proto/清晰需要时重命名；分组顺序：标准库 → 其它包 → protobuf → 副作用 import；blank import 主要在 main 或测试；dot import 在 Google Go 代码中禁止。
- **Error**：失败操作以 `error` 作为最后返回值；错误文本小写开头、无句末标点；不要静默忽略 error；优先显式 error/bool 而非 in-band 哨兵值；先处理错误再走主路径。
- **语言与格式**：跨包 struct 字面量用命名字段；空 slice 用 `var t []T` 而非 `[]T{}`；避免多行 `if`/`for`/`switch`/函数签名造成缩进混乱；含 sync/buffer 字段的 struct 不要复制；不要用 panic 做普通错误处理；`Must` helper 主要用于启动/包初始化/测试 setup；goroutine 生命周期要明确且有界；优先同步 API；接口按需定义、保持小、accept interfaces return concrete types；泛型仅解决真问题；不为省小拷贝而传指针；value/pointer receiver 按正确性/可变性/复制安全/类型大小选择；`switch` case 末尾省略多余 `break`；引号字符串用 `%q`；Go 1.18+ 用 `any` 替代 `interface{}`。
- **测试**：失败信息含函数/输入/实际/期望；避免断言库掩盖上下文；`got` 在 `want` 前；复杂值用 `cmp.Equal`/`cmp.Diff`，新测试避免 `reflect.DeepEqual`；后续检查仍有意义时用 `t.Error` 继续，否则 `t.Fatal`；不要在非测试 goroutine 调 `t.Fatal`/`t.FailNow`。

---

## 全文

### 第一部分：Style Guide（canonical）

#### 五条优先级

可读 Go 代码由以下优先级治理，按顺序：
1. Clarity（清晰）
2. Simplicity（简单）
3. Concision（简洁）
4. Maintainability（可维护）
5. Consistency（一致性）

#### Style principles

##### Clarity

首要目标是让读者理解程序。清晰来自好名字、有用注释、组织。代码应为读者优化，而非作者。区分"做什么"与"为什么做"。要表达目的，可用更好名字、加针对性注释、引入空白、重构为更小函数/方法。

理由常通过名字体现，名字不够时需要注释——尤其微妙语言行为、业务逻辑、性能敏感实现、需谨慎使用的 API。

注释不应增加杂乱、重复明显代码、与实现矛盾、造成不必要维护负担。优先通过结构与名字自我解释的代码。注释最适合解释"为什么存在"。不寻常代码模式通常应仅为理由（如性能）而突出。引用标准库示例：`sort`、可运行 example、`strings.Cut`。

##### Simplicity

Go 代码对用户、读者、维护者都应直接。简单代码：易跟踪、避免不必要抽象、不需记忆先前细节、值流清晰、文档独立、错误与测试失败有用、避免聪明。

实现简单与 API 简单可能权衡——更复杂内部可接受若让 API 更易正确使用，但复杂应有意图且文档化。复杂在性能/多客户需求时可接受，但应伴随注释、文档、测试、example。若简单任务变得很复杂，是重新审视设计的信号。

###### Least mechanism

多种方案可选时，优先标准简单机制：
1. 核心 Go 特性适配处用：channels、slices、maps、loops、structs
2. 必要时用标准库
3. 然后才考虑现有内部库或新依赖

例：测试中直接覆盖 flag 绑定变量而非 `flag.Set`；用 `map[string]bool` 做集合成员判定，除非需更丰富集合行为。

##### Concision

简洁代码信噪比高，重要信息突出。噪声来自重复、过多语法、不清名字、不必要抽象、空白。表驱动测试减少重复同时突出用例差异。

常见 idiom 让读者快速移动。如 `if err := ...; err != nil` 立即可识别。若代码像常见 idiom 但行为不同，让差异更可见（如注释）。

```go
if err := doSomething(); err != nil {
    // ...
}
```

对比：

```go
if err := doSomething(); err == nil { // if NO error
    // ...
}
```

##### Maintainability

代码写后会被多次修改，应支持安全未来变更。可维护代码：易正确更新、API 可演进、文档化假设、抽象匹配问题、避免未用特性与不必要耦合、测试失败清晰。

接口与抽象可移除有用上下文，故应提供明确收益并文档化。避免把重要含义藏在微小视觉差异中。

问题示例：

```go
if user, err = db.UserByID(userID); err != nil {
    // ...
}
```

改进：

```go
u, err := db.UserByID(userID)
if err != nil {
    return fmt.Errorf("invalid origin user: %s", err)
}
user = u
```

另一个问题示例：

```go
leap := (year%4 == 0) && (!(year%100 == 0) || (year%400 == 0))
```

更清晰：

```go
// Gregorian leap years aren't just year%4 == 0.
// See https://en.wikipedia.org/wiki/Leap_year#Algorithm.
var (
    leap4   = year%4 == 0
    leap100 = year%100 == 0
    leap400 = year%400 == 0
)
leap := leap4 && (!leap100 || leap400)
```

helper 函数不应隐藏关键行为或边界情况。名字应可预测——同一概念参数/receiver 应同名。可维护代码也限制依赖，包括未文档化行为。设计应考虑未来演进，即便需更多前期结构。

##### Consistency

一致代码在视觉与行为上与附近及更广代码相似。一致性不凌驾清晰/简单/简洁/可维护之上，但可打破平局。包级一致性通常最重要，但本地习惯不应凌驾文档化风格或更广一致性。

#### Core guidelines

##### Formatting

所有 Go 文件必须匹配 `gofmt` 输出。生成的代码一般也应格式化（如 `format.Source`）。

##### MixedCaps

Go 名字用 camel case，不用下划线。例：导出常量 `MaxLength`；未导出常量 `maxLength`；不用 `MAX_LENGTH` 或 `max_length`。局部变量按未导出对待大小写。

##### Line length

无固定最大行长。若行太长，优先重构而非任意换行。若行已尽可能短，可保留长。不在缩进变化前断行（如函数声明/条件）。不拆长字符串（如 URL）只为适配短宽。

##### Naming

命名是上下文相关且部分基于判断。Go 名字常比其它语言短。名字应避免重复、考虑周围上下文、不重述已明显概念。更多命名细节见 Style Decisions。

##### Local consistency

指南未涵盖的风格点，作者可选风格，除非附近代码已建立一致方式。本地风格有效例：错误格式化用 `%s` 或 `%v`；用缓冲 channel 替代 mutex。本地风格无效例：强加固定行长规则；用断言测试库。

若现有本地风格与指南冲突且影响有限，评审可指出同时更大清理单独跟踪。当变更恶化偏差、扩大偏差、通过更多 API 暴露偏差或引入 bug 时，本地一致性不是有效借口——作者应清理、先重构或选不恶化问题的替代方案。

---

### 第二部分：Style Decisions（normative）

#### Naming

- 优先无下划线 Go 标识符，例外：仅生成包、测试/example、罕见底层 OS/cgo 互操作。
- 包名短、小写、不破单词；避免 `util`/`helper`/`common`。
- receiver 名短、与类型相关、一致、不用则省。
- 常量用 MixedCaps，不用 ALL_CAPS 或 `k` 前缀。
- 缩写保持一致大小写：`URL`/`ID`/`DB` 或对应小写。
- 避免 `Get` 前缀，除非"get"是领域概念一部分。
- 变量名长度随作用域大小与歧义增长。
- 避免重复包/类型/函数/本地上下文的名字。

#### Comments and documentation

- 导出顶级名需要 doc 注释。
- doc 注释应是完整句子，一般以被注释名开头。
- 包注释直接在 `package` 子句前，每包一个。
- 注释换行无固定列限制，保持可读。
- 有用时优先可运行 example。

#### Imports

- 仅在冲突、生成 proto 名、清晰需要时重命名 import。
- import 分组顺序：标准库 → 其它包 → protobuf import → 副作用 import。
- blank import 主要在 main 包或测试，少数例外。
- Google Go 代码中禁止 dot import。

#### Errors

- 操作失败时 `error` 作为最后返回值。
- 错误文本通常小写开头、省略句末标点。
- 不要无理由静默忽略 error。
- 优先显式 error/bool 返回而非 in-band 哨兵值。
- 先处理错误，主路径不缩进。

#### Language and formatting

- 跨包 struct 字面量用命名字段。
- 多行字面量保持大括号位置清晰。
- 清晰时省略复合字面量中重复类型名。
- 空本地 slice 声明优先 `nil` slice。
- 避免造成缩进混乱的多行 `if`/`for`/`switch` 与函数签名。
- 复制 struct 要小心，尤其含同步或 buffer 类字段。
- 不要用 panic 做普通错误处理。
- `Must` helper 主要用于启动/包初始化或测试 setup。
- goroutine 生命周期应清晰且有界。
- 优先同步 API；调用者可加并发。
- 接口按需定义、保持小、一般 accept interfaces return concrete types。
- 泛型仅在解决真问题时用，不要默认用。
- 不为避免小拷贝而用指针参数。
- value/pointer receiver 按正确性、可变性、复制安全、类型大小选择。
- `switch` case 末尾省略多余 `break`。
- 引号人类可读字符串输出用 `%q`。
- Go 1.18+ 新代码优先 `any` 而非 `interface{}`。

#### Common libraries

- flag 应在 main 类包定义，flag 名用 snake_case，Go 变量用 MixedCaps。
- Google 代码用类似 `glog` 的日志包。
- `context.Context` 显式传递时作为第一个参数。
- 不要把 ctx 存 struct，罕见接口约束情况除外。
- 不要发明自定义 context 类型。
- 密钥或安全敏感随机用 `crypto/rand`，不用 `math/rand`。

#### Testing

- 测试失败应标识失败函数、输入、实际结果、期望结果。
- 避免断言库掩盖上下文或产生弱诊断。
- "got" 在 "want" 前。
- 优先用 `cmp` 做整体结构比较。
- 避免对不稳定序列化输出的脆弱比较。
- 后续检查仍有意义时继续。
- 复杂值优先 `cmp.Equal`/`cmp.Diff`；新测试避免 `reflect.DeepEqual`。

---

### 第三部分：Best Practices（non-canonical）

#### Purpose

本文档提供应用 Google Go 风格指南的实用指导，是辅助指导，非 canonical 风格指南。

#### Naming

- 避免冗余函数/方法名。
- 不在函数名中重复包名。
- 不在方法名中重复 receiver 类型名。
- 返回值的函数优先名词性名。
- 普通 getter 避免 `Get` 前缀。
- 动作优先动词性名。
- 同功能不同类型函数追加类型名，如 `ParseInt`/`ParseInt64`。

#### Test doubles and helper packages

- 测试 helper 包常在生产包名后加 `test`，如 `creditcardtest`。
- 若有单一明显被 double 的类型，简短名如 `Stub` 可清晰。
- 多 double 类型或行为时用更明确名，如 `StubService`/`AlwaysDeclines`/`AlwaysCharges`。
- 测试局部变量名应让 double 与生产值可区分。

#### Shadowing

- 同作用域内复用变量在旧值不再需要时可接受。
- 嵌套作用域内短声明要小心——可能创建新变量并 shadow 外层。
- 长作用域避免隐藏常见包名的变量名，如 `url`。

#### Package naming and size

- 避免模糊包名 `util`/`helper`/`common`。
- 包名应描述包提供什么。
- 包边界应反映内聚、API 可用性、实现耦合。
- Go 无约定要求一类型一文件。
- 文件应足够聚焦，让维护者易找到代码。

#### Imports

- 生成 proto import 常用描述性别名结尾 `pb`。
- 生成 gRPC import 常用别名结尾 `grpc`。
- 歧义可能时优先清晰全词别名而非 `pb` 等极短名。

#### Error handling

- 把 error 当有意义值。
- 调用者需程序化区分条件时给 error 结构。
- 优先 sentinel error 或自定义 error 类型而非匹配错误字符串。
- 给 error 加有用上下文，但不要重复已有信息。
- 调用者应能 `errors.Is`/`errors.As` 检查包装 error 时用 `%w`。
- 不打算保留结构化 error 身份时用 `%v`。
- 一般 `%w` 放消息末尾，包装分类 sentinel 时前置可读性更好时除外。
- 避免既记录又返回同一 error，除非有明确理由。

#### Logging

- 日志消息应解释发生了什么并含有用诊断上下文。
- 让调用者决定是否记录返回的 error。
- 谨慎处理敏感信息。
- 节制使用 error 级日志。
- 守护昂贵 verbose 日志计算。

#### Initialization, panics, and fatal errors

- 初始化失败一般应传播到 `main`。
- 库优先返回 error 而非 panic。
- 程序中不可恢复不变量失败用 fatal 日志。
- 通常不鼓励从 panic 恢复，除非内部使用并在 API 边界转为 error。
- API 误用或不可达代码情况 panic 可接受。

#### Documentation

- 文档非显然行为，而非机械文档化每个参数。
- 除非行为不同，不重述普通 context 取消行为。
- 惊人时、API 提供时或接口契约一部分时文档化并发安全。
- 清晰文档化清理要求。
- 文档化重要 sentinel error 与具体 error 类型。
- 尽可能预览生成文档。
- 用 Godoc 格式约定：空行分段、缩进 example、可运行 example、标题。

#### Variable declarations

- 非零初始化局部变量优先 `:=`。
- 值待后用时用零值声明。
- 初始内容已知时用复合字面量。
- 需要零值指针时用 `new` 或取复合字面量地址。
- 写 map 前初始化。
- 仅在 justified 时用 size hint，尤其性能证据。
- 尽可能指定 channel 方向。

#### Function arguments

- 避免过长函数签名。
- 多选项时考虑 options struct。
- 仅当灵活性证明额外机制合理时用 variadic functional options。
- `context.Context` 不放 option struct。
- variadic options 通常应取显式值而非仅用 presence 作信号。

#### Command-line interfaces

- 子命令重的 CLI，`subcommands` 满足需求时推荐。
- `cobra` 常见且功能丰富但有陷阱。
- Cobra 命令应用 `cmd.Context()` 而非创建新 background context。

#### Tests

- 优先把 pass/fail 逻辑放 `Test` 函数。
- 避免隐藏测试逻辑的断言 helper 风格 API。
- 测试 helper 适合 setup 与 cleanup。
- 可能失败的 setup helper 可调 `t.Fatal`，应调 `t.Helper`。
- 验证逻辑重复时优先表驱动测试。
- 实际可行时集成测试用真实 transport。
- 可能继续时用 `t.Error`。
- 继续无意义时用 `t.Fatal`。
- 不要在测试 goroutine 外调 `t.Fatal`/`t.FailNow`。
- 验收测试 helper 包可通过返回 error 而非直接失败来验证用户实现。
