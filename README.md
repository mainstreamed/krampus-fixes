[![Build status](https://avatars.githubusercontent.com/u/104525888?s=36&v=4)](https://github.com/git/git/actions?query=branch%3Amaster+event%3Apush) 
# Krampus Fixes

Put [main.lua](main.lua) or the loadstring below in autoexec for the fixes to work

Loadstring version⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
`loadstring(request({Url='https://raw.githubusercontent.com/mainstreamed/krampus-fixes/main/main.lua',Method='GET'}).Body)();`

**Includes:**
- adds the following to run_on_actor enviroment (Drawing, set/getrenderproperty, isrenderobj, cleardrawcache, getactors, on_actor_created)
- adds all fixes and additions below to run_on_actor enviroment
- adds decompile function (not mine)
- adds replacemetamethod function
- fix for setfpscap / getfpscap
- fix for restorefunction crashing
- adds more aliases (clonefunc, restorefunc, isfunchooked)
- recreations for some functions (maybe more optimised?)
