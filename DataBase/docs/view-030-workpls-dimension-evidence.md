# v_workpls_dimension_evidence

`v_workpls_dimension_evidence` 是 WorkPLS 正式 Dimension Evidence 的 DataBase 只读读取面。

## 粒度

一条来源画像快照、一个 `metric_name + unit + metric_aggregation`、一个 PLS 维度一行。

业务唯一键：

```text
workspace_id
+ profile_id
+ canonical_object_key
+ data_version
+ metric_name
+ unit
+ profile_time_window
+ source_batch_id
+ dimension_key
```

## 来源链路

```text
platform_profile_tag_metrics
  -> v_platform_profile_tag_metric_semantics
  -> v_platform_profile_channel_dimension_features
  -> v_workpls_dimension_evidence

v_pls_audience_profile_snapshots
  -> v_workpls_dimension_evidence
```

view 只输出能按 `workspace_id + profile_id + canonical_object_key + source_batch_id + profile_time_window` 唯一绑定到 `v_pls_audience_profile_snapshots` 的行。绑定不上、多重绑定、workspace 不一致、profile/object 不一致或必要字段不合格时不输出。

## 字段

字段顺序固定为：

1. `workspace_id`
2. `snapshot_id`
3. `profile_id`
4. `canonical_object_key`
5. `data_version`
6. `metric_name`
7. `metric_aggregation`
8. `dimension_key`
9. `dimension_label`
10. `value`
11. `unit`
12. `profile_time_window`
13. `source_batch_id`
14. `source_quality_flags_json`
15. `source_evidence_refs_json`
16. `metric_row_count`
17. `tag_type_count`
18. `tag_value_count`
19. `avg_mapping_confidence`
20. `latest_metric_updated_at`
21. `latest_mapping_updated_at`

## 口径

- `snapshot_id = profile_id`。
- `data_version` 来自唯一绑定的 `v_pls_audience_profile_snapshots`。
- `metric_aggregation = 'sum'`。
- `dimension_key = dimension_code`。
- `dimension_label = dimension_name`。
- `value = dimension_metric_sum`。
- `unit = metric_unit`。
- `source_quality_flags_json` 继承唯一绑定 snapshot 的 `quality_flags_json`。
- `source_evidence_refs_json` 聚合真实 `platform_profile_tag_metric` 来源记录。

## Evidence Refs

`source_evidence_refs_json` 是 JSON array。每个元素至少包含：

```json
{
  "sourceSystem": "agentharness",
  "sourceRecordType": "platform_profile_tag_metric",
  "sourceRecordId": "metric_id",
  "sourceBatchId": "source_batch_id",
  "sourceFile": "source_file",
  "sourceRow": 1,
  "platformTagCatalogId": "platform_tag_catalog_id"
}
```

数组按稳定 JSON 字符串排序并去重。该 view 不输出 SQLite `rowid`、`raw_json`、SQL/view 名、绝对文件路径正文或 WorkPLS 派生 quality status。

## Fail Closed

以下情况不输出行：

- 没有真实指标或没有 approved PLS 标签值映射。
- `value` 非有限数。
- `metric_name`、`unit`、`dimension_key`、`dimension_label`、`source_evidence_refs_json` 缺失或为空。
- snapshot 绑定失败或存在多重绑定。

当前 `platform_profile_tag_metrics` 与 `v_platform_profile_channel_dimension_features` 真实链路为 0 行；本 view 目前只验证 schema/read-surface，不代表正式 Comparison Run 已有真实数据覆盖。
