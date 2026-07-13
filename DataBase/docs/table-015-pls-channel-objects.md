# Table 015: `pls_channel_objects`

## Purpose

`pls_channel_objects` stores the master objects from the PLS channel profile
object library.

It is the first real-data landing table for the PLS “渠道画像” module in
AgentHarness:

```text
PLS channel object library -> pls_channel_objects
```

## Why This Table Exists

PLS 渠道画像不是单一账号画像，而是一套渠道对象库。对象包括平台、商圈、
店铺、账号、活动和业务场景。AgentHarness 需要先承接这些对象主数据，
再继续承接对象关系、人群画像和商品适配画像。

This table keeps the business identity, version lineage, review status, quality
flags, and raw JSON together so future imports can be audited and replayed.

## Files

- Migration: `DataBase/migrations/015_create_pls_channel_objects.sql`
- Seed: `DataBase/seeds/015_seed_pls_channel_objects.sql`
- Validation: `DataBase/validations/015_validate_pls_channel_objects.sql`

## Current Scope

The seed data uses the six-object mock package from PLS channel profile 2.0:

- platform
- trade_area
- store
- account
- marketing_event
- business_scenario

These rows validate the table shape before importing real PLS workspace data.

## Next Work

Create `pls_channel_object_bindings` to preserve relationships such as:

```text
platform -> account
trade_area -> store
marketing_event -> channel entity
business_scenario -> channel entity
```
