@echo off
set argC=0
for %%x in (%*) do set /A argC+=1
if %argC% NEQ 2 goto noarg
docker run -it --rm --shm-size=2g -p 127.0.0.1:%2:6080 --name %1 ssilenzi/recordings:latest
goto :eof

:noarg
echo No arguments supplied
exit /B 1

