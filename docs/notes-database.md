# DataBase Domain Notes

## Owner

OpenCode。

## 负责

- `DataBase/**` 内的事实数据、table/view、migration、seed、importer、validation、字段注释、数据库文档和血缘。
- 为联合契约提供稳定的事实读取或写入入口。

## 不负责

- 决定 OntoBase 权威业务语义。
- 修改 `OntoBase/**`、`MemoryBase/**`、`KnowledgeBase/**` 或共享 contract。

## 强制验证

- 遵守 `AGENTS.md` 的 Database Maintenance。
- schema 或链路变化后更新 `DataBase/docs/pls-consumption-guide.md`、`DataBase/console/app.js` 血缘及字段中文注释。
- handoff 中列出 migration、validation、数据兼容和 rollback 风险。

## 跨域出口

DataBase 通过已批准 contract 暴露 table、view、import/export 或 API；其他域不得把内部 SQLite 结构视为自身 schema。
