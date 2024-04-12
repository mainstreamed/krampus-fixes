# Krampus Fixes

Put [main.lua](main.lua) or loadstring in autoexec for the fixes to work

Loadstring
`loadstring(request({Url='https://raw.githubusercontent.com/mainstreamed/krampus-fixes/main/main.lua',Method='GET'}).Body)()`

includes:
- added decompile function (not mine)
- added replaceclosure function
- fix for drawings within run_on_actor
- fix for setfpscap and getfpscap
- fix for restorefunction crashing (scuffed asf)
- recreations for some functions (maybe more optimised?)
