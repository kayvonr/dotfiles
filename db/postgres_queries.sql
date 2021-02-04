-- currently running
select pid, usename, client_addr, backend_start, xact_start, query_start, now() - query_start as run_time, state, trim(regexp_replace(query, E'[\n\r]+', ' ', 'g' )) as query from pg_stat_activity where state <> 'idle' order by state, run_time desc
-- all visibile open connections (minus aws admin connections)
select pid, usename, client_addr, backend_start, xact_start, query_start, case when state = 'idle' then interval '0 minutes' else  now() - query_start end as run_time, state, trim(regexp_replace(query, E'[\n\r]+', ' ', 'g' )) as query from pg_stat_activity where usename is not null and usename <> 'rdsadmin' order by state, run_time desc

-- blocked
SELECT blocked_locks.pid AS blocked_pid, blocked_activity.usename AS blocked_user, blocking_locks.pid AS blocking_pid, blocking_activity.usename AS blocking_user, blocked_activity.query AS blocked_statement, blocking_activity.query AS current_statement_in_blocking_process FROM pg_catalog.pg_locks blocked_locks JOIN pg_catalog.pg_stat_activity blocked_activity ON blocked_activity.pid = blocked_locks.pid JOIN pg_catalog.pg_locks blocking_locks ON blocking_locks.locktype = blocked_locks.locktype AND blocking_locks.DATABASE IS NOT DISTINCT FROM blocked_locks.DATABASE AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid AND blocking_locks.pid != blocked_locks.pid JOIN pg_catalog.pg_stat_activity blocking_activity ON blocking_activity.pid = blocking_locks.pid WHERE NOT blocked_locks.GRANTED

-- index stats + usage overview
SELECT t.schemaname, t.tablename, indexname, c.reltuples AS num_rows, pg_size_pretty(pg_relation_size(quote_ident(t.schemaname)::text || '.' || quote_ident(t.tablename)::text)) AS table_size, pg_size_pretty(pg_relation_size(quote_ident(t.schemaname)::text || '.' || quote_ident(indexrelname)::text)) AS index_size, CASE WHEN indisunique THEN 'Y' ELSE 'N' END AS UNIQUE, number_of_scans, tuples_read, tuples_fetched FROM pg_tables t LEFT OUTER JOIN pg_class c ON t.tablename = c.relname LEFT OUTER JOIN ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns, idx_scan AS number_of_scans, idx_tup_read AS tuples_read, idx_tup_fetch AS tuples_fetched, indexrelname, indisunique, schemaname FROM pg_index x JOIN pg_class c ON c.oid = x.indrelid JOIN pg_class ipg ON ipg.oid = x.indexrelid JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid) AS foo ON t.tablename = foo.ctablename AND t.schemaname = foo.schemaname WHERE t.schemaname NOT IN ('pg_catalog', 'information_schema') ORDER BY 6 desc, 1,2 LIMIT 20;

-- largest relations
SELECT nspname || '.' || relname AS "relation", pg_size_pretty(pg_relation_size(C.oid)) AS "size" FROM pg_class C LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace) WHERE nspname NOT IN ('pg_catalog', 'information_schema') ORDER BY pg_relation_size(C.oid) DESC LIMIT 20

-- analyze + vacuum + dead tuple stats
WITH table_opts AS ( SELECT pg_class.oid, relname, nspname, array_to_string(reloptions, '') AS relopts FROM pg_class INNER JOIN pg_namespace ns ON relnamespace = ns.oid), vacuum_settings AS ( SELECT oid, relname, nspname, CASE WHEN relopts LIKE '%autovacuum_vacuum_threshold%' THEN substring(relopts, '.autovacuum_vacuum_threshold=([0-9.]+).')::integer ELSE current_setting('autovacuum_vacuum_threshold')::integer END AS autovacuum_vacuum_threshold, CASE WHEN relopts LIKE '%autovacuum_vacuum_scale_factor%' THEN substring(relopts, '.autovacuum_vacuum_scale_factor=([0-9.]+).')::real ELSE current_setting('autovacuum_vacuum_scale_factor')::real END AS autovacuum_vacuum_scale_factor FROM table_opts) SELECT vacuum_settings.nspname AS schema, vacuum_settings.relname AS table, to_char(psut.last_vacuum, 'YYYY-MM-DD HH24:MI') AS last_vacuum, to_char(psut.last_autovacuum, 'YYYY-MM-DD HH24:MI') AS last_autovacuum, to_char(pg_class.reltuples, '9G999G999G999') AS rowcount, to_char(psut.n_dead_tup, '9G999G999G999') AS dead_rowcount, to_char(autovacuum_vacuum_threshold + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples), '9G999G999G999') AS autovacuum_threshold, CASE WHEN autovacuum_vacuum_threshold + (autovacuum_vacuum_scale_factor::numeric * pg_class.reltuples) < psut.n_dead_tup THEN 'yes' END AS expect_autovacuum FROM pg_stat_user_tables psut INNER JOIN pg_class ON psut.relid = pg_class.oid INNER JOIN vacuum_settings ON pg_class.oid = vacuum_settings.oid ORDER BY 1

-- relation bloat
SELECT
  current_database(), schemaname, tablename, /*reltuples::bigint, relpages::bigint, otta,*/
  ROUND((CASE WHEN otta=0 THEN 0.0 ELSE sml.relpages::float/otta END)::numeric,1) AS tbloat,
  CASE WHEN relpages < otta THEN 0 ELSE bs*(sml.relpages-otta)::BIGINT END AS wastedbytes,
  iname, /*ituples::bigint, ipages::bigint, iotta,*/
  ROUND((CASE WHEN iotta=0 OR ipages=0 THEN 0.0 ELSE ipages::float/iotta END)::numeric,1) AS ibloat,
  CASE WHEN ipages < iotta THEN 0 ELSE bs*(ipages-iotta) END AS wastedibytes
FROM (
  SELECT
    schemaname, tablename, cc.reltuples, cc.relpages, bs,
    CEIL((cc.reltuples*((datahdr+ma-
      (CASE WHEN datahdr%ma=0 THEN ma ELSE datahdr%ma END))+nullhdr2+4))/(bs-20::float)) AS otta,
    COALESCE(c2.relname,'?') AS iname, COALESCE(c2.reltuples,0) AS ituples, COALESCE(c2.relpages,0) AS ipages,
    COALESCE(CEIL((c2.reltuples*(datahdr-12))/(bs-20::float)),0) AS iotta -- very rough approximation, assumes all cols
  FROM (
    SELECT
      ma,bs,schemaname,tablename,
      (datawidth+(hdr+ma-(case when hdr%ma=0 THEN ma ELSE hdr%ma END)))::numeric AS datahdr,
      (maxfracsum*(nullhdr+ma-(case when nullhdr%ma=0 THEN ma ELSE nullhdr%ma END))) AS nullhdr2
    FROM (
      SELECT
        schemaname, tablename, hdr, ma, bs,
        SUM((1-null_frac)*avg_width) AS datawidth,
        MAX(null_frac) AS maxfracsum,
        hdr+(
          SELECT 1+count(*)/8
          FROM pg_stats s2
          WHERE null_frac<>0 AND s2.schemaname = s.schemaname AND s2.tablename = s.tablename
        ) AS nullhdr
      FROM pg_stats s, (
        SELECT
          (SELECT current_setting('block_size')::numeric) AS bs,
          CASE WHEN substring(v,12,3) IN ('8.0','8.1','8.2') THEN 27 ELSE 23 END AS hdr,
          CASE WHEN v ~ 'mingw32' THEN 8 ELSE 4 END AS ma
        FROM (SELECT version() AS v) AS foo
      ) AS constants
      GROUP BY 1,2,3,4,5
    ) AS foo
  ) AS rs
  JOIN pg_class cc ON cc.relname = rs.tablename
  JOIN pg_namespace nn ON cc.relnamespace = nn.oid AND nn.nspname = rs.schemaname AND nn.nspname <> 'information_schema'
  LEFT JOIN pg_index i ON indrelid = cc.oid
  LEFT JOIN pg_class c2 ON c2.oid = i.indexrelid
) AS sml
ORDER BY wastedbytes DESC
