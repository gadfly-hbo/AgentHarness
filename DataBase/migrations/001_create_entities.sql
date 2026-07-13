PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS entities (
  id TEXT PRIMARY KEY,
  entity_type TEXT NOT NULL,
  canonical_name TEXT NOT NULL,
  source_system TEXT NOT NULL,
  external_ref TEXT,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  attributes_json TEXT NOT NULL DEFAULT '{}'
    CHECK (json_valid(attributes_json)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_entities_source_external_ref
ON entities (source_system, external_ref)
WHERE external_ref IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_entities_type_status
ON entities (entity_type, status);
