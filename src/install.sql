
create schema watsonx;
create or replace variable watsonx.region varchar(16) ccsid 1208 default 'us-south';
create or replace variable watsonx.apiVersion varchar(10) ccsid 1208 default '2023-07-07';
create or replace variable watsonx.apikey varchar(100) ccsid 1208 default '';
create or replace variable watsonx.projectid varchar(100) ccsid 1208 default '';
create or replace variable watsonx.JobBearerToken varchar(10000) ccsid 1208 default null;
create or replace variable watsonx.JobTokenExpires timestamp;

create or replace function watsonx.GetUrl(route varchar(1000))
  returns varchar(256) ccsid 1208
begin
  declare finalUrl varchar(256) ccsid 1208;

  set finalUrl = 'https://' concat watsonx.region concat '.ml.cloud.ibm.com/ml/v1' concat route;

  if (watsonx.apiVersion is not null and watsonx.apiVersion != '') then
    set finalUrl = finalUrl concat '?version=' concat watsonx.apiVersion;
  end if;

  return finalUrl;
end;

create or replace procedure watsonx.SetApiKeyForJob(apikey varchar(100))
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set watsonx.apikey = apikey;
end;

create or replace procedure watsonx.SetProjectIdForJob(projectid varchar(100))
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set watsonx.projectid = projectid;
end;

create or replace procedure watsonx.SetBearerTokenForJob(bearer_token varchar(10000), expires integer)
  modifies sql data
  program type sub
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set watsonx.JobBearerToken = bearer_token;
  -- We subtract 60 seconds from the expiration time to ensure we don't cut it too close
  set watsonx.JobTokenExpires = current timestamp + expires seconds - 60 seconds;
end;

create or replace function watsonx.ShouldGetNewToken() 
  returns char(1)
begin
  if (watsonx.JobBearerToken is null) then
    return 'Y';
  end if;
  if (watsonx.JobTokenExpires is null) then
    return 'Y';
  end if;
  if (current timestamp > watsonx.JobTokenExpires) then
    return 'Y';
  end if;
  return 'N';
end;

create or replace procedure watsonx.logoutJob()
  program type sub
  modifies sql data
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin
  set watsonx.JobBearerToken = null;
  set watsonx.JobTokenExpires = null;
end;

create or replace function watsonx.parameters(
  decoding_method varchar(20) default null,
  temperature numeric(1, 1) default null,
  time_limit integer default null,
  top_p numeric(1, 1) default null,
  top_k integer default null,
  random_seed integer default null,
  repetition_penalty numeric(1, 1) default null,
  truncate_input_tokens integer default null,
  min_new_tokens integer default null,
  max_new_tokens integer default null,
  typical_p numeric(1, 1) default null
) 
  returns varchar(1000) ccsid 1208
begin
  return json_object(
    'decoding_method': decoding_method,
    'temperature': temperature format json,
    'time_limit': time_limit format json,
    'top_p': top_p format json, 
    'top_k': top_k format json, 
    'random_seed': random_seed format json, 
    'repetition_penalty': repetition_penalty format json, 
    'truncate_input_tokens': truncate_input_tokens format json,
    'min_new_tokens': min_new_tokens format json, 
    'max_new_tokens': max_new_tokens format json, 
    'typical_p': typical_p format json
    ABSENT ON NULL
  );
end;