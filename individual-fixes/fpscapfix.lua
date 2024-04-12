local global_enviroment = getgenv();

local getfflag          = clonefunction(getfflag);
local setfflag          = clonefunction(setfflag);
local typeof            = clonefunction(typeof);
local type              = clonefunction(type);
local error             = clonefunction(error);

local funcs = {};
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

for index, value in funcs do
      global_enviroment[index] = clonefunction(newcclosure(value));
end;