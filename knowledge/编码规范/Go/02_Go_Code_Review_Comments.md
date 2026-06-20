# Go Code Review Comments

> 来源：https://go.dev/wiki/CodeReviewComments （原 GitHub wiki 已迁移至 go.dev）
> 形式：上方中文简要 + 下方全文（基于官方 wiki 整理）。
> 适用：Go 代码评审者与作者共用术语速查。

---

## 中文简要

这是 Go 官方维护的"代码评审常见意见清单"，把评审中重复出现的意见提炼成短词，评审者引用短词即可指向详细解释。它补充 Effective Go，不替代之。要点：

- **Gofmt**：先跑 `gofmt`/`goimports` 解决机械风格问题。
- **Comment Sentences**：注释是完整句子，以被注释对象名开头，以句号结尾。
- **Contexts**：`context.Context` 作为第一个参数显式传递；不要塞进 struct；不要造自定义 Context 类型。
- **Copying**：方法绑定在 `*T` 上的类型不要值复制（如 `bytes.Buffer`）。
- **Crypto Rand**：密钥不要用 `math/rand`，用 `crypto/rand`。
- **Declaring Empty Slices**：用 `var t []string`（nil slice）而不是 `t := []string{}`。
- **Doc Comments**：所有导出顶级名都应有 doc 注释。
- **Don't Panic**：不要用 `panic` 做正常错误处理。
- **Error Strings**：错误字符串小写开头、不加句末标点。
- **Goroutine Lifetimes**：goroutine 生命周期必须明确——何时退出、是否退出。
- **Handle Errors**：不要用 `_` 丢弃 error；检查、处理、返回或 panic。
- **Imports**：标准库优先，分组，空行分隔；不要随便重命名。
- **Import Blank / Import Dot**：blank import 仅用于副作用（main 包或测试）；dot import 仅在循环依赖测试中用。
- **In-Band Errors**：不要用 `-1`/`""`/`nil` 表示错误，加返回值或 error。
- **Indent Error Flow**：错误优先处理并 return，主路径不缩进。
- **Initialisms**：缩写保持大小写一致（`URL`/`url`，`ServeHTTP` 而非 `ServeHttp`）。
- **Interfaces**：接口定义在消费者侧，不在生产者侧；返回具体类型而非接口。
- **Line Length**：无固定限制，按语义换行。
- **Mixed Caps**：用 mixedCaps 而非下划线或全大写。
- **Named Result Parameters**：仅在同类型多返回值或文档需要时命名。
- **Naked Returns**：仅短函数可用裸 return。
- **Package Comments / Package Names**：包注释紧邻 `package` 子句；包名短、小写；避免 `util`/`common`/`misc`/`api`/`types`/`interfaces`。
- **Pass Values**：不要为节省几字节而传指针（string/interface 是定长值）。
- **Receiver Names / Type**：receiver 名短且反映身份（如 `c *Client`）；不要用 `me`/`this`/`self`；map/func/chan 不用指针 receiver；slice 不 reslice 不用指针；含 `sync.Mutex` 用指针；不要混用值/指针 receiver。
- **Synchronous Functions**：优先同步函数，让调用者决定是否并发。
- **Useful Test Failures**：测试失败信息含函数名、输入、实际值、期望值，顺序 `got; want`。
- **Variable Names**：局部变量短，越远离声明越要描述性。

---

## 全文

> 本页收集 Go 代码评审中常见的意见，让评审者能以简短术语指向详细解释。它补充 [Effective Go](https://go.dev/doc/effective_go)。更多测试指导见 [Go Test Comments](https://go.dev/wiki/TestComments)，更长的风格指南见 [Google Go Style Guide](https://google.github.io/styleguide/go/)。

### Gofmt

跑 `gofmt` 自动修复大部分机械风格问题。`goimports` 是 `gofmt` 超集，还会增删 import。

### Comment Sentences

文档注释应是完整句子，以被注释对象名开头，以句号结尾：

```go
// Request represents a request to run a command.
type Request struct { ... }

// Encode writes the JSON encoding of req to w.
func Encode(w io.Writer, req *Request) { ... }
```

### Contexts

`context.Context` 携带凭据、tracing、deadline、cancellation 跨 API 与进程边界。使用 context 的函数应将其作为第一个参数：

```go
func F(ctx context.Context, /* other arguments */) {}
```

指导：
- 沿调用链显式传递 ctx。
- 仅在合适时用 `context.Background()`。
- 不要在 struct 加 `Context` 字段；把 ctx 传给需要的方法。
- 不要造自定义 context 类型。
- 函数签名中除 `context.Context` 外不要用其它 context 接口。
- 应用数据通常放参数/receiver/全局；仅在真正合适时放 ctx value。
- Context 不可变，可跨调用共享。

### Copying

避免从其它包复制可能引起别名问题的值。例如 `bytes.Buffer` 含 `[]byte`，复制后副本与原值可能共享存储。

通用规则：

> 若类型 `T` 的方法绑定在 `*T` 上，不要复制 `T` 的值。

### Crypto Rand

不要用 `math/rand`/`math/rand/v2` 生成密钥，即便是一次性的。用 `crypto/rand`：

```go
import (
    "crypto/rand"
    "fmt"
)

func Key() string {
    return rand.Text()
}
```

需要文本时用 `crypto/rand.Text`，或用 `encoding/hex`/`encoding/base64` 编码随机字节。

### Declaring Empty Slices

优先：

```go
var t []string
```

而非：

```go
t := []string{}
```

前者是 nil slice，后者非 nil 但长度 0。功能上通常等价，但 nil slice 是首选风格。

例外：有时需要非 nil 空 slice，如 JSON 编码——nil slice 编码为 `null`，`[]string{}` 编码为 `[]`。避免设计区分 nil 与空 slice 的接口。

### Doc Comments

所有顶级导出名都应有 doc 注释。非平凡的非导出类型/函数也应加注释。见 Effective Go 的注释约定。

### Don't Panic

不要用 `panic` 做正常错误处理。用 `error` 与多返回值。

### Error Strings

错误字符串不应大写开头、不应以标点结尾（除非以专有名词/缩写开头）：

```go
fmt.Errorf("something bad")
```

而非：

```go
fmt.Errorf("Something bad")
```

这便于干净地包装上下文：

```go
log.Printf("Reading %s: %v", filename, err)
```

日志消息不同——日志是面向行的。

### Examples

新包应包含用法示例：可运行的 `Example` 或展示完整调用序列的简单测试。

### Goroutine Lifetimes

启动 goroutine 时要明确它何时/是否退出。goroutine 可能因阻塞在 channel 发送/接收而泄漏——即使 channel 不可达，GC 也不会终止阻塞的 goroutine。

游离 goroutine 的问题：
- 向已关闭 channel 发送会 panic
- 输入被修改导致 data race
- 不可预测的内存使用

保持并发代码简单。若生命周期不明显，文档说明 goroutine 何时/为何退出。

### Handle Errors

不要用 `_` 丢弃 error。函数返回 error 时：检查、处理、返回，或真正异常时 panic。

### Imports

避免重命名 import，除非为避免名冲突。优先重命名本地/项目特定的 import。import 分组用空行分隔，标准库优先：

```go
package main

import (
    "fmt"
    "hash/adler32"
    "os"

    "github.com/foo/bar"
    "rsc.io/goversion/version"
)
```

`goimports` 自动处理。

### Import Blank

仅副作用 import：

```go
import _ "pkg"
```

应仅出现在程序 main 包或需要的测试中。

### Import Dot

dot import 可用于因循环依赖不能放进被测包的测试：

```go
package foo_test

import (
    "bar/testutil" // also imports "foo"
    . "foo"
)
```

除此之外避免：

```go
import . "pkg"
```

它使代码难以阅读——标识符可能来自当前包或 dot-import 的包。

### In-Band Errors

避免用 `-1`/`""`/`nil` 等特殊值表示错误（有歧义）。不要：

```go
// Lookup returns the value for key or "" if there is no mapping for key.
func Lookup(key string) string
```

而用额外返回值：

```go
// Lookup returns the value for key or ok=false if there is no mapping for key.
func Lookup(key string) (value string, ok bool)
```

防止误用：

```go
Parse(Lookup(key)) // compile-time error
```

鼓励显式处理：

```go
value, ok := Lookup(key)
if !ok {
    return fmt.Errorf("no value for %q", key)
}
return Parse(value)
```

需要解释时用 `error`，不需要时用 `bool`。指示值应为最后一个返回值。

### Indent Error Flow

主路径最小缩进，先处理错误。避免：

```go
if err != nil {
    // error handling
} else {
    // normal code
}
```

优先：

```go
if err != nil {
    // error handling
    return
}
// normal code
```

若 `if` 带初始化语句：

```go
if x, err := f(); err != nil {
    // error handling
    return
} else {
    // use x
}
```

考虑把声明移出：

```go
x, err := f()
if err != nil {
    // error handling
    return
}
// use x
```

### Initialisms

缩写/首字母缩略词应保持大小写一致：
- `URL` 或 `url`
- `ServeHTTP`，不是 `ServeHttp`
- `appID`，不是 `appId`

多个缩写：

```go
xmlHTTPRequest
XMLHTTPRequest
```

生成的 protobuf 代码豁免。

### Interfaces

接口通常属于使用它的包，而非实现它的包。实现包应返回具体类型，便于添加方法而无需大规模重构。不要为"mock"而在生产者侧定义接口。

消费者侧接口：

```go
package consumer

type Thinger interface {
    Thing() bool
}

func Foo(t Thinger) string { … }
```

测试 fake：

```go
package consumer

type fakeThinger struct{ … }

func (t fakeThinger) Thing() bool { … }

if Foo(fakeThinger{…}) == "x" { … }
```

避免生产者侧接口：

```go
// DO NOT DO IT!!!
package producer

type Thinger interface {
    Thing() bool
}

type defaultThinger struct{ … }

func (t defaultThinger) Thing() bool { … }

func NewThinger() Thinger {
    return defaultThinger{ … }
}
```

优先返回具体类型：

```go
package producer

type Thinger struct{ … }

func (t Thinger) Thing() bool { … }

func NewThinger() Thinger {
    return Thinger{ … }
}
```

### Line Length

Go 无硬性行长限制。避免过长行，但也别为短而强行断行。按语义而非固定列数断行。若行太长，考虑更短的名字、更少参数、更好的函数边界、改进语义。

### Mixed Caps

用 mixedCaps 而非下划线或全大写：

```go
maxLength
```

而非：

```go
MaxLength
MAX_LENGTH
```

同时遵循缩写规则。

### Named Result Parameters

考虑命名返回值在文档中的呈现。避免不必要重复：

```go
func (n *Node) Parent1() (node *Node) {}
func (n *Node) Parent2() (node *Node, err error) {}
```

优先：

```go
func (n *Node) Parent1() *Node {}
func (n *Node) Parent2() (*Node, error) {}
```

同类型多返回值时命名有用：

```go
func (f *Foo) Location() (float64, float64, error)
```

不如：

```go
// Location returns f's latitude and longitude.
// Negative values mean south and west, respectively.
func (f *Foo) Location() (lat, long float64, err error)
```

不要仅为避免声明局部变量而命名返回值。deferred 闭包需要时命名是合理的。

### Naked Returns

裸 return 返回命名结果值：

```go
func split(sum int) (x, y int) {
    x = sum * 4 / 9
    y = sum - x
    return
}
```

极短函数可用裸 return。中等长度函数应显式。

### Package Comments

包注释必须紧邻 `package` 子句，无空行：

```go
// Package math provides basic constants and mathematical functions.
package math
```

块注释形式：

```go
/*
Package template implements data-driven templates for generating textual
output such as HTML.
....
*/
package template
```

`package main` 注释可用多种形式：

```go
// Binary seedgen ...
package main
```

```go
// Command seedgen ...
package main
```

```go
// Program seedgen ...
package main
```

```go
// The seedgen command ...
package main
```

```go
// Seedgen ...
package main
```

包注释是公开的，应用规范英文。

### Package Names

避免在导出标识符中重复包名。包 `chubby` 用：

```go
chubby.File
```

而非：

```go
chubby.ChubbyFile
```

避免无意义包名：`util`/`common`/`misc`/`api`/`types`/`interfaces`。

### Pass Values

不要为省几字节而传指针。避免不必要指针：

```go
*string
*io.Reader
```

string 与 interface 是定长值，可直接传。本建议不适用于大 struct 或可能增长的小 struct。

### Receiver Names

receiver 名应反映身份，常一两个字母：

```go
func (c *Client) Do() {}
```

避免通用名 `me`/`this`/`self`。保持一致：一个方法用 `c`，其它方法不应改用 `cl`。

### Receiver Type

值/指针 receiver 指引：
- receiver 是 map/func/chan，不要用指针。
- receiver 是 slice 且方法不 reslice/reallocate，不要用指针。
- 方法修改 receiver，用指针。
- struct 含 `sync.Mutex` 等，用指针。
- receiver 是大 struct/array，指针更高效。
- receiver 更新需对外可见，用指针。
- receiver 含指向可变数据的指针，为清晰用指针。
- receiver 是小不可变值类型，值 receiver 可行。
- 不要混用 receiver 类型。
- 拿不准，用指针。

### Synchronous Functions

优先同步函数：直接返回结果，或返回前完成回调/channel 操作。好处：
- goroutine 局部化
- 生命周期易推理
- 更少泄漏与 data race
- 更易测试

调用者可在 goroutine 中调用以加并发。在调用侧去除不必要并发更难。

### Useful Test Failures

测试失败应显示：哪里错、输入、实际结果、期望结果。典型 Go 风格：

```go
if got != tt.want {
    t.Errorf("Foo(%q) = %d; want %d", tt.in, got, tt.want)
}
```

顺序是 actual 然后 expected。基于 helper 的测试可用独立测试函数：

```go
func TestSingleValue(t *testing.T) { testHelper(t, []int{80}) }
func TestNoValues(t *testing.T)    { testHelper(t, []int{}) }
```

调试测试的人可能不是你或你的团队，所以让失败有用。

### Variable Names

Go 变量名应短而非长，特别是有限作用域的局部变量。优先 `c`/`i`/`r` 而非 `lineCount`/`sliceIndex`。

基本规则：

> 名字离声明越远，越要描述性。

例如：method receiver 一两个字母；循环索引 `i`；reader `r`；不寻常值与全局变量用更描述性名字。
