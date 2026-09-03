-- ============================================================
-- Test script for the ollama module
-- ============================================================
-- Covers:
--   - set*forjob / get* round-trips (server, port, model, protocol)
--   - set*forme persistence (writes to dbsdk_v1.conf)
--   - ollama_generate() with default model
--   - ollama_generate() with explicit model_id
--
-- Run as: the user profile named in dbsdk_v1.test_user (default: DBSDKTEST)
-- Compatible with: ACS Run SQL Scripts, RUNSQLSTM / runsql.sh
-- ============================================================

-- ----------------------------------------
-- Configurable test user profile name.
-- Edit the SET statement below to change it.
-- ----------------------------------------
CREATE OR REPLACE VARIABLE dbsdk_v1.test_user VARCHAR(10) DEFAULT 'DBSDKTEST';
SET dbsdk_v1.test_user = 'DBSDKTEST';

-- ----------------------------------------
-- Guard 1: must be run as test_user
-- ----------------------------------------
BEGIN
  IF CURRENT_USER <> dbsdk_v1.test_user THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Must be run as DBSDKTEST (edit dbsdk_v1.test_user to change)';
  END IF;
END;

-- ----------------------------------------
-- Guard 2: ollama server must be configured
-- in dbsdk_v1.conf for test_user.
-- Job-scope variables are intentionally left
-- unset here — ollama_getserver() will fall
-- through to the conf row (see src/ollama/utils.sql).
-- ----------------------------------------
BEGIN
  IF dbsdk_v1.ollama_getserver() IS NULL THEN
    SIGNAL SQLSTATE '45001'
      SET MESSAGE_TEXT = 'Ollama server not configured for test_user — add a conf row for DBSDKTEST and retry';
  END IF;
END;

-- ============================================================
-- Section 1: set*forjob / get* round-trips
-- ============================================================

-- Server
CALL dbsdk_v1.ollama_setserverforjob('test-ollama-host');
SELECT
  CASE
    WHEN dbsdk_v1.ollama_getserver() = 'test-ollama-host'
    THEN 'PASS: ollama_setserverforjob / ollama_getserver round-trip'
    ELSE 'FAIL: ollama_setserverforjob / ollama_getserver round-trip'
  END AS test_result
FROM sysibm.sysdummy1;

-- Port
CALL dbsdk_v1.ollama_setportforjob(19999);
SELECT
  CASE
    WHEN dbsdk_v1.ollama_getport() = 19999
    THEN 'PASS: ollama_setportforjob / ollama_getport round-trip'
    ELSE 'FAIL: ollama_setportforjob / ollama_getport round-trip'
  END AS test_result
FROM sysibm.sysdummy1;

-- Model
CALL dbsdk_v1.ollama_setmodelforjob('testmodel:latest');
SELECT
  CASE
    WHEN dbsdk_v1.ollama_getmodel() = 'testmodel:latest'
    THEN 'PASS: ollama_setmodelforjob / ollama_getmodel round-trip'
    ELSE 'FAIL: ollama_setmodelforjob / ollama_getmodel round-trip'
  END AS test_result
FROM sysibm.sysdummy1;

-- Protocol
CALL dbsdk_v1.ollama_setprotocolforjob('https');
SELECT
  CASE
    WHEN dbsdk_v1.ollama_getprotocol() = 'https'
    THEN 'PASS: ollama_setprotocolforjob / ollama_getprotocol round-trip'
    ELSE 'FAIL: ollama_setprotocolforjob / ollama_getprotocol round-trip'
  END AS test_result
FROM sysibm.sysdummy1;

-- Reset job-scope variables so the generate tests use the conf row
SET dbsdk_v1.ollama_server   = NULL;
SET dbsdk_v1.ollama_port     = NULL;
SET dbsdk_v1.ollama_model    = NULL;
SET dbsdk_v1.ollama_protocol = NULL;

-- ============================================================
-- Section 2: set*forme persistence (writes to dbsdk_v1.conf)
-- ============================================================

-- Teardown: remove any existing conf row for test_user
DELETE FROM dbsdk_v1.conf WHERE usrprf = dbsdk_v1.test_user;

CALL dbsdk_v1.ollama_setserverforme('forme-ollama-host');
CALL dbsdk_v1.ollama_setportforme(29999);
CALL dbsdk_v1.ollama_setmodelforme('forme-model:latest');
CALL dbsdk_v1.ollama_setprotocolforme('http');

SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM dbsdk_v1.conf
          WHERE usrprf         = dbsdk_v1.test_user
            AND ollama_server   = 'forme-ollama-host'
            AND ollama_port     = 29999
            AND ollama_model    = 'forme-model:latest'
            AND ollama_protocol = 'http') = 1
    THEN 'PASS: set*forme procedures wrote correct values to dbsdk_v1.conf'
    ELSE 'FAIL: set*forme procedures did not write expected values to dbsdk_v1.conf'
  END AS test_result
FROM sysibm.sysdummy1;

-- Teardown: remove the conf row written by set*forme tests
DELETE FROM dbsdk_v1.conf WHERE usrprf = dbsdk_v1.test_user;

-- ============================================================
-- Section 3: ollama_generate — live endpoint tests
-- Uses dbsdk_v1.conf row for test_user (Guard 2 ensures it exists)
-- ============================================================

-- Test: generate with default model
SELECT
  CASE
    WHEN dbsdk_v1.ollama_generate('Why is the sky blue?') IS NOT NULL
    THEN 'PASS: ollama_generate returned a non-null response (default model)'
    ELSE 'FAIL: ollama_generate returned null (default model)'
  END AS test_result
FROM sysibm.sysdummy1;

-- Test: generate with explicit model_id
-- Replace 'granite3.2:8b' with any model available on the test Ollama server
SELECT
  CASE
    WHEN dbsdk_v1.ollama_generate('What is 2 + 2?', 'granite3.2:8b') IS NOT NULL
    THEN 'PASS: ollama_generate returned a non-null response (explicit model_id)'
    ELSE 'FAIL: ollama_generate returned null (explicit model_id)'
  END AS test_result
FROM sysibm.sysdummy1;
