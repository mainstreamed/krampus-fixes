local global_enviroment = getgenv();

local hookfunc          = clonefunction(hookfunc);
local clonefunction     = clonefunction(clonefunction);

local reg = {};

local funcs = {};
funcs.hookfunction = function(func, ...)
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