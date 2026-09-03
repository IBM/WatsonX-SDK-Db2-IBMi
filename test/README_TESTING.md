# Testing Guide

This directory contains SQL test scripts for the `dbsdk_v1` schema on IBM i.

---

## Contents

| File | Module(s) tested | Requires live endpoint? |
|---|---|---|
| [`a.sql`](a.sql) | `watsonx` — auth, generate, models, utils | Yes — watsonx cloud |
| [`openai_compatible_test.sql`](openai_compatible_test.sql) | `openai_compatible` — job-scope config, `generate`, `generate_json` | Yes — OpenAI-compatible server |
| [`test_fix.sql`](test_fix.sql) | `conf` — MERGE row-isolation regression (issue #21/#27) | No |
| [`test_json_object_update.sql`](test_json_object_update.sql) | `json_object_update` utility function | No |
| [`ollama_test.sql`](ollama_test.sql) | `ollama` — config utils, `set*forme` persistence, `ollama_generate` | Yes — Ollama server |
| [`openai_compatible_chat_generate_test.sql`](openai_compatible_chat_generate_test.sql) | `openai_compatible_chat_generate`, `set*forme` persistence | Optional (local and/or cloud) |
| [`grant_test_user.sql`](grant_test_user.sql) | Setup — grants authority to the test user profile | No (run as schema owner) |

---

## Prerequisites

### 1. IBM i environment

- IBM i with Db2 for i (any currently supported release).
- The `dbsdk_v1` schema must be built and deployed. See the project build instructions in the root `makefile`.

### 2. Test user profile

Scripts that write to `dbsdk_v1.conf` or call live endpoints must be run as a **dedicated test IBM i user profile**.
The default expected profile name is **`DBSDKTEST`**.

To use a different profile, search for `<<CHANGE_TEST_USER>>` in each applicable script and replace
`'DBSDKTEST'` with your profile name. The marker appears in the user guard and teardown statements.

The test profile needs:
- `*EXECUTE` authority on every `dbsdk_v1` function and procedure it calls.
- `SELECT`, `INSERT`, `UPDATE`, `DELETE` authority on `dbsdk_v1.conf`.
- Network access from the IBM i job to any endpoint under test (Ollama, OpenAI-compatible server, etc.).

### 3. Granting authority to the test profile

The functions and procedures in `dbsdk_v1` are compiled without an explicit `set option usrprf`
clause in the utility modules, so they default to `USRPRF(*OWNER)`. A user other than the schema
owner will receive `SQL0551 Not authorized to object … type *PGM` (or `type *SRVPGM`) when calling them.

Run [`test/grant_test_user.sql`](grant_test_user.sql) **once** as the schema owner (or any profile
with `*SECADM` special authority) before running any test scripts:

```
-- In ACS Run SQL Scripts, connected as the schema owner:
-- Open test/grant_test_user.sql and run all statements.

-- Or from a 5250 command line:
RUNSQLSTM SRCSTMF('/path/to/test/grant_test_user.sql') COMMIT(*NONE) NAMING(*SQL)
```

If you rename the test profile from `DBSDKTEST`, also edit every occurrence of `DBSDKTEST` in
`grant_test_user.sql` before running it (or run the individual `GRANT` statements manually).

Re-run `grant_test_user.sql` any time the schema is rebuilt, since `CREATE OR REPLACE` drops and
re-creates the compiled program object and resets its authority list.

### 4. SSL certificate store access (HTTPS endpoints only)

Tests that call cloud HTTPS endpoints (e.g. Gemini, OpenAI) use `QSYS2.HTTP_POST_VERBOSE` with
`set option usrprf = *user`, meaning the HTTP call runs as the test user profile. IBM i's GSKit SSL
layer opens the system key database (`*SYSTEM` DCM certificate store) as that user. If `DBSDKTEST`
does not have read authority on the keystore, the call fails with:

```
GSKit Error 6003 - Access to the key database is not allowed
```

To grant the minimum necessary IFS authority, run the following **as a security administrator**
(`*SECADM` or `*ALLOBJ`) from a 5250 command line:

```
CHGAUT OBJ('/QIBM/UserData/ICSS/Cert/Server') USER(DBSDKTEST) DTAAUT(*RX)
CHGAUT OBJ('/QIBM/UserData/ICSS/Cert/Server/DEFAULT.KDB') USER(DBSDKTEST) DTAAUT(*R)
```

The first command grants traverse (`*RX`) on the directory only; the second grants read (`*R`) on
the keystore file itself. No other files in the directory are affected.

To verify the current authority on the keystore file:

```
WRKAUT OBJ('/QIBM/UserData/ICSS/Cert/Server/DEFAULT.KDB')
```

If you have renamed the test profile from `DBSDKTEST`, substitute your profile name in the commands
above. This is a one-time step and does not need to be repeated when the schema is rebuilt.

### 5. Registering the test user profile

Before running any test that calls `set*forme` procedures or live generate functions, the test user's
row must exist in `dbsdk_v1.conf`. The simplest way to create it (as the test user):

```sql
CALL dbsdk_v1.conf_register_user();
```

Then populate the endpoint details using either the `CFGOLLAMA` / `CFGOPENAI` admin programs in
`src/admin/`, the `conf_update_*` admin procedures in `src/admin/sql/conf_admin.sql`, or direct
`set*forme` calls — for example:

```sql
-- Ollama example
CALL dbsdk_v1.ollama_setserverforme('my-ollama-host');
CALL dbsdk_v1.ollama_setportforme(11434);
CALL dbsdk_v1.ollama_setprotocolforme('http');
CALL dbsdk_v1.ollama_setmodelforme('granite3.2:8b');

-- OpenAI-compatible local example
CALL dbsdk_v1.openai_compatible_setserverforme('localhost');
CALL dbsdk_v1.openai_compatible_setportforme(8080);
CALL dbsdk_v1.openai_compatible_setprotocolforme('http');
CALL dbsdk_v1.openai_compatible_setbasepathforme('/v1');
CALL dbsdk_v1.openai_compatible_setmodelforme('llama3');
```

---

## How to run

### Option A — ACS Run SQL Scripts (recommended for interactive use)

1. Open IBM i Access Client Solutions (ACS).
2. Connect to your IBM i system as the test user profile (`DBSDKTEST`).
3. Open **Run SQL Scripts** (`File → New SQL Script` or toolbar button).
4. Open or paste the `.sql` file you want to run.
5. Click **Run All** (F5) or run selected statements individually.
6. Results appear in the **Results** tab. Look for `PASS:` / `FAIL:` values in result columns and
   check the **Messages** tab for any signals raised by guard blocks.

> **Tip:** Scripts that require endpoint-specific values (server address, API key, model name) have
> clearly marked comment blocks at the top of the relevant section. Edit those values in the ACS
> editor before running.

### Option B — RUNSQLSTM on IBM i (batch / CI use)

The project's `runsql.sh` wrapper calls `RUNSQLSTM` directly. To run a test script from a PASE shell:

```sh
runsql.sh dbsdk_v1 test/ollama_test.sql
```

Or directly with `RUNSQLSTM` from a 5250 command line:

```
RUNSQLSTM SRCSTMF('/path/to/test/ollama_test.sql') COMMIT(*NONE) NAMING(*SQL) DFTRDBCOL(DBSDK_V1)
```

---

## Understanding test output

### PASS / FAIL assertions

Most tests produce a result row with a single column named `TEST_RESULT`. A passing test looks like:

```
TEST_RESULT
---------------------------------------------------------
PASS: ollama_setserverforjob / ollama_getserver round-trip
```

A failure looks like:

```
TEST_RESULT
---------------------------------------------------------
FAIL: ollama_setserverforjob / ollama_getserver round-trip
```

In ACS Run SQL Scripts, all result sets appear in the **Results** tab. Scan for any `FAIL:` prefix.

### Guard signals

Scripts that detect a misconfiguration or wrong user raise an SQL signal that stops execution immediately.

| SQLSTATE | Meaning |
|---|---|
| `45000` | Script is not being run as the expected test user profile. Edit `dbsdk_v1.test_user`. |
| `45001` | Required endpoint configuration is missing (server, model, etc.) for the Ollama or local OpenAI-compatible block. |
| `45002` | Cloud API key is not set. Edit the `setapikeyforjob` call at the top of the cloud sub-block. |

In ACS, a signal appears as an error message in the **Messages** tab. In `RUNSQLSTM`, it appears in
the job log.

---

## Script-by-script notes

### `ollama_test.sql`

Requires a running [Ollama](https://ollama.com/) server reachable from the IBM i job, with at least
one model pulled. The `dbsdk_v1.conf` row for the test user must have `ollama_server` set (Guard 2
checks this before any live calls are made).

The script has three sections:
- **Section 1** — `set*forjob` / `get*` round-trips (no live endpoint call, just job-variable manipulation)
- **Section 2** — `set*forme` persistence tests (writes and reads `dbsdk_v1.conf`; teardown deletes the row)
- **Section 3** — live `ollama_generate` calls; uses explicit `setserverforjob`/`setportforjob`/`setprotocolforjob` calls so it does not depend on the conf row deleted by Section 2

⚠️ **Before running Section 3**, check the four `CALL` statements just above it in the script and edit them to match your environment:

```sql
CALL dbsdk_v1.ollama_setserverforjob('localhost');    -- change if different
CALL dbsdk_v1.ollama_setportforjob(11434);            -- change if different
CALL dbsdk_v1.ollama_setprotocolforjob('http');       -- change if different
CALL dbsdk_v1.ollama_setmodelforjob('granite4.1:8b'); -- change to any pulled model
```

The explicit-model test also uses `granite4.1:8b` as the model name. Change this to any model
that is pulled on your Ollama server:

```sql
-- Near the bottom of ollama_test.sql:
WHEN dbsdk_v1.ollama_generate('What is 2 + 2?', 'granite4.1:8b') IS NOT NULL
```

### `openai_compatible_chat_generate_test.sql`

Has three independent sections:

**LOCAL sub-block** — targets a locally-hosted OpenAI-compatible server (e.g. llama.cpp,
LM Studio, Ollama's `/v1` shim). Edit the `setserverforjob` / `setportforjob` / `setmodelforjob`
calls at the top of the block to match your local setup. If the server or model is `NULL` after
setup, Guard `45001` fires and the block is skipped cleanly.

**CLOUD sub-block** — targets a cloud endpoint (e.g. `api.openai.com`, Gemini). You must provide
a real API key:

```sql
-- In the CLOUD ENDPOINT SUB-BLOCK section:
CALL dbsdk_v1.openai_compatible_setapikeyforjob('sk-your-real-api-key-here');
```

Also update `setserverforjob` and `setmodelforjob` for your chosen cloud provider. If the API key
is `NULL`, Guard `45002` fires and the block is skipped cleanly.

**`set*forme` persistence tests** — always run regardless of whether either endpoint guard fired.
These tests do not make any network calls; they only write to and read from `dbsdk_v1.conf`.

### `test_fix.sql`

No live endpoint required. Inserts synthetic rows for fictional users `TEST1` and `TEST2`, verifies
MERGE row-isolation, and cleans up. Can be run as any user that has `*CHANGE` authority to
`dbsdk_v1.conf`.

### `test_json_object_update.sql`

No live endpoint required. All 11 tests run as pure SQL expressions against `sysibm.sysdummy1`.
Expected output is documented in inline comments. Can be run as any user.

### `openai_compatible_test.sql`

Requires a locally-hosted OpenAI-compatible server. Edit the `setserverforjob` / `setportforjob` /
`setprotocolforjob` / `setbasepathforjob` calls at the top before running.

### `a.sql`

Requires a watsonx cloud account. The watsonx API key and project ID must be set in
`dbsdk_v1.conf` for the running user (or set via `wx_setapikeyforjob` / `wx_setprojectidforjob`).

---

## Cleanup

All test scripts that write to `dbsdk_v1.conf` clean up after themselves with a `DELETE` at the end.
If a script is interrupted mid-run (e.g. a guard signal fires), you can manually remove any leftover
test row:

```sql
DELETE FROM dbsdk_v1.conf WHERE usrprf = 'DBSDKTEST';
```

---

## Known limitations

### Bare `SET` on global variables requires `*SRVPGM` authority

`SET dbsdk_v1.<variable> = value` is a direct write to the `*SRVPGM` object that backs the global
variable. IBM i checks `*CHANGE` authority on that object before SQL privilege evaluation; this
authority cannot be granted via `GRANT` statements from SQL. For this reason, the test scripts never
use bare `SET` to write `dbsdk_v1.*` variables — all variable writes are routed through the
`set*forjob` procedures, which run as `*OWNER` and have full authority on the `*SRVPGM`.

`CREATE OR REPLACE VARIABLE` similarly requires `*ADD` authority on the schema, which `DBSDKTEST`
does not hold. The test scripts therefore use hardcoded string literals for the test profile name
(marked `<<CHANGE_TEST_USER>>`) rather than a global variable.
