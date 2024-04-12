local global_enviroment = getgenv();

local typeof            = clonefunction(typeof);
local mt                = getrawmetatable(Drawing.new('Square'));

local funcs = {};
funcs.isrenderobj = function(drawing)
      return (typeof(drawing) == 'DrawingObject');
end;
funcs.setrenderproperty = mt.__newindex;
funcs.getrenderproperty = mt.__index;

for index, value in funcs do
      global_enviroment[index] = clonefunction(newcclosure(value));
end;