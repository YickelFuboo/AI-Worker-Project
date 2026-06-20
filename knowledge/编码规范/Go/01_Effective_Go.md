# Effective Go

> 来源：https://go.dev/doc/effective_go
> 形式：上方中文简要 + 下方全文（基于官方页面整理）。
> 适用：所有 Go 开发者，写"地道的 Go"而非"翻译自其他语言的 Go"。

---

## 中文简要

Effective Go 是 Go 官方出品的"地道 Go 写作指南"，强调**用 Go 自己的方式写 Go**，不要把 C++/Java/Python 的习惯直接搬过来。核心要点：

- **格式化**：用 `gofmt`，tab 缩进，无固定行长限制；`if/for/switch` 不写括号；左大括号必须与关键字同行。
- **注释**：doc 注释紧跟声明，以被注释对象名开头，完整句子。
- **命名**：包名短、小写、单词；导出名首字母大写；getter 不加 `Get` 前缀；单方法接口用 `-er` 后缀（`Reader`/`Writer`）。
- **控制结构**：`if` 可带初始化语句；避免 `else` 后接 `return`；`switch` 默认不 fallthrough；`switch` 无表达式等价于 `switch true`；类型 `switch` 用 `.(type)`。
- **函数**：多返回值（含 error）；命名返回值便于 doc 与裸 `return`；`defer` LIFO 执行，适合资源释放。
- **数据**：`new(T)` 返回 `*T` 指向零值；`make` 仅用于 slice/map/channel；数组是值类型（赋值复制），故多用 slice；slice 共享底层数组；map 用 comma-ok 模式查询，`delete` 删除。
- **打印**：`%v`/`%+v`/`%#v`/`%T`/`%q`/`%x`；自定义 `String()` 时小心递归。
- **初始化**：`iota` 常量；变量可运行时初始化；`init()` 在变量初始化后、导入包初始化后执行。
- **方法**：可定义在任意命名类型上；指针接收者可修改接收者，值接收者不可；值方法可在值与指针上调用。
- **接口**：隐式实现；用类型断言 `v.(T)` 检查；编译期断言 `var _ json.Marshaler = (*T)(nil)`。
- **嵌入**：接口可嵌套接口（`type ReadWriter interface { Reader; Writer }`）；结构体可嵌入结构体/接口，方法被提升。
- **并发**：口号"不要通过共享内存通信，而要通过通信共享内存"。`go` 启动 goroutine；channel 用 `make` 创建；带缓冲 channel 可做信号量；channel 可作为字段（请求-响应模式）。
- **错误**：`error` 接口 `Error() string`；自定义 error 类型携带上下文（如 `PathError`）；`panic` 仅用于不可恢复错误；`recover` 在 deferred 函数中捕获 panic。

> 阅读建议：先看"Formatting/Commentary/Names/Control structures/Functions"，建立基本写作感；写并发代码前必读"Concurrency"与"Errors"。

---

## 全文

### Introduction

Go 是一门新语言。虽然它借用了 C、Pascal、Modula、Oberon、Smalltalk 等语言的思想，但 Go 程序不应是这些语言程序的直译。写好 Go 的关键是理解它的属性与惯用法。

### Formatting

用 `gofmt` 自动格式化，省去风格争议。

```go
type T struct {
    name  string // name of the object
    value int    // its value
}
```

要点：
- 缩进用 tab。
- 无固定行长限制。
- 控制结构不带括号：

```go
if x > 0 {
    return y
}
```

左大括号必须与 `if`/`for`/`switch`/`select` 同行。

### Commentary

Go 提供 `//` 行注释与 `/* */` 块注释。紧邻顶级声明的注释是 doc 注释。

### Names

命名很重要，因为大小写控制可见性：导出名首字母大写，包内名首字母小写。

#### 包名

短、小写、通常单词。例如 `bytes.Buffer`、`bufio.Reader`，避免重复：用 `bufio.Reader` 而非 `bufio.BufReader`。

#### Getters

Go getter 通常省略 `Get`：

```go
owner := obj.Owner()
if owner != user {
    obj.SetOwner(user)
}
```

#### 接口名

单方法接口常用 `-er` 后缀：

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}
```

### Semicolons

Go 自动插入分号。地道 Go 几乎不写分号，除了 `for` 子句。不要写：

```go
if i < f()
{
    g()
}
```

应写：

```go
if i < f() {
    g()
}
```

### Control structures

Go 有 `if`/`for`/`switch`/`select`，无 `while`/`do while`。

#### If

带初始化语句：

```go
if err := file.Chmod(0664); err != nil {
    log.Print(err)
    return err
}
```

避免不必要的 `else`：

```go
f, err := os.Open(name)
if err != nil {
    return err
}
codeUsing(f)
```

#### Redeclaration and reassignment

短声明可复用已有变量，只要至少有一个新变量：

```go
f, err := os.Open(name)
d, err := f.Stat()
```

#### For

`for` 覆盖传统循环、while 风格、无限循环：

```go
for init; condition; post { }
for condition { }
for { }
```

Range：

```go
for key, value := range oldMap {
    newMap[key] = value
}
```

用 `_` 忽略：

```go
for _, value := range array {
    sum += value
}
```

#### Switch

默认不 fallthrough：

```go
func shouldEscape(c byte) bool {
    switch c {
    case ' ', '?', '&', '=', '#', '+', '%':
        return true
    }
    return false
}
```

无表达式 switch 等价于 `switch true`：

```go
switch {
case '0' <= c && c <= '9':
    return c - '0'
case 'a' <= c && c <= 'f':
    return c - 'a' + 10
}
```

#### Type switch

```go
switch t := t.(type) {
default:
    fmt.Printf("unexpected type %T\n", t)
case bool:
    fmt.Printf("boolean %t\n", t)
case int:
    fmt.Printf("integer %d\n", t)
case *bool:
    fmt.Printf("pointer to boolean %t\n", *t)
case *int:
    fmt.Printf("pointer to integer %d\n", *t)
}
```

### Functions

#### Multiple return values

```go
func (file *File) Write(b []byte) (n int, err error)
```

```go
func nextInt(b []byte, i int) (int, int) {
    for ; i < len(b) && !isDigit(b[i]); i++ {
    }
    x := 0
    for ; i < len(b) && isDigit(b[i]); i++ {
        x = x*10 + int(b[i]) - '0'
    }
    return x, i
}
```

#### Named result parameters

```go
func nextInt(b []byte, pos int) (value, nextPos int)
```

命名返回值初始化为零值，可裸 `return`：

```go
func ReadFull(r Reader, buf []byte) (n int, err error) {
    for len(buf) > 0 && err == nil {
        var nr int
        nr, err = r.Read(buf)
        n += nr
        buf = buf[nr:]
    }
    return
}
```

#### Defer

`defer` 在外层函数返回时执行：

```go
func Contents(filename string) (string, error) {
    f, err := os.Open(filename)
    if err != nil {
        return "", err
    }
    defer f.Close()

    var result []byte
    buf := make([]byte, 100)
    for {
        n, err := f.Read(buf[0:])
        result = append(result, buf[0:n]...)
        if err != nil {
            if err == io.EOF {
                break
            }
            return "", err
        }
    }
    return string(result), nil
}
```

LIFO 顺序：

```go
for i := 0; i < 5; i++ {
    defer fmt.Printf("%d ", i)
}
```

输出 `4 3 2 1 0`。

### Data

#### Allocation with `new`

`new(T)` 分配零值存储，返回 `*T`：

```go
p := new(SyncedBuffer)
var v SyncedBuffer
```

Go 鼓励设计"零值可用"的类型，如 `bytes.Buffer`、`sync.Mutex`。

#### Constructors and composite literals

复合字面量：

```go
return &File{fd: fd, name: name}
```

`new(File)` 与 `&File{}` 等价。

#### Allocation with `make`

`make` 初始化 slice/map/channel：

```go
v := make([]int, 100)
```

差异：

```go
var p *[]int = new([]int)       // 指向 nil slice 的指针
var v []int = make([]int, 100)  // 已初始化 slice
```

#### Arrays

数组是值类型：
- 赋值复制所有元素
- 传参传副本
- 长度是类型的一部分

```go
func Sum(a *[3]float64) (sum float64) {
    for _, v := range *a {
        sum += v
    }
    return
}
```

地道 Go 多用 slice。

#### Slices

slice 引用底层数组；传 slice 给函数，函数可修改其元素：

```go
func (f *File) Read(buf []byte) (n int, err error)
```

```go
n, err := f.Read(buf[0:32])
```

自定义 append 示例：

```go
func Append(slice, data []byte) []byte {
    l := len(slice)
    if l+len(data) > cap(slice) {
        newSlice := make([]byte, (l+len(data))*2)
        copy(newSlice, slice)
        slice = newSlice
    }
    slice = slice[0 : l+len(data)]
    copy(slice[l:], data)
    return slice
}
```

内置 `append`：

```go
x := []int{1, 2, 3}
x = append(x, 4, 5, 6)
```

追加另一个 slice：

```go
x := []int{1, 2, 3}
y := []int{4, 5, 6}
x = append(x, y...)
```

#### Maps

```go
var timeZone = map[string]int{
    "UTC": 0 * 60 * 60,
    "EST": -5 * 60 * 60,
    "CST": -6 * 60 * 60,
    "MST": -7 * 60 * 60,
    "PST": -8 * 60 * 60,
}
```

查询：

```go
offset := timeZone["EST"]
```

comma-ok：

```go
seconds, ok := timeZone[tz]
```

删除：

```go
delete(timeZone, "PDT")
```

### Printing

格式化打印在 `fmt` 包：

```go
fmt.Printf("Hello %d\n", 23)
fmt.Fprint(os.Stdout, "Hello ", 23, "\n")
fmt.Println("Hello", 23)
```

常用动词：
- `%v` 默认格式
- `%+v` struct 字段带名
- `%#v` Go 语法表示
- `%T` 类型
- `%q` 引号字符串/rune
- `%x` 十六进制

```go
fmt.Printf("%T\n", timeZone)
```

输出 `map[string]int`。

自定义格式化 `String() string`：

```go
func (t *T) String() string {
    return fmt.Sprintf("%d/%g/%q", t.a, t.b, t.c)
}
```

避免递归 `String`。

### Initialization

#### Constants and `iota`

```go
type ByteSize float64

const (
    _           = iota
    KB ByteSize = 1 << (10 * iota)
    MB
    GB
    TB
    PB
    EB
    ZB
    YB
)
```

#### Variables

```go
var (
    home   = os.Getenv("HOME")
    user   = os.Getenv("USER")
    gopath = os.Getenv("GOPATH")
)
```

#### `init`

每个源文件可定义 `init`：

```go
func init() {
    if user == "" {
        log.Fatal("$USER not set")
    }
}
```

`init` 在变量初始化后、导入包初始化后执行。

### Methods

方法可定义在任意命名类型上（指针/接口类型除外）。

```go
type ByteSlice []byte

func (slice ByteSlice) Append(data []byte) []byte {
    // append 实现
}
```

指针接收者可修改接收者：

```go
func (p *ByteSlice) Write(data []byte) (n int, err error) {
    slice := *p
    // append data
    *p = slice
    return len(data), nil
}
```

指针接收者规则：
- 值方法可在值与指针上调用
- 指针方法只能在指针上调用
- 若值可寻址，Go 自动取地址

### Interfaces

接口指定行为：

```go
type Handler interface {
    ServeHTTP(ResponseWriter, *Request)
}
```

类型隐式实现接口（无需声明）。

满足 `sort.Interface` 的示例：

```go
type Sequence []int

func (s Sequence) Len() int {
    return len(s)
}

func (s Sequence) Less(i, j int) bool {
    return s[i] < s[j]
}

func (s Sequence) Swap(i, j int) {
    s[i], s[j] = s[j], s[i]
}
```

类型断言：

```go
str, ok := value.(string)
if ok {
    fmt.Printf("string value is: %q\n", str)
}
```

### Blank identifier

`_` 丢弃值：

```go
for _, value := range array {
    sum += value
}
```

丢弃返回值：

```go
if _, err := os.Stat(path); os.IsNotExist(err) {
    fmt.Printf("%s does not exist\n", path)
}
```

副作用导入：

```go
import _ "net/http/pprof"
```

编译期接口检查：

```go
var _ json.Marshaler = (*RawMessage)(nil)
```

### Embedding

Go 支持嵌入 struct 与 interface。

接口嵌入：

```go
type ReadWriter interface {
    Reader
    Writer
}
```

结构体嵌入：

```go
type ReadWriter struct {
    *Reader
    *Writer
}
```

嵌入方法被提升到外层类型。示例：

```go
type Job struct {
    Command string
    *log.Logger
}
```

则：

```go
job.Println("starting now...")
```

### Concurrency

口号：

> Do not communicate by sharing memory; instead, share memory by communicating.

#### Goroutines

```go
go list.Sort()
```

函数字面量：

```go
func Announce(message string, delay time.Duration) {
    go func() {
        time.Sleep(delay)
        fmt.Println(message)
    }()
}
```

#### Channels

```go
ci := make(chan int)
cs := make(chan *os.File, 100)
```

等待 goroutine：

```go
c := make(chan int)

go func() {
    list.Sort()
    c <- 1
}()

doSomethingForAWhile()
<-c
```

带缓冲 channel 做信号量：

```go
var sem = make(chan int, MaxOutstanding)

func handle(r *Request) {
    sem <- 1
    process(r)
    <-sem
}
```

固定 worker pool：

```go
func handle(queue chan *Request) {
    for r := range queue {
        process(r)
    }
}

func Serve(clientRequests chan *Request, quit chan bool) {
    for i := 0; i < MaxOutstanding; i++ {
        go handle(clientRequests)
    }
    <-quit
}
```

#### Channels of channels

请求可携带响应 channel：

```go
type Request struct {
    args       []int
    f          func([]int) int
    resultChan chan int
}
```

客户端：

```go
request := &Request{[]int{3, 4, 5}, sum, make(chan int)}
clientRequests <- request
fmt.Printf("answer: %d\n", <-request.resultChan)
```

服务端：

```go
func handle(queue chan *Request) {
    for req := range queue {
        req.resultChan <- req.f(req.args)
    }
}
```

#### Parallelization

跨 CPU 拆分工作，用 channel 等待完成：

```go
func (v Vector) DoAll(u Vector) {
    c := make(chan int, numCPU)
    for i := 0; i < numCPU; i++ {
        go v.DoSome(i*len(v)/numCPU, (i+1)*len(v)/numCPU, u, c)
    }
    for i := 0; i < numCPU; i++ {
        <-c
    }
}
```

### Errors

Go 习惯把错误作为值返回：

```go
type error interface {
    Error() string
}
```

自定义 error 类型：

```go
type PathError struct {
    Op   string
    Path string
    Err  error
}

func (e *PathError) Error() string {
    return e.Op + " " + e.Path + ": " + e.Err.Error()
}
```

类型断言做细粒度处理：

```go
if e, ok := err.(*os.PathError); ok && e.Err == syscall.ENOSPC {
    deleteTempFiles()
    continue
}
```

#### Panic

`panic` 用于不可恢复错误：

```go
panic(fmt.Sprintf("CubeRoot(%g) did not converge", x))
```

#### Recover

`recover` 在 panic 展开期间恢复控制，通常在 deferred 函数中：

```go
func safelyDo(work *Work) {
    defer func() {
        if err := recover(); err != nil {
            log.Println("work failed:", err)
        }
    }()
    do(work)
}
```

---

Effective Go 的核心教训：用 Go 自己的风格写 Go——`gofmt`、短而有意义的名字、简单的控制流、显式错误处理、用接口表达行为、用嵌入做组合、用 channel/goroutine 写清晰的并发结构。
