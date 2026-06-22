---
adr_id: ADR-002
title: 控制面/用户面解耦 CUPS,smf 经 PFCP N4 控制 upf
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [smf, upf]
related_repos: [smf, upf]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-002:控制面/用户面解耦 CUPS

## 决策声明

会话管理(smf)与用户面转发(upf)解耦,smf 经 PFCP(N4 接口,UDP/8805)向 upf 下发 PDR/FAR/QER/URR 规则;upf 不参与控制面信令,仅按规则转发与上报。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:CUPS 解耦 vs 控制/转发合体)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入。

## 5. 关联

- **关联元素**:smf / upf
- **关联代码仓**:smf / upf(go-upf)
- **关联历史方案**:无(待补)
