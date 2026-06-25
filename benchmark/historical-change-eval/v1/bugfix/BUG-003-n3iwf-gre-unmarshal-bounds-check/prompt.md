# BUG-003：N3IWF GRE Unmarshal 短包边界检查

## 原始问题 / 需求

N3IWF 的 GRE 报文 Unmarshal 在处理短 buffer 或截断的可选 Key 字段时不应发生越界 panic。请在读取 GRE 基础头和可选字段前做长度检查，并添加短包、截断 Key 字段和合法报文测试。

## 期望结果

短包返回明确错误；合法报文仍能正常解析；新增单元测试覆盖异常和正常路径。
