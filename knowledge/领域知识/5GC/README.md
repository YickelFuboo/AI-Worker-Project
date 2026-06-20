# 5GC 领域知识库

> 收录范围：3GPP 5G Core（5GC）规范 + free5GC 开源实现。
> 来源：仅取自 3GPP 官方规范（ETSI 发布版）与 free5GC 官方站点（free5gc.org / github.com/free5gc）。
> 语言：中英混合。规范术语保留英文原文，叙述用中文。
> 深度目标：可落地参考——读者读完应能定位到具体规范条款、free5GC 代码路径与配置项。

## 目录结构

| 目录 | 内容 |
|---|---|
| `01_架构与协议/` | SBA 架构、参考点（N1–Nn）、协议栈（NAS/NGAP/PFCP/HTTP2）、QoS、会话与移动性管理流程 |
| `02_Network_Functions/` | AMF/SMF/UPF/UDM/UDR/PCF/NRF/AUSF/NSSF/NEF/CHF/BSF/N3IWF/TNGF 详解 |
| `03_free5GC实现/` | free5GC 项目架构、模块组织、与 3GPP 对应、构建/部署/调试要点 |
| `04_3GPP规范索引/` | 关键 TS 索引、Release 对照、PDF 原文（本地存档） |

## 本地存档的 3GPP 规范 PDF（Release 18）

位于 `04_3GPP规范索引/` 下，可直接打开查阅：

| 文件 | 规范号 | 标题 | 版本 |
|---|---|---|---|
| `ts23501.pdf` | TS 23.501 | System architecture for the 5G System (5GS) | v18.11.0 |
| `ts23502.pdf` | TS 23.502 | Procedures for the 5G System | v18.10.0 |
| `ts29500.pdf` | TS 29.500 | 5G System; Technical Realization of Service Based Architecture; Stage 3 | v18.8.0 |
| `ts29502.pdf` | TS 29.502 | 5G System; Session Management Services; Stage 3 | v18.8.0 |
| `ts29510.pdf` | TS 29.510 | 5G System; Network function repository services; Stage 3 | v18.11.0 |
| `ts29518.pdf` | TS 29.518 | 5G System; Access and Mobility Management Services; Stage 3 | v18.11.0 |
| `ts38413.pdf` | TS 38.413 | NG-RAN; NG Application Protocol (NGAP) | v18.5.0 |
| `ts29244.pdf` | TS 29.244 | Interface to the Control Plane of the 5G Core; Stage 3 (PFCP) | v18.10.0 |

## 在线权威源

- 3GPP 规范门户：https://www.3gpp.org/dynareport/23501.htm （每个 TS 都有 `https://www.3gpp.org/dynareport/<specno>.htm` 形态的 status 页）
- 3GPP FTP 规范归档：https://www.3gpp.org/ftp/Specs/archive/
- ETSI 发布版（含 PDF/Word）：`https://www.etsi.org/deliver/etsi_ts/<series_low>_<series_high>/<specno>/<version>/<file>.pdf`
- free5GC 官方站点：https://free5gc.org/
- free5GC 用户指南：https://free5gc.org/guide/
- free5GC GitHub：https://github.com/free5gc/free5gc
- free5GC 论坛：https://forum.free5gc.org

## 使用约定

- 提到规范条款时统一用 `TS 23.501 §6.2.1` 这样的引用格式，便于在本地 PDF 中跳转。
- 提到 free5GC 代码时用相对路径 `NFs/amf/internal/...`，对应到本仓库 `repos/amf/internal/...` 的镜像。
- 表格中的 NF 缩写第一次出现给出全称。

## 维护说明

- 本目录由 2026-06-20 一次性抓取构建，3GPP 规范版本以 Release 18 为基线；free5GC 信息以 v3.4.x 为参照。
- 若需要升级规范版本，去 https://www.3gpp.org/dynareport/<specno>.htm 查最新版本号，再到 ETSI 下载对应 PDF 替换。
