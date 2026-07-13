PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_platform_tag_mappings (
  id TEXT PRIMARY KEY,
  dimension_id TEXT NOT NULL,
  platform TEXT NOT NULL,
  raw_tag_fields TEXT NOT NULL,
  raw_enum_examples TEXT NOT NULL,
  data_availability TEXT NOT NULL
    CHECK (data_availability IN ('direct', 'manual', 'missing', 'inferred')),
  mapping_strategy TEXT NOT NULL,
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (dimension_id)
    REFERENCES pls_semantic_dimensions(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (dimension_id, platform)
);

CREATE INDEX IF NOT EXISTS idx_pls_platform_tag_mappings_platform
ON pls_platform_tag_mappings (platform, status);

CREATE INDEX IF NOT EXISTS idx_pls_platform_tag_mappings_dimension
ON pls_platform_tag_mappings (dimension_id, status);
