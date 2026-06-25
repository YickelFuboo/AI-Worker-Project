# REQ-009：PCF Traffic Influence 生成 PCC Rule 时加入 charging data

## 原始问题 / 需求

PCF 根据 Traffic Influence 数据生成 PCC rule 时，需要同时携带 charging data，使后续策略和计费流程能基于 Traffic Influence 规则关联计费信息。请调整 PCC rule 构造逻辑，将 Traffic Influence 中的计费相关数据映射到规则中。

## 期望结果

PCC rule 构造会从 Traffic Influence 数据中设置 charging data 相关字段。
