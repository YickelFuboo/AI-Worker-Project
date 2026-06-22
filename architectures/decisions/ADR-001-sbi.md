---
adr_id: ADR-001
title: 控制面采用服务化接口 SBI(HTTP/2 + JSON + OAuth2 + mTLS)
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [amf, ausf, bsf, chf, nef, nrf, nssf, pcf, smf, udm, udr]
related_repos: [amf, ausf, bsf, chf, nef, nrf, nssf, pcf, smf, udm, udr]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-001:控制面采用服务化接口 SBI

## 决策声明

5G 核心网控制面 NF 之间通信采用 SBI(Service-Based Interface):传输层 HTTP/2、编码 JSON、互访鉴权 OAuth2 客户端令牌、链路加密 mTLS;统一经由 NRF 注册与发现对端。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:SBI vs Diameter 点对点、SBI vs gRPC 等候选)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入。

## 5. 关联

- **关联元素**:amf / ausf / bsf / chf / nef / nrf / nssf / pcf / smf / udm / udr(全部控制面 NF)
- **关联代码仓**:同上
- **关联历史方案**:无(待补)
