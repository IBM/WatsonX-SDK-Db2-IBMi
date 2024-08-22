create or replace function watsonx.generate(
  text varchar(1000) ccsid 1208,
  model_id varchar(128) ccsid 1208 default 'meta-llama/llama-2-13b-chat',
  parameters varchar(1000) ccsid 1208 default null
)
  returns varchar(10000) ccsid 1208
  not deterministic
  no external action
  set option usrprf = *user, dynusrprf = *user, commit = *none
begin

  declare response_header Varchar(10000) CCSID 1208;
  declare response_message Varchar(10000) CCSID 1208;
  declare watsonx_response Varchar(10000) CCSID 1208;
  declare needsNewToken char(1) default 'Y';

  set needsNewToken = watsonx.ShouldGetNewToken();
  if (needsNewToken = 'Y') then
    return '*PLSAUTH';
  end if;

  if parameters is null then
    set parameters = watsonx.parameters(max_new_tokens => 100, time_limit => 1000);
  end if;

  select RESPONSE_MESSAGE, RESPONSE_HTTP_HEADER
  into response_message, response_header
  from table(HTTP_POST_VERBOSE(
    watsonx.geturl('/text/generation'),
    json_object('model_id': model_id, 'input': text, 'parameters': parameters format json, 'space_id': watsonx.spaceid),
    json_object('headers': json_object('Authorization': 'Bearer ' concat watsonx.JobBearerToken, 'Content-Type': 'application/json', 'Accept': 'application/json'))
  )) x;
  
  
  -- select ltrim("generated_text") into watsonx_response
  -- from json_table(response_message, 'lax $.results[*]'
  -- columns(
  --   "generated_text" varchar(10000) ccsid 1208
  -- ));

  -- if (watsonx_response is null) then
  --   return '*ERROR';
  -- end if;
  
  return json_object('response_message': response_message format json, 'response_header': response_header format json);
end;