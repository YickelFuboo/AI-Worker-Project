---
adr_id: ADR-006
title: 用户面转发采用 gtp5g 内核模块下沉
status: 已采纳
decided_at: 2026-06-22
deciders: []
superseded_by: null
related_elements: [upf]
related_repos: [upf]
last_modified: "2026-06-22T14:30:00+08:00"
---

# ADR-006:用户面转发采用 gtp5g 内核模块下沉

## 决策声明

upf 用户面数据通道下沉到 Linux 内核 gtp5g 模块执行 GTP-U 封装/解封装、PDR/FAR/QER 匹配与转发;用户态进程仅负责 PFCP 控制面信令处理与规则编译,数据面零拷贝走内核态。

## 1. 背景与问题

待历史架构设计文档补齐后填入。

## 2. 候选方案

待历史架构设计文档补齐后填入(至少应含:gtp5g 内核模块 vs DPDK 用户态 vs eBPF/XDP)。

## 3. 决策与理由

待历史架构设计文档补齐后填入。

## 4. 影响与代价

待历史架构设计文档补齐后填入(已识别约束:依赖特定内核版本与 gtp5g 模块版本范围)。

## 5. 关联

- **关联元素**:upf
- **关联代码仓**:upf(go-upf)
- **关联历史方案**:无(待补)
