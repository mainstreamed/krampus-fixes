local global_enviroment       = getgenv();
local registry                = getreg();

local globals                 = {};
local reg                     = {};

local httpservice             = cloneref(game.HttpService);
local mt                      = getrawmetatable(Drawing.new('Square'));

local getrenderproperty       = clonefunction(mt.__index);
local setrenderproperty       = clonefunction(mt.__newindex);
local drawing_new             = clonefunction(Drawing.new);
local getnamecallmethod       = clonefunction(getnamecallmethod);
local run_on_actor            = clonefunction(run_on_actor);
local create_comm_channel     = clonefunction(create_comm_channel);
local get_comm_channel        = clonefunction(get_comm_channel);
local hookfunc                = clonefunction(hookfunc);
local clonefunction           = clonefunction(clonefunction);
local getscriptbytecode       = clonefunction(getscriptbytecode);
local getrawmetatable         = clonefunction(getrawmetatable);
local setrawmetatable         = clonefunction(setrawmetatable);
local base64_encode           = clonefunction(base64_encode);
local setreadonly             = clonefunction(setreadonly);
local getfflag                = clonefunction(getfflag);
local setfflag                = clonefunction(setfflag);
local gettenv                 = clonefunction(gettenv);

local jsondecode              = clonefunction(httpservice.JSONDecode);
local sub                     = clonefunction(string.sub);
local clone                   = clonefunction(table.clone);
local freeze                  = clonefunction(table.freeze);
local insert                  = clonefunction(table.insert);
local find                    = clonefunction(table.find);
local typeof                  = clonefunction(typeof);
local type                    = clonefunction(type);
local error                   = clonefunction(error);
local pcall                   = clonefunction(pcall);
local rawset                  = clonefunction(rawset);
local rawget                  = clonefunction(rawget);
local isA                     = clonefunction(game.IsA);
local getDescendants          = clonefunction(game.GetDescendants);

-- drawing fix setup
do
      local cache = {
            connections = {},
            drawings = {},
            index = 0,
      };
      
      globals.id, globals.event = create_comm_channel();
      globals.Event = globals.event.Event;
      
      local fire = clonefunction(globals.event.Fire);
      
      -- comm channel handler
      do
            -- creating main connection
            do
                  local main_connection = function(...)
                        local args = {...};
                        if (args[1] ~= '❤') then
                              for i = 1, #cache.connections do
                                    cache.connections[i](...);
                              end;
                              return;
                        elseif (args[2] ~= 'parallel') then
                              return;
                        end;
      
                        local action, id, index, value = args[3], args[4], args[5], args[6];
                        if (action == 'index') then
                              fire(globals.event, '❤', 'serial', getrenderproperty(cache.drawings[id], index));
                        elseif (action == 'new') then
                              cache.index += 1;
                              fire(globals.event, '❤', 'serial', cache.index);
                              cache.drawings[cache.index] = drawing_new(id, index);
                        elseif (action == 'remove') then
                              cache.drawings[id]:Remove();
                        elseif (action == 'newindex') then
                              if (index == 'Font') then
                                    value = cache.drawings[value.X];
                              end;
                              cache.drawings[id][index] = value;
                        end;
                  end;
                  globals.Event:Connect(main_connection);
            end;
            -- hooking communications
            do
                  local mt_event = clone(getrawmetatable(globals.event));
                  local mt_connect = clone(getrawmetatable(globals.Event));
      
                  local old_event = mt_event.__index
                  local old_connect_namecall = mt_connect.__namecall;
                  local old_connect_index = mt_connect.__index;
      
                  mt_event.__index = function(self, index, ...)
                        if (self == globals.event and index == 'Event') then
                              return globals.Event;
                        end;
                        return old_event(self, index, ...);
                  end;
                  mt_connect.__namecall = function(self, func, ...)
                        if (self == globals.Event and type(func) == 'function' and getnamecallmethod() == 'Connect') then
                              insert(cache.connections, func);
                              return;
                        end;
                        return old_connect_namecall(self, func, ...);
                  end;
                  mt_connect.__index = function(self, index, ...)
                        if (self == globals.Event and index == 'Connect') then
                              return function(self, func)
                                    if (self == globals.Event and type(func) == 'function') then
                                          insert(cache.connections, func);
                                          return;
                                    end;
                              end;
                        end;
                        return old_connect_index(self, index, ...);
                  end;
      
                  setrawmetatable(globals.event, mt_event);
                  setrawmetatable(globals.Event, mt_connect);
            end;
      end;
end;


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
funcs.run_on_actor = function(actor, string, ...)
      string = [[
            local Drawing;
            local get_comm_channel = get_comm_channel;

            do 
                  local old_get_comm_channel = clonefunction(get_comm_channel)
                  local log;
                  local newuserdata       = Vector2.new;
                  local event             = old_get_comm_channel(0);
                  local fire              = clonefunction(event.Fire);
                  local getnamecallmethod = clonefunction(getnamecallmethod);
                  local setrawmetatable   = clonefunction(setrawmetatable);

                  local insert            = clonefunction(table.insert);
                  local type              = clonefunction(type);

                  local connections       = {};

                  local getlog = function()
                        local logged = log;
                        log = nil;
                        return logged;
                  end;
                  local main_connection = function(...)
                        local args = {...};
                        if (args[1] ~= '❤') then
                              for i = 1, #connections do
                                    connections[i](...);
                              end;
                              return;
                        elseif (args[2] == 'serial') then
                              log = args[3];
                        end;
                  end;

                  event.Event:Connect(main_connection);

                  -- changing vars
                  do
                        Drawing = {new = function(...)
                              fire(event, '❤', 'parallel', 'new', ...);
                              local draw_id = getlog();
                              local userdata = newuserdata(draw_id, 0);
                              local mt = {
                                    __type = 'DrawingObject',
                                    __index = function(self, index)
                                          fire(event, '❤', 'parallel', 'index', draw_id, index);
                                          return getlog();
                                    end,
                                    __newindex = function(self, index, value)
                                          fire(event, '❤', 'parallel', 'newindex', draw_id, index, value);
                                    end,
                                    __namecall = function(self, ...)
                                          local method = getnamecallmethod();
                                          if (method == 'Remove' or method == 'Destroy') then
                                                fire(event, '❤', 'parallel', 'remove', draw_id);
                                          end;
                                    end,
                              };
                              setrawmetatable(userdata, mt);
                              return userdata;
                        end};
                        get_comm_channel = function(id, ...)
                              if (id ~= 0) then
                                    return old_get_comm_channel(id, ...);
                              end;
                              return event;
                        end;

                        getgenv().Drawing = Drawing;
                        getgenv().get_comm_channel = get_comm_channel;
                  end;

                  -- blocking communications
                  do 
                        local Event = event.Event;
                        local mt_event = table.clone(getrawmetatable(event));
                        local mt_connect = table.clone(getrawmetatable(Event));

                        local old_event = mt_event.__index
                        local old_connect_namecall = mt_connect.__namecall;
                        local old_connect_index = mt_connect.__index;

                        local new_event = function(self, index, ...)
                              if (self == event and index == 'Event') then
                                    return Event;
                              end;
                              return old_event(self, index, ...);
                        end;
                        local new_connect_namecall = function(self, func, ...)
                              if (self == Event and type(func) == 'function' and getnamecallmethod() == 'Connect') then
                                    insert(connections, func);
                                    return;
                              end;
                              return old_connect_namecall(self, func, ...);
                        end;
                        local new_connect_index = function(self, index, ...)
                              if (self == Event and index == 'Connect') then
                                    return function(self, func)
                                          if (self == Event and type(func) == 'function') then
                                                insert(connections, func);
                                                return;
                                          end;
                                    end;
                              end;
                              return old_connect_index(self, index, ...);
                        end;

                        mt_event.__index = new_event;
                        mt_connect.__namecall = new_connect_namecall;
                        mt_connect.__index = new_connect_index;

                        setrawmetatable(event, mt_event);
                        setrawmetatable(Event, mt_connect);
                  end;
            end;
      ]]..string;
      return run_on_actor(actor, string, ...);
end;
funcs.create_comm_channel = function()
      return globals.id, globals.event;
end;
funcs.get_comm_channel = function(id, ...)
      if (id ~= 0) then
            return get_comm_channel(id, ...);
      end;
      return globals.event;
end;
funcs.setfpscap = function(fpscap)
      if (type(fpscap) ~= 'number') then
            return error(`invalid argument #1 (number expected, got {typeof(fpscap)})`);
      end;
      setfflag('TaskSchedulerTargetFps', fpscap);
end;
funcs.getfpscap = function()
      local fpscap = getfflag('TaskSchedulerTargetFps') or 60;
      if (fpscap == 0) then
            return 60;
      end;
      return fpscap;
end;
funcs.isrenderobj = function(drawing)
      return (typeof(drawing) == 'DrawingObject');
end;
funcs.setrenderproperty = setrenderproperty;
funcs.getrenderproperty = getrenderproperty;
funcs.hookfunction = function(func, ...)
      if (type(func) ~= 'function') then
            return hookfunc(func, ...);
      end;
      local cloned = clonefunction(func);
      local ref = hookfunc(func, ...);
      reg[func] = cloned;
      return ref;
end;
funcs.clonefunction = function(func, ...)
      local cloned = clonefunction(func, ...);
      if (func and reg[func]) then
            reg[cloned] = reg[func];
      end;
      return cloned;
end;
funcs.restorefunction = function(func, ...)
      if (func and reg[func]) then
            hookfunc(func, reg[func]);
            reg[func] = nil;
      end;
end;
funcs.isfunctionhooked = function(func, ...)
      if (reg[func]) then
            return true;
      end;
      return false;
end;
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

-- cleanup for aliases
do
      global_enviroment.hookfunc = funcs.hookfunction;
      global_enviroment.replaceclosure = funcs.hookfunction;
      global_enviroment.clonefunc = funcs.clonefunction;
      global_enviroment.restorefunc = funcs.restorefunction;
      global_enviroment.isfunchooked = funcs.isfunctionhooked;
end;
