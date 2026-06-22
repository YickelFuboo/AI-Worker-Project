---
adr_id: ADR-003
title: NF 发现机制采用 NRF 集中注册中心
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [nrf, amf, ausf, bsf, chf, nef, nssf, pcf, smf, udm, udr]
related_repos: [nrf, amf, ausf, bsf, chf, nef, nssf, pcf, smf, udm, udr]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-003:NF 发现机制采用 NRF 集中注册中心

## 决策声明

全系统 NF 在启动时向 NRF 注册自身能力与端点,运行时经 Nnrf_NFDiscovery 发现对端;NRF 同时承担 OAuth2 客户端令牌签发,统一鉴权与发现入口。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:NRF 集中 vs DNS-SRV 去中心化、NRF 集中 vs 静态配置)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入(已识别风险:NRF 单点,见 system_architectures.md §9.1)。

## 5. 关联

- **关联元素**:nrf 及所有 SBI NF
- **关联代码仓**:同上
- **关联历史方案**:无(待补)
