---
adr_id: ADR-005
title: 非 3GPP 接入双分支(n3iwf 不受信 + tngf 受信)独立 NF
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [n3iwf, tngf, amf, upf]
related_repos: [n3iwf, tngf, amf, upf]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-005:非 3GPP 接入双分支独立 NF

## 决策声明

非 3GPP 接入采用两个独立 NF:n3iwf 处理不受信接入(经公网 WiFi,UE 经 IKEv2/IPsec 建隧道),tngf 处理受信接入(经 TWAN,RADIUS + EAP-5G 鉴权);两者均经 NGAP/N2 接入 amf、经 GTP-U/N3 接入 upf,与 3GPP 接入复用控制/用户面。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:n3iwf+tngf 分立 vs 合并、新建 NF vs 在 amf 内置非 3GPP 模块)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入。

## 5. 关联

- **关联元素**:n3iwf / tngf / amf / upf
- **关联代码仓**:n3iwf / tngf
- **关联历史方案**:无(待补)
