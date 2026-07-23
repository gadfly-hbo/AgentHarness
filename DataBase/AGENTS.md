# AgentHarness DataBase 工作规则

## 目的

为 `DataBase/**` 提供只在数据库任务中加载的结构、导入、文档和血缘维护规则。根目录 `AGENTS.md` 与中央 structured routing 继续适用。

## 使用方式

- 新建或实质修改 table、view、column、key、index、constraint、migration、导入或聚合前，先执行根规则的 Structural Confirmation Gate。
- 读取真实 schema、migration、数据样例、消费入口和 `DataBase/docs/pls-consumption-guide.md`，一次只按已确认产品需求扩展结构。
- 真实数据与现有承接结构不匹配时可以提出调整，但不能根据猜测补字段或覆盖未确认 contract。

## 同步维护

以下变化必须同步更新维护入口：

- table/view/column 的新增、删除、重命名或语义变化。
- 数据导入、上下游依赖、特征聚合或产品读取入口变化。
- 新数据源暴露现有结构与真实数据不一致。

对应要求：

- 更新 `DataBase/docs/pls-consumption-guide.md`，说明推荐读写入口、字段语义、校验和注意事项。
- 更新 `DataBase/console/app.js` 的静态血缘图，使上下游关系与当前 schema 一致。
- 新增或修改字段时维护 `database_field_comments` 的简体中文业务解释。
- migration、seed、validation 和 docs 保持现有编号、命名和执行顺序连续。

## 验证

- migration 必须有对应 seed/import 依据和 validation；验证真实触发约束，不以脚本成功退出代替数据断言。
- 结构变更核对 schema、关键行数、外键/唯一性、消费 view、字段注释和血缘展示。
- 修改 SQLite fixture 或真实导入结果时遵守项目数据安全和删除确认规则，不擅自清理历史数据。

## 示例

新增消费字段时，先确认业务含义、粒度、身份、null/default、来源和读取入口，再创建 migration/validation，并同步消费指南、字段注释与血缘图；不能只在现有 table 上直接加列。

## 注意事项

- `DataBase/README.md` 保存当前运行命令和目录索引，不在本文件重复完整 migration 清单。
- 联合 contract 变化仍由 Codex 批准；DataBase agent 不通过实现倒逼其他域同步。
- 更严格的任务 brief 或 contract 优先。
