local global_enviroment = getgenv();

local httpservice       = cloneref(game.HttpService);

local getscriptbytecode = clonefunction(getscriptbytecode);
local getrawmetatable   = clonefunction(getrawmetatable);
local setrawmetatable   = clonefunction(setrawmetatable);
local base64_encode     = clonefunction(base64_encode);
local setreadonly       = clonefunction(setreadonly);

local jsondecode        = clonefunction(httpservice.JSONDecode);
local sub               = clonefunction(string.sub);
local clone             = clonefunction(table.clone);
local freeze            = clonefunction(table.freeze);
local typeof            = clonefunction(typeof);
local type              = clonefunction(type);
local error             = clonefunction(error);
local pcall             = clonefunction(pcall);
local rawset            = clonefunction(rawset);
local rawget            = clonefunction(rawget);

local funcs = {};
funcs.decompile = function(script)
      if (not script or typeof(script) ~= 'Instance' or (script.ClassName ~= 'LocalScript' and script.ClassName ~= 'ModuleScript')) then
            return error(`invalid argument #1 (LocalScript or ModuleScript expected, got {typeof(script)})`);
      end;
      local success, bytecode = pcall(getscriptbytecode, script);
      if (not success) then
            return `failed to get script bytecode {bytecode}`;
      end;
      local data = {
            Url = 'https://unluau.lonegladiator.dev/unluau/decompile',
            Method = 'POST',
            Headers = {['Content-Type'] = 'application/json'},
            Body = [[{"version":5,"bytecode":"]]..base64_encode(bytecode)..[["}]],
      };
      local response = jsondecode(httpservice, request(data).Body);
      if (response.status ~= 'ok') then
            return `decompilation failed: {response.status}`;
      end;
      return sub(response.output, 256, #response.output);
end;
funcs.replacemetamethod = function(obj, method, func)
      local metatable = getrawmetatable(obj);
      if (not metatable or type(metatable) ~= 'table') then 
            return error(`{obj} does not have a metatable`);
      elseif (not rawget(metatable, method)) then
            return error(`{method} is not a valid metamethod`);
      elseif (not func or type(func) ~= 'function') then
            return error(`invalid argument #3 (function expected, got {typeof(func)})`);
      end;
      metatable = clone(metatable);
      local old = rawget(metatable, method);
      setreadonly(metatable, false);
      rawset(metatable, method, func);
      freeze(metatable);
      setrawmetatable(obj, metatable)
      return old;
end;

for index, value in funcs do
      global_enviroment[index] = clonefunction(newcclosure(value));
end;
