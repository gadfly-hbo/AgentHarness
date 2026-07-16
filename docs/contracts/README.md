# Cross-Domain Contracts

## 目的

本目录保存四库一台及外部产品消费 Harness 时的显式联合契约。

## 所有权

- Codex 拥有 contract 的批准、版本、兼容和跨域协调。
- 提供能力的域拥有其内部实现，但不能单方面改变已发布 shape。
- 消费域只能按 contract 使用能力，不得依赖未声明的内部 table、文件或字段。

## Contract 必须说明

- Upstream 与 downstream。
- 业务对象、稳定身份和数据粒度。
- 输入输出 shape、读写入口和协议。
- provenance、时间窗、版本、置信度和审计 metadata。
- 错误、空数据、降级和重试行为。
- 审批、刷新、回写和发布规则。
- 兼容、migration、rollback 和验证方法。
- owner 与 future change 流程。

## 变更流程

1. 域 agent 使用 `docs/templates/CONTRACT_CHANGE_REQUEST.template.md` 提案。
2. Codex 评估所有受影响域。
3. Codex 决定 `accepted`、`rejected` 或 `deferred`。
4. accepted 后先更新 contract，再创建按依赖排序的域任务。
5. 所有域 handoff approved 后运行 contract test 和集成验证。

`docs/four-bases-one-console-contract.md` 是顶层 contract；具体项目 contract 在本目录单独建文件。
