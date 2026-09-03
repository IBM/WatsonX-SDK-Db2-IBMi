-- ## OpenAI-compatible endpoints utility functions

create or replace function dbsdk_v1.openai_compatible_getserver(hostname varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = hostname;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_server;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_server from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `openai_compatible_setserverforjob`

-- **Description:** sets the OpenAI-compatible server to be used for this job

-- **Input parameters:**
-- - `HOSTNAME` (required): The IP address or hostname of the OpenAI-compatible server.
create or replace procedure dbsdk_v1.openai_compatible_setserverforjob(hostname varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_server = hostname;
end;

-- ### procedure: `openai_compatible_setserverforme`

-- **Description:** sets the OpenAI-compatible server to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `HOSTNAME` (required): The IP address or hostname of the OpenAI-compatible server.
create or replace procedure dbsdk_v1.openai_compatible_setserverforme(hostname varchar(1000) ccsid 1208 default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, hostname AS openai_compatible_server
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_server) VALUES (live.usrprf,
      live.openai_compatible_server)
  WHEN MATCHED THEN UPDATE SET openai_compatible_server = live.openai_compatible_server;
end;

create or replace function dbsdk_v1.openai_compatible_getport(port INT default NULL) 
  returns INT
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = port;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_port;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_port from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `openai_compatible_setportforjob`

-- **Description:** sets the OpenAI-compatible server port to be used for this job

-- **Input parameters:**
-- - `PORT` (required): The OpenAI-compatible server port.
create or replace procedure dbsdk_v1.openai_compatible_setportforjob(port INT default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_port = port;
end;

-- ### procedure: `openai_compatible_setportforme`

-- **Description:** sets the OpenAI-compatible server port to be used for this user profile (persists across jobs).

-- **Input parameters:**
-- - `PORT` (required): The OpenAI-compatible server port.
create or replace procedure dbsdk_v1.openai_compatible_setportforme(port INT default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, port AS openai_compatible_port
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_port) VALUES (live.usrprf,
      live.openai_compatible_port)
  WHEN MATCHED THEN UPDATE SET openai_compatible_port = live.openai_compatible_port;
end;

create or replace function dbsdk_v1.openai_compatible_getmodel(model varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = model;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_model;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_model from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `openai_compatible_setmodelforjob`

-- **Description:** sets the large language model (LLM) to be used for this job

-- **Input parameters:**
-- - `MODEL` (required): The model identifier to use.
create or replace procedure dbsdk_v1.openai_compatible_setmodelforjob(model varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_model = model;
end;

-- ### procedure: `openai_compatible_setmodelforme`

-- **Description:** sets the large language model (LLM) to be used for this user profile (persists across jobs)

-- **Input parameters:**
-- - `MODEL` (required): The model identifier to use.
create or replace procedure dbsdk_v1.openai_compatible_setmodelforme(model varchar(1000) ccsid 1208 default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, model AS openai_compatible_model
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_model) VALUES (live.usrprf,
      live.openai_compatible_model)
  WHEN MATCHED THEN UPDATE SET openai_compatible_model = live.openai_compatible_model;
end;

create or replace function dbsdk_v1.openai_compatible_getprotocol(protocol varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_protocol;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_protocol from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `openai_compatible_setprotocolforjob`

-- **Description:** sets the protocol to be used for this job

-- **Input parameters:**
-- - `PROTOCOL` (required): `http`/`https`
create or replace procedure dbsdk_v1.openai_compatible_setprotocolforjob(protocol varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_protocol = protocol;
end;

-- ### procedure: `openai_compatible_setprotocolforme`
-- 
-- **Description:** sets the protocol to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `PROTOCOL` (required): `http`/`https`
create or replace procedure dbsdk_v1.openai_compatible_setprotocolforme(protocol varchar(1000) ccsid 1208 default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, protocol AS openai_compatible_protocol
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_protocol) VALUES (live.usrprf,
      live.openai_compatible_protocol)
  WHEN MATCHED THEN UPDATE SET openai_compatible_protocol = live.openai_compatible_protocol;
end;

-- Function for API key management
create or replace function dbsdk_v1.openai_compatible_getapikey(api_key varchar(8000) ccsid 1208 default NULL) 
  returns varchar(8000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(8000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = api_key;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_apikey;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_apikey from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return returnval;
end;

-- ### procedure: `openai_compatible_setapikeyforjob`

-- **Description:** sets the API key to be used for this job

-- **Input parameters:**
-- - `API_KEY` (required): The API key for authentication.
create or replace procedure dbsdk_v1.openai_compatible_setapikeyforjob(api_key varchar(8000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_apikey = api_key;
end;

-- ### procedure: `openai_compatible_setapikeyforme`
-- 
-- **Description:** sets the API key to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `API_KEY` (required): The API key for authentication.
create or replace procedure dbsdk_v1.openai_compatible_setapikeyforme(api_key varchar(8000) ccsid 1208 default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, api_key AS openai_compatible_apikey
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_apikey) VALUES (live.usrprf,
      live.openai_compatible_apikey)
  WHEN MATCHED THEN UPDATE SET openai_compatible_apikey = live.openai_compatible_apikey;
end;

-- Function for base path configuration (for servers with non-standard API paths)
create or replace function dbsdk_v1.openai_compatible_getbasepath(base_path varchar(1000) ccsid 1208 default NULL) 
  returns varchar(1000) ccsid 1208
  modifies sql data
begin
  declare returnval varchar(1000) ccsid 1208;
  call dbsdk_v1.conf_initialize();
  set returnval = base_path;
  if (returnval is not null) then return returnval;end if;
  set returnval = dbsdk_v1.openai_compatible_basepath;
  if (returnval is not null) then return returnval;end if;
  set returnval = (select openai_compatible_basepath from dbsdk_v1.conf where USRPRF = CURRENT_USER);
  return coalesce(returnval, '/v1'); -- Default to standard OpenAI path if not set
end;

-- ### procedure: `openai_compatible_setbasepathforjob`

-- **Description:** sets the API base path to be used for this job

-- **Input parameters:**
-- - `BASE_PATH` (required): The base path for API endpoints.
create or replace procedure dbsdk_v1.openai_compatible_setbasepathforjob(base_path varchar(1000) ccsid 1208 default NULL) 
  modifies SQL DATA
begin
  set dbsdk_v1.openai_compatible_basepath = base_path;
end;

-- ### procedure: `openai_compatible_setbasepathforme`
-- 
-- **Description:** sets the API base path to be used for this user profile (persists across jobs)
-- 
-- **Input parameters:**
-- - `BASE_PATH` (required): The base path for API endpoints.
create or replace procedure dbsdk_v1.openai_compatible_setbasepathforme(base_path varchar(1000) ccsid 1208 default NULL)
  MODIFIES SQL DATA
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  MERGE INTO dbsdk_v1.conf tt USING (
    SELECT CURRENT_USER AS usrprf, base_path AS openai_compatible_basepath
      FROM sysibm.sysdummy1
  ) live
  ON tt.usrprf = live.usrprf
  WHEN NOT MATCHED THEN INSERT (usrprf, openai_compatible_basepath) VALUES (live.usrprf,
      live.openai_compatible_basepath)
  WHEN MATCHED THEN UPDATE SET openai_compatible_basepath = live.openai_compatible_basepath;
end;

-- ## JSON Object Update Function
-- 
-- **Description:** Merges two JSON objects into one
-- 
-- **Input parameters:**
-- - `base_object` (required): The base JSON object
-- - `update_object` (required): The object to merge into the base object
-- 
-- **Return type:** 
-- - `clob(64K) ccsid 1208`
-- 
-- **Return value:**
-- - A merged JSON object

create or replace function dbsdk_v1.json_object_update(
  base_object CLOB(2G) ccsid 1208,
  update_object CLOB(2G) ccsid 1208
) 
  returns clob(64K) ccsid 1208
  deterministic
  no external action
  not fenced
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  -- If base object is empty, return update object
  if base_object is null or trim(base_object) = '' or trim(base_object) = '{}' then
    return update_object;
  end if;
  
  -- If update object is empty, return base object
  if update_object is null or trim(update_object) = '' or trim(update_object) = '{}' then
    return base_object;
  end if;
  
  -- Directly combine without intermediate variable assignments
  return '{' concat 
         substring(trim(base_object), 2, length(trim(base_object)) - 2) concat 
         ', ' concat 
         substring(trim(update_object), 2, length(trim(update_object)) - 2) concat 
         '}';

end;