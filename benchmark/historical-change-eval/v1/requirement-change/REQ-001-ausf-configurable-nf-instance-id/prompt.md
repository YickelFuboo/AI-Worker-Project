# REQ-001：AUSF 支持配置 nfInstanceId

## 原始问题 / 需求

AUSF 当前每次启动都会生成新的 NF Instance ID，导致 Kubernetes 部署、外部检查或运维追踪时难以稳定识别同一个 NF。请支持在配置文件中可选配置 nfInstanceId；如果配置了合法 UUID v4 就使用它，否则保持原有每次启动自动生成 UUID 的行为。

## 期望结果

配置项中可以声明 nfInstanceId；合法 UUID v4 被用于 AUSF context 初始化；未配置时仍自动生成。
