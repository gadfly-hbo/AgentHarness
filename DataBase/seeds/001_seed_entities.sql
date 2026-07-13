PRAGMA foreign_keys = ON;

INSERT INTO entities (
  id,
  entity_type,
  canonical_name,
  source_system,
  external_ref,
  status,
  attributes_json,
  created_at,
  updated_at
)
VALUES
  (
    'ent_project_modelevol',
    'project',
    'ModelEvol',
    'manual-intake',
    'project:modelevol',
    'active',
    json_object(
      'consumer_need',
      'model_algorithm_iteration',
      'notes',
      'Needs durable records for models, datasets, experiments, predictions, and evaluations.'
    ),
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'ent_project_pls',
    'project',
    'PLS',
    'manual-intake',
    'project:pls',
    'active',
    json_object(
      'consumer_need',
      'profile_and_audience_segmentation',
      'notes',
      'Needs profile records and audience segmentation model records on top of DataBase.'
    ),
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'ent_model_pls_audience_segmentation',
    'model',
    'PLS Audience Segmentation Model',
    'manual-intake',
    'model:pls-audience-segmentation',
    'active',
    json_object(
      'owner_project',
      'PLS',
      'model_kind',
      'audience_segmentation',
      'notes',
      'User-created segmentation model planned to be built on the DataBase foundation.'
    ),
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'ent_module_pls_profile',
    'module',
    'PLS Profile Module',
    'manual-intake',
    'module:pls-profile',
    'active',
    json_object(
      'owner_project',
      'PLS',
      'module_kind',
      'profile',
      'notes',
      'Consumes structured profile facts and model inference outputs.'
    ),
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  ),
  (
    'ent_database_agentharness',
    'database',
    'AgentHarness DataBase',
    'manual-intake',
    'database:agentharness',
    'active',
    json_object(
      'storage_engine',
      'sqlite',
      'build_style',
      'one_table_at_a_time',
      'notes',
      'Structured data foundation for ModelEvol, PLS, and future AgentHarness consumers.'
    ),
    '2026-07-13T00:00:00.000Z',
    '2026-07-13T00:00:00.000Z'
  )
ON CONFLICT(id) DO UPDATE SET
  entity_type = excluded.entity_type,
  canonical_name = excluded.canonical_name,
  source_system = excluded.source_system,
  external_ref = excluded.external_ref,
  status = excluded.status,
  attributes_json = excluded.attributes_json,
  updated_at = excluded.updated_at;
