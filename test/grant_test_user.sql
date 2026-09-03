-- ============================================================
-- Grant authority to the test user profile on dbsdk_v1 objects
-- ============================================================
-- Run this script ONCE as the dbsdk_v1 schema owner (or a user
-- with *SECADM authority) BEFORE running any test scripts.
--
-- Change 'DBSDKTEST' below to match your test user profile if
-- you have changed dbsdk_v1.test_user in the test scripts.
-- ============================================================

-- Table: grant the privileges needed by DBSDKTEST on dbsdk_v1.conf.
--
-- SELECT  - PASS/FAIL assertion queries read dbsdk_v1.conf directly
-- INSERT  - conf_register_user / conf_initialize run with usrprf=*user
-- UPDATE  - set*forme procedures run with usrprf=*user (after source fix),
--           so the MERGE WHEN MATCHED THEN UPDATE branch runs as DBSDKTEST
-- DELETE  - teardown statements run as bare SQL as DBSDKTEST
--
-- Row Access Control (conf_rcac.sql MYROWONLY, ENFORCED FOR ALL ACCESS)
-- independently limits every operation to the DBSDKTEST row regardless
-- of the object-level privileges granted here.
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE dbsdk_v1.conf TO DBSDKTEST;

-- All functions and procedures: allow the test user to call them
-- Re-run this script after rebuilding the schema to pick up new objects.
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.ollama_getserver           TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.ollama_getport             TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.ollama_getmodel            TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.ollama_getprotocol         TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setserverforjob     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setserverforme      TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setportforjob       TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setportforme        TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setmodelforjob      TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setmodelforme       TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setprotocolforjob   TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.ollama_setprotocolforme    TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.ollama_generate            TO DBSDKTEST;

GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getserver       TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getport         TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getmodel        TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getprotocol     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getapikey       TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_getbasepath     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setserverforjob   TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setserverforme    TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setportforjob     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setportforme      TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setmodelforjob    TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setmodelforme     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setprotocolforjob TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setprotocolforme  TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setapikeyforjob   TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setapikeyforme    TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setbasepathforjob TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.openai_compatible_setbasepathforme  TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_generate          TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_generate_json     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.openai_compatible_chat_generate     TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC FUNCTION  dbsdk_v1.json_object_update                  TO DBSDKTEST;

GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.conf_register_user  TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.conf_initialize      TO DBSDKTEST;
GRANT EXECUTE ON SPECIFIC PROCEDURE dbsdk_v1.conf_remove_user     TO DBSDKTEST;

-- Note: bare SET dbsdk_v1.<variable> = ... statements are NOT used in the
-- test scripts because SET on a global variable requires *CHANGE on the
-- underlying *SRVPGM object, which cannot be granted via SQL GRANT.
-- All variable writes are routed through the set*forjob procedures instead,
-- which run as *OWNER and have no authority issue.
