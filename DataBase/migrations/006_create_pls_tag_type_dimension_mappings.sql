PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS pls_tag_type_dimension_mappings (
  id TEXT PRIMARY KEY,
  platform TEXT NOT NULL,
  tag_type TEXT NOT NULL,
  dimension_id TEXT,
  mapping_status TEXT NOT NULL DEFAULT 'proposed'
    CHECK (mapping_status IN ('proposed', 'approved', 'review_needed', 'unmapped', 'rejected')),
  mapping_method TEXT NOT NULL DEFAULT 'rule'
    CHECK (mapping_method IN ('rule', 'manual', 'imported')),
  confidence REAL NOT NULL DEFAULT 0
    CHECK (confidence >= 0 AND confidence <= 1),
  rationale TEXT NOT NULL,
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  FOREIGN KEY (dimension_id)
    REFERENCES pls_semantic_dimensions(id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  UNIQUE (platform, tag_type)
);

CREATE INDEX IF NOT EXISTS idx_pls_tag_type_dimension_mappings_dimension
ON pls_tag_type_dimension_mappings (dimension_id, mapping_status);

CREATE INDEX IF NOT EXISTS idx_pls_tag_type_dimension_mappings_platform
ON pls_tag_type_dimension_mappings (platform, mapping_status);
