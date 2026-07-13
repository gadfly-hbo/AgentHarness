PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS database_field_comments (
  id TEXT PRIMARY KEY,
  table_name TEXT NOT NULL,
  field_name TEXT NOT NULL,
  zh_name TEXT NOT NULL,
  zh_description TEXT NOT NULL,
  business_meaning TEXT NOT NULL,
  example_value TEXT,
  source_ref TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active'
    CHECK (status IN ('active', 'inactive', 'archived')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')),
  UNIQUE (table_name, field_name)
);

CREATE INDEX IF NOT EXISTS idx_database_field_comments_table
ON database_field_comments (table_name, status);
