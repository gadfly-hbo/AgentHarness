# View 010: `v_pls_platform_tag_value_semantics`

## Purpose

`v_pls_platform_tag_value_semantics` is the product-facing consumption view for
PLS-aligned platform tag values.

It expands each platform tag value with its PLS layer, dimension code, Chinese
dimension name, definition, business strategy, confidence, and traceability IDs.

## Why This View Exists

Downstream products should not need to join four tables just to understand one
platform tag value. This view gives PLS profile modules and ModelEvol a stable
read surface:

```text
platform + tag_type + leaf_label -> PLS layer + PLS dimension
```

## Files

- Migration: `DataBase/migrations/010_create_v_pls_platform_tag_value_semantics.sql`
- Validation: `DataBase/validations/010_validate_v_pls_platform_tag_value_semantics.sql`

## Current Scope

Tmall, Douyin, and JD are included. Xiaohongshu is intentionally excluded.

## Consumption Guidance

Use this view for read-only product and model consumption. If a tag value needs
manual correction, update `pls_tag_value_dimension_mappings`, not this view.
