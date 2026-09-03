-- ============================================================
-- Test script for openai_compatible_chat_generate
-- and openai_compatible set*forme persistence
-- ============================================================
-- Covers:
--   LOCAL sub-block:
--     - openai_compatible_chat_generate() default options
--     - openai_compatible_chat_generate() with temperature option
--     - openai_compatible_chat_generate() with max_tokens option
--     - openai_compatible_chat_generate() with base_url direct override
--   CLOUD sub-block:
--     - openai_compatible_chat_generate() default options (with apikey)
--     - openai_compatible_chat_generate() with inline api_key_ parameter
--   set*forme persistence (always runs):
--     - openai_compatible_setapikeyforme
--     - openai_compatible_setmodelforme
--     - openai_compatible_setbasepathforme
--
-- Run as: the user profile named in dbsdk_v1.test_user (default: DBSDKTEST)
-- Compatible with: ACS Run SQL Scripts, RUNSQLSTM / runsql.sh
-- ============================================================

-- ----------------------------------------
-- Configurable test user profile name.
-- If your test profile is not DBSDKTEST, change the value
-- in the places marked <<CHANGE_TEST_USER>> below.
-- ----------------------------------------

-- ----------------------------------------
-- Guard 1: must be run as test_user
-- ----------------------------------------
BEGIN
  IF CURRENT_USER <> 'DBSDKTEST' THEN  -- <<CHANGE_TEST_USER>>
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Must be run as DBSDKTEST (edit the CHANGE_TEST_USER lines to change)';
  END IF;
END;

-- ============================================================
-- LOCAL ENDPOINT SUB-BLOCK
-- Configure the variables below for your local OpenAI-compatible
-- server (e.g. llama.cpp, LM Studio, Ollama with OpenAI shim).
-- If no local server is available, this block will skip cleanly.
-- ============================================================

-- Set job-scope variables for local endpoint (no API key needed)
CALL dbsdk_v1.openai_compatible_setserverforjob('localhost');
CALL dbsdk_v1.openai_compatible_setportforjob(8080);
CALL dbsdk_v1.openai_compatible_setprotocolforjob('http');
CALL dbsdk_v1.openai_compatible_setbasepathforjob('/v1');
CALL dbsdk_v1.openai_compatible_setmodelforjob('llama3');

-- Guard: skip local block if server or model is not configured
BEGIN
  IF dbsdk_v1.openai_compatible_getserver() IS NULL
  OR dbsdk_v1.openai_compatible_getmodel()  IS NULL THEN
    SIGNAL SQLSTATE '45001'
      SET MESSAGE_TEXT = 'LOCAL endpoint not configured - skipping local chat_generate tests';
  END IF;
END;

-- Test: chat_generate default options (local)
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'Why is the sky blue?'
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate default options (local)'
    ELSE 'FAIL: openai_compatible_chat_generate default options (local) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Test: chat_generate with temperature option (local)
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'Name three planets.',
           '{"temperature": 0.5}'
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate with temperature option (local)'
    ELSE 'FAIL: openai_compatible_chat_generate with temperature option (local) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Test: chat_generate with max_tokens option (local)
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'Count from 1 to 5.',
           '{"max_tokens": 50}'
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate with max_tokens option (local)'
    ELSE 'FAIL: openai_compatible_chat_generate with max_tokens option (local) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Test: chat_generate with base_url direct override (local)
-- This exercises the base_url parameter path in the function body.
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'What is 2 + 2?',
           '{}',
           NULL,
           'http://localhost:8080/v1'
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate with base_url override (local)'
    ELSE 'FAIL: openai_compatible_chat_generate with base_url override (local) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Reset local job-scope variables
CALL dbsdk_v1.openai_compatible_setserverforjob(NULL);
CALL dbsdk_v1.openai_compatible_setportforjob(NULL);
CALL dbsdk_v1.openai_compatible_setprotocolforjob(NULL);
CALL dbsdk_v1.openai_compatible_setbasepathforjob(NULL);
CALL dbsdk_v1.openai_compatible_setmodelforjob(NULL);
CALL dbsdk_v1.openai_compatible_setapikeyforjob(NULL);

-- ============================================================
-- CLOUD ENDPOINT SUB-BLOCK
-- Configure the variables below for a cloud OpenAI-compatible
-- endpoint (e.g. OpenAI api.openai.com, Gemini, etc.).
-- An API key is required. If not configured, this block skips.
-- ============================================================

-- Set job-scope variables for cloud endpoint
-- Replace these values with real cloud endpoint details before running
CALL dbsdk_v1.openai_compatible_setserverforjob('generativelanguage.googleapis.com');
CALL dbsdk_v1.openai_compatible_setportforjob(443);
CALL dbsdk_v1.openai_compatible_setprotocolforjob('https');
CALL dbsdk_v1.openai_compatible_setbasepathforjob('/v1beta/openai');
CALL dbsdk_v1.openai_compatible_setmodelforjob('gemini-3.6-flash');
-- Set your API key here before running:
CALL dbsdk_v1.openai_compatible_setapikeyforjob(NULL);

-- Guard: skip cloud block if API key is not configured
BEGIN
  IF dbsdk_v1.openai_compatible_getapikey() IS NULL THEN
    SIGNAL SQLSTATE '45002'
      SET MESSAGE_TEXT = 'CLOUD endpoint not configured - set API key via openai_compatible_setapikeyforjob and retry';
  END IF;
END;

-- Test: chat_generate default options (cloud)
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'Why is the sky blue?'
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate default options (cloud)'
    ELSE 'FAIL: openai_compatible_chat_generate default options (cloud) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Test: chat_generate with inline api_key_ parameter override
-- This exercises the api_key_ parameter path in the function body.
SELECT
  CASE
    WHEN dbsdk_v1.openai_compatible_chat_generate(
           'What is 2 + 2?',
           '{}',
           dbsdk_v1.openai_compatible_getapikey()
         ) IS NOT NULL
    THEN 'PASS: openai_compatible_chat_generate with inline api_key_ override (cloud)'
    ELSE 'FAIL: openai_compatible_chat_generate with inline api_key_ override (cloud) returned null'
  END AS test_result
FROM sysibm.sysdummy1;

-- Reset cloud job-scope variables
CALL dbsdk_v1.openai_compatible_setserverforjob(NULL);
CALL dbsdk_v1.openai_compatible_setportforjob(NULL);
CALL dbsdk_v1.openai_compatible_setprotocolforjob(NULL);
CALL dbsdk_v1.openai_compatible_setbasepathforjob(NULL);
CALL dbsdk_v1.openai_compatible_setmodelforjob(NULL);
CALL dbsdk_v1.openai_compatible_setapikeyforjob(NULL);

-- ============================================================
-- set*forme PERSISTENCE TESTS
-- These tests always run (independent of local/cloud guards).
-- They write to dbsdk_v1.conf and clean up after themselves.
-- ============================================================

-- Teardown: remove any existing conf row for test_user
DELETE FROM dbsdk_v1.conf WHERE usrprf = 'DBSDKTEST';  -- <<CHANGE_TEST_USER>>

CALL dbsdk_v1.openai_compatible_setapikeyforme('test-api-key-forme');
CALL dbsdk_v1.openai_compatible_setmodelforme('forme-model-id');
CALL dbsdk_v1.openai_compatible_setbasepathforme('/forme/v1');

SELECT
  CASE
    WHEN (SELECT COUNT(*) FROM dbsdk_v1.conf
          WHERE usrprf                      = 'DBSDKTEST'  -- <<CHANGE_TEST_USER>>
            AND openai_compatible_apikey    = 'test-api-key-forme'
            AND openai_compatible_model     = 'forme-model-id'
            AND openai_compatible_basepath  = '/forme/v1') = 1
    THEN 'PASS: set*forme procedures wrote correct values to dbsdk_v1.conf'
    ELSE 'FAIL: set*forme procedures did not write expected values to dbsdk_v1.conf'
  END AS test_result
FROM sysibm.sysdummy1;

-- Teardown: remove the conf row written by set*forme tests
DELETE FROM dbsdk_v1.conf WHERE usrprf = 'DBSDKTEST';  -- <<CHANGE_TEST_USER>>
