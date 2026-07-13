PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_semantic_dimensions (
  id TEXT PRIMARY KEY,
  layer_code TEXT NOT NULL
    CHECK (layer_code IN ('P', 'L', 'S')),
  layer_name TEXT NOT NULL,
  dimension_code TEXT NOT NULL UNIQUE,
  dimension_name TEXT NOT NULL,
  dimension_definition TEXT NOT NULL,
  business_strategy TEXT NOT NULL,
  source_platform TEXT NOT NULL DEFAULT '通用 (映射标准)',
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE INDEX IF NOT EXISTS idx_pls_semantic_dimensions_layer
ON pls_semantic_dimensions (layer_code, status);
