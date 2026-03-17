---
name: docs-implentio-db
description: Query the Implentio PostgreSQL database. Use when asked to look up data, debug issues, or explore database state across cdm, client, public, analytics, or reconciliation schemas.
---

# Implentio Database Skill

## How to Connect

The user must supply a connection string (or it should be available as `$DB_URL`). Use the `mcp__pg-tunnel__query` MCP tool to run queries directly, or use psql:

```bash
psql "$DB_URL" -c "SELECT ..."
```

For multi-line queries:
```bash
psql "$DB_URL" <<'SQL'
SELECT ...
FROM ...
WHERE ...
SQL
```

**Never modify records** without explicit user approval (INSERT, UPDATE, DELETE, TRUNCATE).

---

## Schema Overview

| Schema | Purpose |
|--------|---------|
| **cdm** | Common Data Model — ingested operational data + synthetic reconciliation data (35 tables) |
| **client** | Application layer — denormalized data for UI/API (28+ tables) |
| **public** | Spring Batch monitoring + system metrics (8 tables) |
| **analytics** | Materialized views per-brand for Metabase (dynamic naming, brand-prefixed) |
| **reconciliation** | Brand-rule mappings for reconciliation outcomes (partitioned by brand_rule_id) |

### Data Flow
```
External sources → ingestion → cdm (raw+synthetic) → reconciliation → client (UI-ready)
                                                                   ↘ analytics (Metabase)
```

---

## CDM Schema

Core domain model with real (invoiced) and synthetic (expected) data. All tables have `brand_id`.

### Orders & Products
| Table | Key Columns |
|-------|-------------|
| `sales_order` | `id`, `brand_id`, `sales_order_number`, `order_time`, `status`, `destination_*` |
| `sales_order_line_item` | `id`, `sales_order_id`, `sku`, `quantity`, `quantity_uom` |
| `sales_order_line_item_fulfillment_request` | `id`, `sales_order_line_item_id`, `warehouse_id`, `fulfillment_request_date` |
| `product` | `id`, `brand_id`, `number`, `name`, `description`, `height_in`, `length_in`, `width_in`, `weight_oz` |
| `sku` | `id`, `brand_id`, `number`, `product_id` |
| `kit_component` | `id`, `brand_id`, `parent_product_id`, `constituent_sku_id`, `quantity` |

### Fulfillment & Shipping (Real)
| Table | Key Columns |
|-------|-------------|
| `fulfillment` | `id`, `brand_id`, `number`, `sales_order_number`, `warehouse_id`, `logistics_invoice_id`, `status` |
| `fulfillment_package` | `id`, `brand_id`, `fulfillment_id`, `carrier`, `service_level`, `tracking_number`, `weight_oz`, `shipping_zone`, `label_create_time`, `ship_time`, `delivery_time`, `address_*` |
| `fulfillment_package_line_item` | `id`, `brand_id`, `fulfillment_package_id`, `sku`, `quantity` |
| `fulfillment_summary` | `id`, `brand_id`, `effective_time`, `item_count` |
| `fulfillment_package_line_item_summary` | `id`, `brand_id`, `effective_time`, `item_count` |

### Fulfillment & Shipping (Synthetic/Expected)
| Table | Key Columns |
|-------|-------------|
| `synthetic_fulfillment` | `id`, `brand_id`, `real_fulfillment_id`, `sales_order_id`, `warehouse_id`, `synthetic_logistics_invoice_id` |
| `synthetic_fulfillment_package` | `id`, `brand_id`, `real_fulfillment_package_id`, `scenario_id`, `carrier`, `service_level`, `weight_oz`, `address_*` |
| `synthetic_fulfillment_package_line_item` | `id`, `brand_id`, `sku_id`, `real_fulfillment_package_line_item_id`, `rules_applied` (Json) |

### Invoices & Charges (Real)
| Table | Key Columns |
|-------|-------------|
| `logistics_invoice` | `id`, `brand_id`, `number`, `biller`, `invoice_date`, `period_start`, `period_end`, `due_date`, `ingestion_id` |
| `service_charge` | `id`, `brand_id`, `applied_to_id`, `applied_to_type`, `service_charge_type_id`, `quantity`, `unit_cost`, `total_cost` |
| `service_charge_type` | `id`, `brand_id`, `code`, `description`, `parent_service_charge_type_id`, `taxonomy_level` |

### Invoices & Charges (Synthetic/Expected)
| Table | Key Columns |
|-------|-------------|
| `synthetic_logistics_invoice` | `id`, `brand_id`, `real_logistics_invoice_id`, `invoice_period_start`, `invoice_period_end` |
| `synthetic_service_charge` | `id`, `brand_id`, `applied_to_id`, `applied_to_type`, `charge_type_id`, `quantity`, `unit_cost`, `total_cost`, `scenario_id`, `rules_applied` (Json), `is_scenario_primary` |
| `synthetic_service_charge_scenario` | `id`, `brand_id`, `applied_to_id`, `applied_to_type`, `name`, `consider_for_reconciliation`, `replacing_synthetic_service_charges` (string[]) |

### Reconciliation
| Table | Key Columns |
|-------|-------------|
| `reconciliation_run` | `id`, `brand_id`, `invoice_id`, `synthetic_logistics_invoice_id`, `status`, `start_time`, `end_time`, `logs` (Json) |
| `reconciled_service_charge` | `id`, `brand_id`, `real_service_charge_id`, `synthetic_service_charge_id`, `difference_amount`, `difference_cause_category`, `difference_root_cause`, `difference_status`, `user_review_status`, `is_rolled_up`, `alternate_scenario_difference_amount` |

### Rate Cards & Pricing
| Table | Key Columns |
|-------|-------------|
| `rate_card` | `id`, `brand_id`, `biller`, `warehouse_id`, `effective_start_date`, `effective_end_date` |
| `rate` | `id`, `brand_id`, `rate_card_id`, `service_charge_type_id`, `amount` (Numeric), `key_metadata` (Json) |
| `fuel_surcharge_rate` | `id`, `brand_id`, `carrier`, `effective_start_date`, `effective_end_date`, `rate_information` (Json) |

### Reference Data
| Table | Key Columns |
|-------|-------------|
| `shipping_zone` | `id`, `brand_id`, `origin_zip`, `destination_zip`, `carrier`, `service_level`, `zone` |
| `shipping_das` | `id`, `brand_id`, `postal_code`, `carrier`, `effective_from`, `effective_to`, `das`, `edas`, `rural`, `remote`, `remote_ak`, `remote_hi` |
| `warehouse` | `id`, `brand_id`, `name`, `address_line_1`, `address_line_2`, `city`, `state`, `postal_code`, `codes` (string[]) |
| `ingestion_record` | `id`, `brand_id`, `ingestion_source`, `ingestion_status`, `ingestion_time`, `metadata` (Json), `created_by`, `updated_by` |

### Brand Configuration
| Table | Key Columns |
|-------|-------------|
| `brand_rule` | `id`, `brand_id`, `type`, `name`, `rule` (Json), `applies_to`, `effective_from_ts`, `effective_to_ts`, `description`, `metadata` (Json) |
| `brand_carrier_service_translation` | `id`, `brand_id`, `brand_carrier_name`, `brand_service_level`, `normalized_carrier_name`, `normalized_service_level` |
| `lcc_service_level_group` | `id`, `brand_id`, `name`, `warehouse_id`, `biller`, `effective_start_date`, `effective_end_date`, `apply_lcc_to_invoice` |
| `lcc_service_level_equivalence_grouping` | `id`, `brand_id`, `group_id`, `carrier`, `service_level` |

---

## Client Schema

Denormalized/derived data for the Implentio web application. All tables use UUID PKs and `brand_id` for tenant isolation.

### Brand & User Management
| Table | Key Columns |
|-------|-------------|
| `brand` | `id`, `slug` (unique), `name`, `primary_contact_email`, `email_ingestion_identifier`, `status`, `ingestion_processing_rules` (Json), `view_by`, `custom_days`, `anchor_date` |
| `brand_flag` | `brand_id`, `flag` (composite PK — feature toggles) |
| `user` | `id`, `email` (unique), `first_name`, `last_name`, `cognito_sub_id` (unique), `brand_id`, `is_active` |
| `role` | `id`, `name` (unique) |
| `user_role` | `user_id`, `role_id` |

### Invoice & Reconciliation Results
| Table | Key Columns |
|-------|-------------|
| `invoice` | `id`, `brand_id`, `invoice_number`, `status`, `logistics_provider_name`, `total_charges` (Decimal 20,4), `types` (string[]), `warehouses` (string[]), `creditable_error_dollars`, `creditable_error_count`, `reconciliation_run_id`, `invoice_date`, `period_start`, `period_end` |
| `summary_invoice` | `id`, `brand_id`, `invoice_number`, `status`, `logistics_provider_name`, `total_charges`, `types`, `invoice_date` |
| `summary_invoice_service` | `id`, `brand_id`, `invoice_id`, `service`, `parent_service`, `total_charges` |
| `invoice_service_charge` | `id`, `brand_id`, `invoice_id`, `level`, `reconciled_service_charge_id`, `service_code`, `expected_quantity`, `expected_rate`, `expected_total`, `invoiced_quantity`, `invoiced_rate`, `invoiced_total`, `difference`, `error_count`, `logistics_invoice_id` |
| `invoice_service_errors` | `id`, `brand_id`, `invoice_id`, `service`, `parent_service`, `total_charges`, `error_dollars`, `unfavorable_error_dollars`, `favorable_error_dollars`, `error_count`, `reconciliation_run_id` |
| `invoice_error` | `id`, `brand_id`, `invoice_id`, `status`, `error_type`, `service`, `total_error_dollars`, `reconciliation_run_id`, `reconciled_service_charge_id` |
| `invoice_error_status` | `id`, `brand_id`, `invoice_id`, `invoice_error_id`, `error_type`, `service_type` |

### Sales Orders & Errors
| Table | Key Columns |
|-------|-------------|
| `sales_order` | `id`, `brand_id`, `sales_order_number`, `invoice_number`, `status`, `reconciliation_run_id`, `sales_order_type`, `label_create_time`, `ship_time`, `delivery_time`, `expected_metadata` (Json), `invoiced_metadata` (Json), `is_invoice_roll_up_item` |
| `order_details` | `id`, `brand_id`, `sales_order_id`, `fulfillment_id`, `level`, `sku`, `product_name`, `reconciled_service_charge_id`, `service_code`, `expected_quantity`, `expected_rate`, `expected_total`, `invoiced_quantity`, `invoiced_rate`, `invoiced_total`, `error`, `difference`, `error_count`, `alternate_sales_order_numbers` (string[]) |
| `sales_order_error` | `id`, `brand_id`, `sales_order_id`, `status`, `error_type`, `service`, `total_error_dollars`, `unfavorable_error_dollars`, `favorable_error_dollars`, `is_invoice_roll_up_item`, `scenario_metadata` (Json) |
| `sales_order_error_status` | `id`, `brand_id`, `sales_order_error_id`, `error_type`, `service_type`, `status` |
| `alternate_sales_order_numbers` | `id`, `brand_id`, `sales_order_number`, `alternate_sales_order_number`, `type` |
| `error_group_sales_orders` | `id`, `brand_id`, `error_group_identifier`, `sales_order_service_codes` (string[]), `error_group_root_causes` (string[]), `error_group_descriptions` (string[]) |
| `constituent_reconciled_service_charge` | `id`, `brand_id`, `reconciled_service_charge_id` |

### Credit Requests
| Table | Key Columns |
|-------|-------------|
| `credit_request` | `id`, `brand_id`, `status`, `user_id`, `invoice_number`, `amount_requested` (Decimal 20,4), `amount_received` (Decimal 20,4) |
| `credit_request_error` | `id`, `credit_request_id`, `sales_order_error_status_id` |

### Analytics & Reporting
| Table | Key Columns |
|-------|-------------|
| `analytics_ingested_invoices` | `id`, `brand_id`, `invoice_id`, `table_name` |
| `brand_report` | `id`, `brand_id`, `report_type` (INVOICE_REPORT \| BRAND_REPORT), `report_name`, `group_id`, `status` (UNREVIEWED \| REVIEWED \| ARCHIVED), `location`, `info` (string[]), `warnings` (string[]), `errors` (string[]) |
| `brand_template` | `id`, `brand_id`, `name`, `type`, `template` (Json), `description` |

### Workflow & System
| Table | Key Columns |
|-------|-------------|
| `workflow_state` | `id`, `brand_id`, `process_id` (unique), `workflow_type`, `status`, `current_step`, `file_name`, `state_data` (Json), `metadata` (Json), `error_message` |
| `brand_workflow_config` | `id`, `brand_id`, `workflow_type`, `config_name`, `version`, `is_active`, `is_default`, `config_data` (Json), `created_by` |
| `system_workflow_config_template` | `id`, `workflow_type`, `template_name`, `version`, `config_data` (Json) |
| `instructions` | `id`, `name` (unique), `instructions` (Text), `metadata` (Json) |
| `system_failure` | `id`, `brand_id`, `name`, `description`, `info` (Json with recommendations) |
| `service_type` | `id`, `service_type`, `service` |

### Metabase Integration
| Table | Key Columns |
|-------|-------------|
| `metabase_collection` | `id`, `brand_id`, `collection_id` (Int) |
| `metabase_dashboard` | `id`, `brand_id`, `name`, `metabase_dashboard_id` (Int), `dashboard_template_id` (Int) |
| `metabase_dashboard_template` | `id`, `metabase_id` (Int), `name`, `is_global`, `card_template_ids` (Int[]), `brand_ids` (string[]) |
| `metabase_card` | `id`, `brand_id`, `metabase_card_id` (Int), `card_template_id` (Int) |
| `metabase_card_template` | `id`, `metabase_id` (Int), `view_name`, `description`, `type` (MATERIALIZED_VIEW) |

---

## Public Schema

Spring Batch processing state + PostgreSQL monitoring.

| Table | Purpose |
|-------|---------|
| `batch_job_instance` | Job metadata (`job_instance_id`, `job_name`, `job_key`) |
| `batch_job_execution` | Job run records (`job_instance_id`, `status`, `start_time`, `end_time`, `exit_code`, `exit_message`) |
| `batch_step_execution` | Step details (`job_execution_id`, `step_name`, `status`, read/write/commit/filter counts) |
| `batch_job_execution_context` | Execution context blob |
| `batch_step_execution_context` | Step context blob |
| `pg_stat_statements` | Query statistics (`query`, `calls`, `total_exec_time`, `mean_exec_time`, `rows`) |
| `pg_stat_statements_info` | Statistics metadata (`stats_reset`) |
| `system_metrics` | Time-series metrics (`name`, `tags` Json, `value` Json) |

---

## Analytics Schema

**Currently empty** — reserved for per-brand materialized views used by Metabase.

- Tables are named `<brand_slug>_<view_name>` (e.g., `acme_monthly_invoices`)
- Discover existing analytics tables:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'analytics'
ORDER BY table_name;
```

- The `client.metabase_card_template` table tracks which views exist (via `view_name` column)

---

## Reconciliation Schema

Partitioned table mapping brand rules to reconciliation outcomes.

- **`reconciliation_root_cause`** — root table, partitioned by `brand_id`
- Partition tables named with hashed IDs: `p1_<uuid>` where UUID = `brand_rule_id`

Key columns on each partition:
- `brand_id` — tenant identifier
- `reconciliation_run_id` — which run produced this
- `reconciled_service_charge_id` — the charge being reconciled
- `brand_rule_id` — which rule was applied
- `sales_order_id` — associated order (nullable)

List all partitions:
```sql
SELECT tablename
FROM pg_tables
WHERE schemaname = 'reconciliation'
ORDER BY tablename;
```

---

## Cross-Schema Relationships

```
cdm.logistics_invoice.id        → client.invoice.reconciliation_run_id (indirect via recon run)
cdm.reconciled_service_charge.id → client.invoice_service_charge.reconciled_service_charge_id
cdm.reconciled_service_charge.id → client.invoice_error.reconciled_service_charge_id
cdm.reconciled_service_charge.id → client.sales_order_error (via sales_order_id)
cdm.service_charge_type.code    → client tables service_code columns
cdm.brand_rule.id               → reconciliation partition tables brand_rule_id
reconciliation.* .reconciliation_run_id → cdm.reconciliation_run.id
```

---

## Query Performance Guidelines

### Brand-Scoped Queries: Join Order Matters

Always start from the smallest table and work toward the largest. The typical cardinality order (smallest → largest) is:

```
client.brand (one row per brand)
  → client.invoice / cdm.logistics_invoice (tens per brand)
  → cdm.reconciliation_run (one per invoice)
  → cdm.reconciled_service_charge (hundreds–thousands per invoice)
  → cdm.service_charge (thousands per invoice)
  → client.sales_order (thousands per invoice)
  → cdm.fulfillment (thousands per invoice)
  → cdm.fulfillment_package (thousands–tens of thousands per invoice)
  → cdm.fulfillment_package_line_item (largest — one row per SKU per package)
```

**Rules:**
1. **Always start from `client.brand`** when filtering by slug or name — it's a single lookup row, and its `id` propagates down as a typed filter.
2. **Join through invoices before orders/fulfillments** — invoice narrows the result set dramatically before touching high-cardinality tables.
3. **Never `FROM cdm.fulfillment_package_line_item` directly** — always arrive there via `fulfillment_package → fulfillment → invoice`.
4. **Avoid `WHERE brand_id = (SELECT id FROM client.brand WHERE slug = ...)`** as a subquery on large tables — prefer an explicit JOIN so the planner can use the brand index on the join side.

**Preferred join pattern:**
```sql
-- Start narrow, expand outward
SELECT ...
FROM client.brand b                              -- 1 row
JOIN client.invoice i ON i.brand_id = b.id       -- ~tens
JOIN cdm.reconciliation_run rr ON rr.id = i.reconciliation_run_id  -- 1:1 with invoice
JOIN cdm.reconciled_service_charge rsc ON rsc.reconciliation_run_id = rr.id  -- hundreds
JOIN cdm.service_charge sc ON sc.id = rsc.real_service_charge_id   -- 1:1 with rsc
WHERE b.slug = 'brand-slug-here'
  AND i.invoice_number = 'INV-12345';            -- filter early
```

---

## Conventions & Patterns

### Multi-tenancy
Every business table has `brand_id`. Always filter by `brand_id` in production queries.

### Real vs Synthetic
- **Real** tables = data from carrier/logistics invoices (what was charged)
- **Synthetic** tables = expected data calculated by rules (what should have been charged)
- `reconciled_service_charge` is the diff: `real - synthetic = difference_amount`

### Common Column Patterns
- PKs: `id` (UUID string)
- Timestamps: `create_time`, `update_time` (auto-managed)
- Financial: `Numeric` in cdm, `Decimal(20,4)` in client
- Flexible data: `raw_data`, `metadata`, `rules_applied`, `scenario_metadata` (Json)

### Service Charge Taxonomy
`service_charge_type` is hierarchical via `parent_service_charge_type_id`. Walk it to get category tree.

---

## Common Query Patterns

### Find a brand by slug or name
```sql
-- By slug (exact):
SELECT id, slug, name, status
FROM client.brand
WHERE slug = 'brand-slug-here';

-- By name or slug (fuzzy, when slug is unknown):
SELECT id, slug, name, status
FROM client.brand
WHERE name ILIKE '%brand-name%' OR slug ILIKE '%brand-name%';
```

### Find invoices for a brand
```sql
SELECT i.invoice_number, i.status, i.total_charges, i.creditable_error_dollars, i.invoice_date
FROM client.invoice i
JOIN client.brand b ON b.id = i.brand_id
WHERE b.slug = 'brand-slug-here'
ORDER BY i.invoice_date DESC
LIMIT 20;
```

### Find reconciliation errors for an invoice
```sql
SELECT ie.error_type, ie.service, ie.total_error_dollars, ie.status
FROM client.invoice_error ie
JOIN client.invoice i ON i.id = ie.invoice_id
WHERE i.invoice_number = 'INV-12345';
```

### Find sales order reconciliation details
```sql
SELECT so.sales_order_number, so.status, soe.error_type, soe.service, soe.total_error_dollars
FROM client.sales_order so
LEFT JOIN client.sales_order_error soe ON soe.sales_order_id = so.id
JOIN client.brand b ON b.id = so.brand_id
WHERE b.slug = 'brand-slug-here'
  AND so.invoice_number = 'INV-12345';
```

### Inspect a reconciliation run
```sql
SELECT rr.id, rr.status, rr.start_time, rr.end_time
FROM cdm.reconciliation_run rr
JOIN client.invoice i ON i.reconciliation_run_id = rr.id
WHERE i.invoice_number = 'INV-12345';
```

### Find reconciled service charges for an invoice
```sql
SELECT rsc.id, rsc.difference_amount, rsc.difference_cause_category,
       rsc.difference_root_cause, rsc.difference_status, rsc.user_review_status
FROM cdm.reconciled_service_charge rsc
JOIN cdm.reconciliation_run rr ON rr.id = rsc.reconciliation_run_id
JOIN client.invoice i ON i.reconciliation_run_id = rr.id
WHERE i.invoice_number = 'INV-12345'
  AND rsc.difference_amount != 0
LIMIT 50;
```

### Check ingestion records for a brand
```sql
SELECT ingestion_source, ingestion_status, ingestion_time, metadata
FROM cdm.ingestion_record
WHERE brand_id = '<brand-uuid>'
ORDER BY ingestion_time DESC
LIMIT 20;
```

### Check brand rules
```sql
SELECT br.type, br.name, br.applies_to, br.effective_from_ts, br.effective_to_ts
FROM cdm.brand_rule br
JOIN client.brand b ON b.id = br.brand_id
WHERE b.slug = 'brand-slug-here'
ORDER BY br.type, br.name;
```

### Find service charge type hierarchy
```sql
WITH RECURSIVE sct_tree AS (
  SELECT id, code, description, parent_service_charge_type_id, taxonomy_level, brand_id
  FROM cdm.service_charge_type
  WHERE parent_service_charge_type_id IS NULL
  UNION ALL
  SELECT s.id, s.code, s.description, s.parent_service_charge_type_id, s.taxonomy_level, s.brand_id
  FROM cdm.service_charge_type s
  JOIN sct_tree t ON t.id = s.parent_service_charge_type_id
)
SELECT * FROM sct_tree
WHERE brand_id = '<brand-uuid>'
ORDER BY taxonomy_level, code;
```

### Check workflow state for a brand
```sql
SELECT process_id, workflow_type, status, current_step, error_message, updated_at
FROM client.workflow_state
WHERE brand_id = '<brand-uuid>'
ORDER BY updated_at DESC
LIMIT 10;
```

### Check system failures
```sql
SELECT name, description, info, created_at
FROM client.system_failure
WHERE brand_id = '<brand-uuid>'
ORDER BY created_at DESC;
```

### Check active batch jobs
```sql
SELECT ji.job_name, je.status, je.start_time, je.end_time, je.exit_code, je.exit_message
FROM public.batch_job_execution je
JOIN public.batch_job_instance ji ON ji.job_instance_id = je.job_instance_id
WHERE je.status NOT IN ('COMPLETED', 'FAILED')
ORDER BY je.start_time DESC;
```

### List analytics tables for a brand
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'analytics'
  AND table_name LIKE 'brand-slug-here%'
ORDER BY table_name;
```

---

## Source Files

For deeper investigation, the canonical schema sources are:
- **Client schema**: `packages/implentio-app/packages/api-v2/prisma/schema.prisma`
- **CDM generated types**: `packages/implentio-app/packages/api-v2/src/generated/db-cdm.d.ts`
- **Client generated types**: `packages/implentio-app/packages/api-v2/src/generated/db-client.ts`
- **Reconciliation types**: `packages/implentio-app/packages/api-v2/src/generated/db-reconciliation.d.ts`
- **CDM table schemas**: `packages/implentio-app/packages/api-v2/src/core/recon-engine-v2/query-builder/schemas/cdm-table-schemas.ts`
- **DB docs**: `docs/overviews/database_schema_guide.md`
