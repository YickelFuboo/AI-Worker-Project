# free5GC 实现专题

> 来源：free5gc.org 官方用户指南 + GitHub README + 本仓库 `repos/` 镜像代码。
> 版本基线：main 分支对应 3GPP R15，next 分支对应 R17；本仓库 NF 代码以 v3.4.x 为参照。

## 1. 项目定位

- **free5GC** 是开源 5G Core 实现，遵循 3GPP Release 15（main）/ Release 17（next）。
- License：Apache 2.0。
- 主仓：https://github.com/free5gc/free5gc
- 文档：https://free5gc.org/guide/
- 论坛：https://forum.free5gc.org
- 教程：https://github.com/free5gc/free5GLab
- LFX 课程：https://training.linuxfoundation.org/training/introduction-to-free5gc-lfs114/
- Docker Hub：https://hub.docker.com/u/free5gc

## 2. 支持的功能（v3.4.x）

来源：https://free5gc.org/guide/features/

### 规范与平台
- 3GPP TS 23.501/23.502 Release 15（main）/ Release 17（next）
- 5G Standalone
- Service-Based Interface (SBI)
- SBI 服务：Namf / Nsmf / Nausf / Nudm / Nudr / Nnssf / Nnrf / Npcf / Nchf / Nnef
- 接口：N1, N2, N3, N4, N6, N9

### NF 覆盖
AMF, SMF, UPF, CHF, AUSF, NRF, UDM, UDR, PCF, NSSF, N3IWF, N3IWUE, TNGF, TNGFUE, NEF。

### 关键能力
- **注册**：Initial / Periodic / Mobility Registration；Registration without authentication when RAN performed AMF reselection；NAS reroute when serving AMF cannot handle unmatched NSSAI。
- **鉴权**：5G-AKA、EAP-AKA'。
- **NAS 安全**：NEA0/1/2/3 加密、NIA0/1/2/3 完整性。
- **去注册**：UE-initiated。
- **Service Request**：UE 触发 / 网络触发；AN Release。
- **PDU 会话**：Establishment / Modification (v3.3.0+) / Release。
- **Converged Charging**：webconsole 作为 Billing Domain；CHF 内置 ABMF / RF / CGF；Flow-based Charging。
- **切换**：N2 Handover（无 indirect mode）；Xn Handover。
- **QoS**：control-plane only 5QI / ARP / GBR / MBR / Session-AMBR。
- **N4 使用上报**：周期性 volume measurement。
- **多 UPF + ULCL**、**多 Slice + DNN**、**动态/静态 IPv4 地址分配**、**OAuth2 on SBI**、**Traffic Influence (v3.4.4)**、**UP Security**、**NR-DC**。

## 3. 仓库结构

free5GC 主仓的顶层布局：

```
free5gc/
├── NFs/                  # 各 NF 的 Go module（独立子模块）
│   ├── amf/
│   ├── smf/
│   ├── upf/              # 注：go-upf 是 v3.4.x 起的新 UPF
│   ├── udm/  udr/  pcf/  ausf/  nrf/  nssf/  nef/  chf/  bsf/
│   ├── n3iwf/  tngf/
├── config/               # 各 NF 的 YAML 配置
├── test/                 # 集成测试 + UE/RAN 模拟器
├── webconsole/           # WebUI 与计费前端
├── Makefile
├── run.sh                # 启动所有 NF
├── quick-setup.sh        # 一键环境
└── go.mod
```

本仓库 `repos/` 下每个子目录对应 free5GC 一个 NF 子模块的镜像，可直接 `go build ./...`。

## 4. 安装与运行

### 推荐路径：free5GC compose（Docker）

```bash
git clone https://github.com/free5gc/free5gc-compose.git
cd free5gc-compose
make base       # 构建 Docker 镜像
docker compose up -d
```

### 单机模式：quick-setup

来源：https://free5gc.org/guide/quick-setup/

**前置要求**：
- CPU：AMD 或 Intel with AVX
- OS：Ubuntu 20.04 / 22.04 / 24.04 / 25.04
- 已安装 `git`

**步骤**：

```bash
git clone https://github.com/free5gc/free5gc.git
cd free5gc

# 查网络接口
ip a

# 一键安装依赖 + 编译 + 配置 + 启动
source quick-setup.sh -i <network interface>

# 开发者模式：禁用控制台输出
source quick-setup.sh -i <interface> -l

# 直接部署：跳过构建
source quick-setup.sh -i <interface> -d

# 启动所有 NF
./run.sh

# 启动 WebConsole
cd webconsole
./bin/webconsole
```

WebConsole 默认监听 `:5000`，提供签约/切片/DNN/计费管理界面。

### 从源码构建（高级）

参考 free5gc.org/guide `Build and Install free5GC` 章节，主要步骤：

1. 安装 Go ≥ 1.21、MongoDB 6.x、`build-essential`、`gtp5g` 内核模块。
2. 编译各 NF：`make amf smf upf ...` 或 `make all`。
3. 安装内核模块：`cd lib/gtp5g && make && sudo make install`。
4. 启动 MongoDB：`sudo systemctl start mongodb`。
5. 启动 NF：`./run.sh`。

## 5. 配置要点

每个 NF 的配置在 `config/<nf>.yaml`，公共配置在 `config/free5GC.yaml`。关键配置项：

| NF | 关键配置 | 说明 |
|---|---|---|
| AMF | `ngapIp`, `sbi.port` | N2 监听 IP 与 SBI 端口 |
| SMF | `userplane.node[0]`, `snssai` | UPF 拓扑与切片映射 |
| UPF (go-upf) | `pfcp.addr`, `gtpu.addr`, `dnn` | N4/N3 监听 |
| NRF | `sbi.port` | 默认 8000，所有 NF 先连这里 |
| UDM/UDR | `mongodb.name/url` | 数据库连接 |
| WebConsole | `port: 5000` | WebUI |
| AMF | `security.integrityOrder`, `cipheringOrder` | NAS 安全算法优先级 |

切片与 DNN：在 WebConsole → Subscribers → Slice/DNN 配置；AMF 收到 UE 切片请求后通过 NSSF 选择 SMF。

UPF 选择：SMF 根据 S-NSSAI + DNN 匹配 UPF 配置；ULCL 模式由 SMF 按 Traffic Filter 决定分流。

## 6. 二次开发要点

### NF 服务骨架
每个 NF 都遵循相同结构：
- `cmd/<nf>/main.go`：入口
- `internal/sbi/`：HTTP/2 server + producer/consumer
- `internal/context/`：上下文与状态
- `internal/util/`：工具函数
- `internal/fsm/`：状态机（NAS/NGAP）
- `pkg/`：可对外暴露的库

### 修改 SBI 操作
1. 在 `internal/sbi/<service-name>_server.go` 加 handler。
2. 在 `openapi/` 下用 oapi-codegen 生成 Go 类型（参考 free5GC 的 `Makefile` `openapi` target）。
3. 在 `internal/sbi/consumer/` 中加 consumer 调用。
4. 在 `internal/context/` 维护状态。

### NAS 消息处理
- 编解码：`internal/nas/nasmessage`（amf仓）。
- 处理器：`internal/nas/nasmessage/handler/<mm/sm>`。
- 加新消息：先在 `internal/nas/nasmessage/encoder/decoder` 加，再写 handler。

### NGAP
- 编解码：`internal/ngap/message/`。
- 处理器：`internal/ngap/handler/`。

### PFCP
- `internal/pfcp/message/`：消息编解码。
- `internal/pfcp/handler/`：消息处理。
- 新增 IE：参考 TS 29.244 §7.3，在 `internal/pfcp/ie/` 加。

## 7. 调试

### 日志
所有 NF 用 `Logger` 包（基于 Go `log`），配置 `infoLevel: debug/debugDetailed` 可输出详细日志。

### 关键排查点
- **注册失败**：先看 AMF 日志中 NAS 解码、AUSF 鉴权响应、UDM 签约返回。
- **PDU 会话失败**：看 SMF 日志中 `CreateSMContext`、PCF `SMPolicyControl_Create`、UPF `PFCP Session Establishment`。
- **N4 不通**：检查 SMF 与 UPF 间 N4 端口（默认 8805）、UPF `pfcp.addr` 配置。
- **NRF 找不到 NF**：NF 是否调过 `Nnrf_NFManagement_Register`；心跳是否正常。

### WebConsole
- 默认 `http://<host>:5000`
- 默认账号：`admin / free5gc`（首次登录修改）
- 可创建 UE 签约、切片、DNN、查看计费。

### 测试
free5GC 主仓 `test/` 下集成测试用 UERANSIM 或自带模拟器跑注册/PDU 会话/切换/释放流程：

```bash
cd test
make test                     # 跑全部用例
go test -run TestRegistration ./test  # 单测
```

## 8. 与 3GPP 规范的对应

| 3GPP 条款 | free5GC 实现位置 |
|---|---|
| TS 23.502 §4.2.2 (Registration) | `amf/internal/nas/nasmessage/handler/mm/registration.go` |
| TS 23.502 §4.3.2 (PDU Session) | `smf/internal/sbi/producer/create_sm_context.go` + `smf/internal/pfcp/build.go` |
| TS 23.502 §4.2.3 (Service Request) | `amf/internal/ngap/handler/service_request.go` |
| TS 23.502 §4.9.1 (N2 HO) | `amf/internal/ngap/handler/handover.go` |
| TS 29.518 (Namf) | `amf/internal/sbi/server.go` |
| TS 29.502 (Nsmf) | `smf/internal/sbi/server.go` |
| TS 29.244 (PFCP) | `go-upf/internal/pfcp/`、`smf/internal/pfcp/` |
| TS 38.413 (NGAP) | `amf/internal/ngap/message/` |
| TS 29.510 (Nnrf) | `nrf/internal/sbi/` |
| TS 29.503 (Nudm) | `udm/internal/sbi/producer/` |
| TS 29.504 (Nudr) | `udr/internal/sbi/producer/` |

## 9. 部署形态

### 单机
所有 NF 跑在同一台机器，`run.sh` 顺序拉起。MongoDB 必装。

### Docker Compose
`free5gc-compose` 仓提供 `docker-compose.yaml`，每个 NF 一个容器，UPF 用 `gtp5g` 模块需 host privileged。

### Kubernetes
- 官方 `free5gc-helm`：https://github.com/free5gc/free5gc-helm
- 社区 `towards5gs-helm`：https://github.com/Orange-OpenSource/towards5gs
- 多集群：见 free5gc.org `Deployment > Towards5gs-helm` 链接。

### 高级配置
- ULCL：参考 free5gc.org/guide `ULCL` 章节。
- NR-DC：参考 `NR-DC` 章节。
- Static IP for UE：`Set Static IP for UE`。
- OAuth2：`Enable OAuth2 on SBI`，所有 NF 启用 access token 验证。

## 10. 常见坑

1. **gtp5g 内核模块**：UPF 必须装；版本需匹配 free5GC 版本，跨升级要重编。
2. **MongoDB 数据残留**：测试前 `mongo --eval 'db.dropDatabase()'` 清空，避免老签约影响。
3. **NRF 心跳超时**：NF 调试时停过久会被 NRF 摘掉，重启即可。
4. **AMF 与 SMF 的 SBI 端口冲突**：默认每个 NF 不同端口（AMF 8000、SMF 8001...），改配置后要同步调 AMF 的 SMF 调用 URL。
5. **IPv6 dual-stack**：默认走 IPv4；要 IPv6 需在 NF 配置中改 `sbi.scheme`、`bindIP` 并保证容器/主机有 v6 地址。
6. **AMF 改 NSSAI 后无法注册**：UE 已写入的 IMEI/SUCI 缓存可能残留，清 MongoDB 的 `subscriptionData` 与 AMF 内存（重启）。

## 11. 参考链接

- 主仓：https://github.com/free5gc/free5gc
- Compose：https://github.com/free5gc/free5gc-compose
- Helm：https://github.com/free5gc/free5gc-helm
- 官方论坛：https://forum.free5gc.org
- 版本历史：https://free5gc.org/history
- 故障排查：https://free5gc.org/guide/troubleshooting
