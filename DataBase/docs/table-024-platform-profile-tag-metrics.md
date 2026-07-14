# Table 024: `platform_profile_tag_metrics`

## Purpose

`platform_profile_tag_metrics` stores real platform profile tag metrics in a
standard long-table format.

It is the write entry for real audience profile exports from Tmall, Douyin, JD,
and future platforms. It is designed for platform, trade area, store, account,
campaign, and business-scenario profile data.

## Files

- Migration: `DataBase/migrations/024_create_platform_profile_tag_metrics.sql`
- Validation: `DataBase/validations/024_validate_platform_profile_tag_metrics.sql`
- Spec: `DataBase/docs/platform-profile-extract-spec-v0.1.md`
- Frontend importer: `DataBase/console` 的“真实画像导入”页面
- CLI importer: `DataBase/importers/import_platform_profile_tag_metrics.mjs`

## Notes

- One row stores one metric for one platform tag value.
- `metric_name` separates `share`, `tgi`, `count`, `index`, `score`, and other
  metrics.
- Percentages should be converted to numeric values in `metric_value`, while the
  original display value can be retained in `metric_display_value`.
- If `platform + tag_type + leaf_label` is ambiguous, the import CSV must provide
  `platform_tag_catalog_id`.
- The importer normalizes `share` metrics before writing to this table. The
  normalized value is stored in `metric_value`, and the raw value is retained in
  `raw_json.normalization.raw_metric_value`.
