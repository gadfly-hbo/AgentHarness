PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS platform_tag_catalog (
  id TEXT PRIMARY KEY,
  platform TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  level_1 TEXT,
  level_2 TEXT,
  level_3 TEXT,
  level_4 TEXT,
  leaf_label TEXT NOT NULL,
  label_path TEXT NOT NULL,
  source_file TEXT NOT NULL,
  source_row INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (platform, source_file, source_row)
);

CREATE INDEX IF NOT EXISTS idx_platform_tag_catalog_platform_type
ON platform_tag_catalog (platform, tag_type, status);

CREATE INDEX IF NOT EXISTS idx_platform_tag_catalog_leaf
ON platform_tag_catalog (platform, leaf_label, status);
