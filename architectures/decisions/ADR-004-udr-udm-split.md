---
adr_id: ADR-004
title: 订阅数据存储 UDR/UDM 分层
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [udm, udr]
related_repos: [udm, udr]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-004:订阅数据存储 UDR/UDM 分层

## 决策声明

订阅数据访问采用两层架构:UDM 封装业务语义(订阅数据管理、UE 上下文管理、鉴权数据派生),向 amf/ausf/smf 提供 SBI 服务;UDR 作为持久化层,后端为 MongoDB,仅 udm/pcf/nef 直接访问。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:UDR/UDM 两层 vs HSS 单层、不同持久化后端选型)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入(已识别风险:多 NF 共享 MongoDB 集群故障域耦合,见 §9.1)。

## 5. 关联

- **关联元素**:udm / udr
- **关联代码仓**:udm / udr
- **关联历史方案**:无(待补)
