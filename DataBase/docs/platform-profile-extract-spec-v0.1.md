# 平台画像真实数据导入规格 v0.1

本文档定义三大平台真实人群画像数据进入 SQLite 前的标准长表格式。

## 目标

不同平台、不同对象维度的画像导出格式会不一致。导入 SQLite 前，先统一转换为
`platform_profile_tag_metrics` 所需的长表结构，再进入 PLS 语义映射和特征聚合。

适用对象包括：

- 平台
- 商圈
- 店铺
- 账号
- 活动
- 业务场景

## 标准字段

| 字段 | 必填 | 说明 |
| --- | --- | --- |
| `workspace_id` | 是 | 业务工作空间或项目空间。 |
| `profile_id` | 是 | 一次画像导出或画像快照ID。 |
| `canonical_object_key` | 是 | 渠道对象统一键，例如 `account:douyin:101326115008`。 |
| `channel_object_type` | 是 | `platform`、`trade_area`、`store`、`account`、`marketing_event`、`business_scenario`。 |
| `channel_object_name` | 是 | 渠道对象展示名称。 |
| `platform` | 是 | 天猫、抖音、京东等。 |
| `tag_type` | 是 | 平台标签类型。 |
| `leaf_label` | 是 | 平台标签值。 |
| `platform_tag_catalog_id` | 否 | 平台标签目录ID。只有当 `platform + tag_type + leaf_label` 匹配到多条目录记录时必填。 |
| `metric_name` | 是 | 指标名，例如 `share`、`tgi`、`count`、`index`、`score`。 |
| `metric_value` | 是 | 可计算数值。百分比应去掉 `%` 后保存为数值。 |
| `metric_unit` | 是 | 指标单位，例如 `percent`、`index`、`count`、`score`。 |
| `metric_display_value` | 否 | 来源文件中的原始展示值，例如 `47.28%`。 |
| `profile_time_window` | 是 | 画像统计时间窗，例如 `2026Q2`。 |
| `sample_size` | 否 | 样本量，不知道时为空。 |
| `source_file` | 是 | 来源文件路径或留存文件路径。 |
| `source_row` | 是 | 来源行号。 |
| `source_batch_id` | 是 | 导入批次ID。 |
| `raw_json` | 是 | 原始行 JSON，用于审计和回放。 |

## 写入入口

真实画像明细只写入：

```text
platform_profile_tag_metrics
```

不要直接写入这些 view：

```text
v_platform_profile_tag_metric_semantics
v_platform_profile_channel_dimension_features
v_platform_profile_channel_feature_matrix
```

## 导入方式

推荐先使用 HTML console：

```bash
node DataBase/console/server.mjs
```

打开本地页面后进入“真实画像导入”，下载 CSV 模板，先预检，再导入数据库。
该页面支持两种导入方式：

- 选择一个或多个 CSV 文件。
- 选择一个包含多个 CSV 的文件夹。

也可以使用命令行导入器：

```bash
node DataBase/importers/import_platform_profile_tag_metrics.mjs path/to/profile.csv
node DataBase/importers/import_platform_profile_tag_metrics.mjs path/to/profile.csv --apply
node DataBase/importers/import_platform_profile_tag_metrics.mjs path/to/profile_folder --apply
```

不加 `--apply` 时只做预检，不写入 SQLite。

## 占比归一化

正式入库前，导入器会先对标签值占比做归一化处理。处理规则：

- 只处理 `metric_name = 'share'` 且 `metric_unit` 为 `percent`、`percentage` 或 `ratio` 的行。
- `percent` / `percentage` 的同组目标合计为 `100`。
- `ratio` 的同组目标合计为 `1`。
- 归一化分组口径为：
  `workspace_id + profile_id + canonical_object_key + platform + tag_type + metric_name + metric_unit + profile_time_window + source_batch_id`。
- 同一个文件夹一次导入多个 CSV 时，会先合并所有文件再按上述口径归一化。
- 写入 `platform_profile_tag_metrics.metric_value` 的是归一化后的数值。
- 来源原始数值会写入 `raw_json.normalization.raw_metric_value`，归一化分母会写入
  `raw_json.normalization.normalization_group_sum`。

预检结果会展示原始值、归一化后值和同组原始合计。确认无误后再执行正式导入。

## 推荐消费入口

| 需求 | 读取对象 |
| --- | --- |
| 查看真实画像标签指标和 PLS 语义 | `v_platform_profile_tag_metric_semantics` |
| 读取渠道对象在每个 PLS 维度上的行式特征 | `v_platform_profile_channel_dimension_features` |
| 读取渠道对象九维宽表特征 | `v_platform_profile_channel_feature_matrix` |

## 聚合原则

`metric_name` 不同的指标不得混合聚合。比如：

- `share` 表示占比。
- `tgi` 表示相对指数。
- `count` 表示人数或次数。

因此维度特征和九维宽表都保留 `metric_name` 和 `metric_unit`。

## 导入前校验

导入真实画像文件前，至少检查：

- `platform + tag_type + leaf_label` 能匹配到 `platform_tag_catalog`。
- 如果上一步匹配到多条目录记录，需要在 CSV 中补充 `platform_tag_catalog_id`。
- 匹配到的标签值已经进入 `pls_tag_value_dimension_mappings`。
- 百分比、TGI、人数等指标已拆成多行，而不是塞进同一字段。
- `share` 指标会在导入器内归一化，不需要用户手工把每个标签类型的占比加总调到 100%。
- 来源文件和批次号稳定可追溯。
