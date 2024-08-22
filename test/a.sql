------
-- Ensure authenticate can return Y (success)
------

call watsonx.logoutjob();
call watsonx.setapikeyforjob('');
call watsonx.setprojectidforjob('');

-- Should return Y
values watsonx.ShouldGetNewToken();

-- Should return Y
values watsonx.authenticate();

-- Should return N
values watsonx.ShouldGetNewToken();

values watsonx.generate('Hello world');
values watsonx.generate('Hello world', model_id => 'meta-llama/llama-2-13b-chat');

------
-- Ensure authenticate can return N (failed)
------

call watsonx.logoutjob();
call watsonx.setapikeyforjob('-BAD');

-- Should return Y
values watsonx.ShouldGetNewToken();

-- Should return N
values watsonx.authenticate();

-- Should return Y
values watsonx.ShouldGetNewToken();

-- Should return '*PLSAUTH'
values watsonx.generate('Hello world');

------
-- Validate URL
------

-- Should return 'https://us-south.ml.cloud.ibm.com/ml/v1/text/generation?version=2023-07-07'
values watsonx.geturl('/text/generation');

------
-- Gets a list of models
------

call watsonx.getmodels();

------
-- Test parameters function
------

values watsonx.parameters(temperature => 0.5, time_limit => 1000);

-- Should return {"temperature":0.5,"time_limit":1000}