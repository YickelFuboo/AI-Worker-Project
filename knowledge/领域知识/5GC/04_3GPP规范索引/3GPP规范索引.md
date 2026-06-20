# 3GPP 规范索引

> 仅收录与 5GC 直接相关的 TS。本地 PDF 存于本目录下，可直接打开。
> 版本基线：Release 18（2024–2025 冻结）。Release 19 部分规范已有早期版本，未纳入。

## 1. 本地存档清单

| 本地文件 | TS | 标题 | 版本 | ETSI 源 URL |
|---|---|---|---|---|
| `ts23501.pdf` | TS 23.501 | System architecture for the 5G System (5GS) | v18.11.0 | https://www.etsi.org/deliver/etsi_ts/123500_123599/123501/18.11.00_60/ts_123501v181100p.pdf |
| `ts23502.pdf` | TS 23.502 | Procedures for the 5G System | v18.10.0 | https://www.etsi.org/deliver/etsi_ts/123500_123599/123502/18.10.00_60/ts_123502v181000p.pdf |
| `ts29500.pdf` | TS 29.500 | 5G System; Technical Realization of Service Based Architecture; Stage 3 | v18.8.0 | https://www.etsi.org/deliver/etsi_ts/129500_129599/129500/18.08.00_60/ts_129500v180800p.pdf |
| `ts29502.pdf` | TS 29.502 | 5G System; Session Management Services; Stage 3 | v18.8.0 | https://www.etsi.org/deliver/etsi_ts/129500_129599/129502/18.08.00_60/ts_129502v180800p.pdf |
| `ts29510.pdf` | TS 29.510 | 5G System; Network function repository services; Stage 3 | v18.11.0 | https://www.etsi.org/deliver/etsi_ts/129500_129599/129510/18.11.00_60/ts_129510v181100p.pdf |
| `ts29518.pdf` | TS 29.518 | 5G System; Access and Mobility Management Services; Stage 3 | v18.11.0 | https://www.etsi.org/deliver/etsi_ts/129500_129599/129518/18.11.00_60/ts_129518v181100p.pdf |
| `ts38413.pdf` | TS 38.413 | NG-RAN; NG Application Protocol (NGAP) | v18.5.0 | https://www.etsi.org/deliver/etsi_ts/138400_138499/138413/18.05.00_60/ts_138413v180500p.pdf |
| `ts29244.pdf` | TS 29.244 | Interface to the Control Plane of the 5G Core; Stage 3 (PFCP) | v18.10.0 | https://www.etsi.org/deliver/etsi_ts/129200_129299/129244/18.10.00_60/ts_129244v181000p.pdf |

## 2. 规范族索引（按系列）

### 23 系列（Stage 2，架构与流程）

| TS | 标题 | 用途 |
|---|---|---|
| 23.501 | System architecture for the 5G System | 5GC 总架构，所有 NF 与参考点的法定描述 |
| 23.502 | Procedures for the 5G System | 流程级描述：注册、PDU 会话、切换、服务请求、Paging 等 |
| 23.503 | Policy and Charging Control | PCC 框架，PCF 决策依据 |
| 23.534 | Edge Computing in 5G | 边缘计算集成 |
| 23.548 | 5G enhancements for V2X | V2X 扩展 |

### 24 系列（Stage 3，UE/NAS 协议）

| TS | 标题 | 用途 |
|---|---|---|
| 24.501 | NAS for 5GS | NAS 5GMM/5GSM 编解码与流程 |
| 24.526 | UE security capability | UE 安全能力协商 |

### 29 系列（Stage 3，5GC SBI 与点对点接口）

| TS | 标题 | 用途 |
|---|---|---|
| 29.500 | 5G System; SBA Technical Realization; Stage 3 | SBI 通用原则：HTTP/2、JSON、错误模型 |
| 29.501 | 5G System; SBA Principles; Stage 3 | SBI 详细设计原则 |
| 29.502 | 5G System; Session Management Services; Stage 3 | Nsmf |
| 29.503 | 5G System; Unified Data Management Services; Stage 3 | Nudm |
| 29.504 | 5G System; Unified Data Repository Services; Stage 3 | Nudr |
| 29.505 | 5G System; UE Policy Management Service; Stage 3 | Nudr_PP, Npcf_UEPolicy |
| 29.506 | 5G System; Policy Control Service; Stage 3 | （合并到 29.512） |
| 29.507 | 5G System; Access and Mobility Policy Control Service; Stage 3 | Npcf_AMPolicyControl |
| 29.508 | 5G System; Session Management Event Exposure; Stage 3 | Nsmf_EventExposure |
| 29.509 | 5G System; Authentication Server Services; Stage 3 | Nausf |
| 29.510 | 5G System; Network Function Repository Services; Stage 3 | Nnrf |
| 29.512 | 5G System; Session Management Policy Control Service; Stage 3 | Npcf_SMPolicyControl |
| 29.514 | 5G System; Policy Authorization Service; Stage 3 | Npcf_PolicyAuthorization |
| 29.518 | 5G System; Access and Mobility Management Services; Stage 3 | Namf |
| 29.519 | 5G System; BSF Services; Stage 3 | Nbsf |
| 29.521 | 5G System; BSF Binding Service; Stage 3 | Nbsf_Management |
| 29.522 | 5G System; NEF Services; Stage 3 | Nnef |
| 29.525 | 5G System; UE Policy Control Service; Stage 3 | Npcf_UEPolicyControl |
| 29.526 | 5G System; UDSF Services; Stage 3 | Nudsf |
| 29.531 | 5G System; NSSF Services; Stage 3 | Nnssf |
| 29.537 | 5G System; SOCP Services; Stage 3 | Service Communication Proxy |
| 29.540 | 5G System; SMS Services; Stage 3 | SMS over NAS |
| 29.549 | 5G System; AF Services; Stage 3 | Naf |
| 29.554 | 5G System; Edge Computing Services; Stage 3 | NEF edge exposure |
| 29.561 | 5G System; UDSF Nudsf; Stage 3 | （详见 29.526） |
| 29.571 | 5G System; Common Data Types; Stage 3 | **所有 SBI 共用数据类型，必查** |
| 29.590 | 5G System; CHF Services; Stage 3 | Nchf (multiservice) |
| 29.594 | 5G System; CHF Converged Charging; Stage 3 | Nchf_ConvergedCharging |
| 29.244 | Interface to the Control Plane of the 5G Core; Stage 3 | N4 PFCP |
| 29.281 | GPRS Tunnelling Protocol for User Plane (GTP-U) | N3/N9 GTP-U |
| 29.244-5xx | （5GC PFCP extensions） | PFCP for 5GC |

### 32 系列（计费）

| TS | 标题 | 用途 |
|---|---|---|
| 32.240 | Telecommunication management; Charging management; Charging architecture and principles | 计费架构 |
| 32.255 | 5G Data Connectivity Domain Charging | 5GC 计费规则 |
| 32.256 | 5G Roaming Charging | 漫游计费 |
| 32.297 | Charging architecture principles | CGF / Bd 接口 |

### 33 系列（安全）

| TS | 标题 | 用途 |
|---|---|---|
| 33.501 | Security architecture and procedures for 5G System | 5G-AKA、密钥层次、NAS/UP 安全 |

### 38 系列（NG-RAN / NGAP）

| TS | 标题 | 用途 |
|---|---|---|
| 38.300 | NR; Overall description; Stage 2 | NR 框架 |
| 38.413 | NG-RAN; NG Application Protocol (NGAP) | N2 信令 |
| 38.423 | NG-RAN; Xn Application Protocol (XnAP) | RAN 间 Xn |

## 3. Release 版本对照

| Release | 冻结 | 5GC 关键变化 |
|---|---|---|
| Rel-15 | 2018-06 | 5GC 基线，SBA、CP/UP 分离、网络切片 |
| Rel-16 | 2020-06 | 增强切片、ULCL、NEF 增强、URLLC、IIoT、5G LAN |
| Rel-17 | 2022-03 | 多播广播 (MBS)、NR-DC、RedCap、NPN 增强 |
| Rel-18 | 2024-06 (stage 3 freeze 2025-03) | 5G-Advanced：Ambient IoT、Network Slicing 增强、SBA 演进 |
| Rel-19 | 2025+ | 早期版本，5G-A 第二阶段 |

> free5GC `main` 分支跟踪 Rel-15；`next` 分支跟踪 Rel-17。

## 4. 查找规范的方法

### 3GPP status 页面
```
https://www.3gpp.org/dynareport/<specno>.htm
```
例如 `https://www.3gpp.org/dynareport/23501.htm` ——列出该规范所有版本与各 Release 最新版。

### 3GPP FTP 归档
```
https://www.3gpp.org/ftp/Specs/archive/<series>/<specno>/
```
例如 `https://www.3gpp.org/ftp/Specs/archive/23_series/23.501/` ——所有历史版本。

### ETSI 发布版（PDF/Word）
URL 模板：
```
https://www.etsi.org/deliver/etsi_ts/<lo>_<hi>/<specno>/<ver_major>.<ver_minor>.<ver_patch>_<rev>/ts_<specno>v<ver>...p.pdf
```
- `<lo>_<hi>`：specno 对应的 5 位范围，例如 23.501 → `123500_123599`，29.510 → `129500_129599`，38.413 → `138400_138499`，29.244 → `129200_129299`。
- `<ver>`：如 `18.11.00`。
- `<rev>`：通常 `60`（_REL).
- 文件名：`ts_<specno>v<ver>0p.pdf`，例如 `ts_123501v181100p.pdf`。

ETSI 对脚本下载需要 User-Agent，否则返回 HTML 错误页。命令示例：

```bash
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"
curl -sL -A "$UA" -o ts_23501.pdf \
  "https://www.etsi.org/deliver/etsi_ts/123500_123599/123501/18.11.00_60/ts_123501v181100p.pdf"
```

## 5. 关键条款速查

| 主题 | TS | 条款 |
|---|---|---|
| 5GC 整体架构 | 23.501 | §4.2 |
| NF 描述 | 23.501 | §6.2 |
| 参考点清单 | 23.501 | §6.7.2 / Annex D |
| QoS 模型 | 23.501 | §5.7 |
| Network Slicing | 23.501 | §5.15 |
| Roaming | 23.501 | §5.16 |
| 数据类型（所有 SBI 共用） | 29.571 | 全文 |
| SBI 通用原则 | 29.500 | §4 |
| SBI 错误模型 | 29.500 | §4.8 |
| 注册流程 | 23.502 | §4.2.2 |
| 服务请求 | 23.502 | §4.2.3 |
| 去注册 | 23.502 | §4.2.4 |
| PDU 会话建立 | 23.502 | §4.3.2 |
| PDU 会话释放 | 23.502 | §4.3.4 |
| N2 切换 | 23.502 | §4.9.1 |
| Xn 切换 | 23.502 | §4.9.2 |
| NGAP 流程 | 38.413 | §8 (Elementary Procedures) |
| PFCP 消息/IE | 29.244 | §5 / §7 |
| 5G-AKA | 33.501 | §6.1 |
| 密钥层次 | 33.501 | §6.2 |
| NAS 安全 | 33.501 | §6.4 |
| UP 安全 | 33.501 | §6.5 |

## 6. 升级本地存档

若需把某个规范升级到新版本：

1. 访问 `https://www.3gpp.org/dynareport/<specno>.htm` 查最新版本号。
2. 用上述 ETSI URL 模板构造下载链接。
3. 替换本目录下的 PDF。
4. 更新本文档第 1 节的版本号与 URL。

## 7. 未纳入本地存档的关键规范

下列规范本目录未存 PDF，但常被引用，列出 ETSI 链接便于按需下载：

- **TS 23.503** (Policy and Charging Control): https://www.3gpp.org/dynareport/23503.htm
- **TS 24.501** (NAS): https://www.3gpp.org/dynareport/24501.htm
- **TS 29.501** (SBA Principles): https://www.3gpp.org/dynareport/29501.htm
- **TS 29.503** (Nudm): https://www.3gpp.org/dynareport/29503.htm
- **TS 29.504** (Nudr): https://www.3gpp.org/dynareport/29504.htm
- **TS 29.507** (AM Policy): https://www.3gpp.org/dynareport/29507.htm
- **TS 29.509** (Nausf): https://www.3gpp.org/dynareport/29509.htm
- **TS 29.512** (SM Policy): https://www.3gpp.org/dynareport/29512.htm
- **TS 29.519** (Nbsf): https://www.3gpp.org/dynareport/29519.htm
- **TS 29.522** (Nnef): https://www.3gpp.org/dynareport/29522.htm
- **TS 29.531** (Nnssf): https://www.3gpp.org/dynareport/29531.htm
- **TS 29.571** (Common Data Types): https://www.3gpp.org/dynareport/29571.htm
- **TS 29.594** (Nchf): https://www.3gpp.org/dynareport/29594.htm
- **TS 29.281** (GTP-U): https://www.3gpp.org/dynareport/29281.htm
- **TS 32.255** (5G Charging): https://www.3gpp.org/dynareport/32255.htm
- **TS 33.501** (Security): https://www.3gpp.org/dynareport/33501.htm
- **TS 38.423** (XnAP): https://www.3gpp.org/dynareport/38423.htm
