[![Build status](https://avatars.githubusercontent.com/u/104525888?s=36&v=4)](https://github.com/git/git/actions?query=branch%3Amaster+event%3Apush) 
# Krampus Fixes

Put [main.lua](main.lua) or the loadstring below in autoexec for the fixes to work

Loadstring version⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
`loadstring(request({Url='https://raw.githubusercontent.com/mainstreamed/krampus-fixes/main/main.lua',Method='GET'}).Body)()`

**Includes:**
- adds decompile function (not mine)
- adds replaceclosure function
- fix for drawings within run_on_actor
- fix for setfpscap and getfpscap
- fix for restorefunction crashing (scuffed asf)
- recreations for some functions (maybe more optimised?)
