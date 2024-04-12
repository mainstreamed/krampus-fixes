local global_enviroment = getgenv();
local registry          = getreg();

local getrawmetatable   = clonefunction(getrawmetatable);
local hookfunc          = clonefunction(hookfunc);
local gettenv           = clonefunction(gettenv);

local typeof            = clonefunction(typeof);
local type              = clonefunction(type);
local error             = clonefunction(error);
local insert            = clonefunction(table.insert);
local find              = clonefunction(table.find);
local rawget            = clonefunction(rawget);
local isA               = clonefunction(game.IsA);
local getDescendants    = clonefunction(game.GetDescendants);

local funcs = {};
funcs.getallthreads = function()
      local threads = {};
      for i = 1, #registry do
            local value = registry[i];
            if (type(value) == 'thread') then
                  insert(threads, value);
            end;
      end;
      return threads;
end;
funcs.getsenv = function(script)
      if (typeof(script) ~= 'Instance' or not isA(script, 'BaseScript')) then
            return error(`invalid argument #1 (LocalScript or ModuleScript expected, got {typeof(script)})`);
      end
      for i = 1, #registry do
            local value = registry[i];
            if (type(value) ~= 'thread') then
                  continue;
            end;
            local env = gettenv(value);
            if (env.script == script) then
                  return env;
            end;
      end;
      return;
end;
funcs.hookmetamethod = function(obj, method, func)
      local metatable, old = getrawmetatable(obj);
      if (not metatable or type(metatable) ~= 'table') then
            return error(`{obj} does not have a metatable`);
      elseif (not rawget(metatable, method)) then
            return error(`{method} is not a valid metamethod`);
      elseif (not func or type(func) ~= 'function') then
            return error(`invalid argument #3 (function expected, got {typeof(func)})`);
      end;
      old = hookfunc(rawget(metatable, method), func);
      return old;
end;
funcs.getrunningscripts = function()
      local runningscripts = {};
      for i = 1, #registry do
            local value = registry[i];
            if (type(value) ~= 'thread') then
                  continue;
            end;
            local env = gettenv(value);
            local script = env.script;
            if (script and not find(runningscripts, script)) then
                  insert(runningscripts, script);
            end;
      end;
      return runningscripts;
end;
funcs.getactors = function()
      local actors = {};
      local descendants = getDescendants(game);
      for i = 1, #descendants do 
            local value = descendants[i];
            if (value.ClassName == 'Actor') then
                  insert(actors, value);
            end;
      end
      return actors;
end;
funcs.getscriptenvs = function()
      local envs = {};
      for i = 1, #registry do
            local value = registry[i];
            if (type(value) ~= 'thread') then
                  continue;
            end;
            local env = gettenv(value);
            local script = env.script;
            if (script and not envs[script]) then
                  envs[script] = env;
            end;
      end;
      return envs;
end;

for index, value in funcs do
      global_enviroment[index] = clonefunction(newcclosure(value));
end;