@echo off
if "%1"=="init" goto init
if "%1"=="rm" goto rm
if "%1"=="shell" goto shell
if "%1"=="start" goto start
if "%1"=="stop" goto stop
echo No start / stop supplied
exit /B 1

:init
    ipconfig.exe | grep 'vEthernet (WSL)' -A4 | cut -d':' -f 2 | tail -n1 | sed -e 's/\s*//g' > tmp
    set /p HOST= < tmp
    del tmp
    docker run -d -t ^
        --network=host ^
        --cap-add=SYS_PTRACE ^
        --security-opt=seccomp:unconfined ^
        --security-opt=apparmor:unconfined ^
        --gpus=all ^
        --name plwitico-noetic ^
        --env="DISPLAY=%HOST%:0" ^
        --env="QT_X11_NO_MITSHM=1" ^
        --volume="%~dp0\gurobi.lic":"/opt/gurobi950/gurobi.lic":ro ^
        --volume="%~dp0\mosek.lic":"/home/ubuntu/mosek/mosek.lic":ro ^
        ssilenzi/plwitico:noetic-light
    docker cp "%~dp0\smartgit" plwitico-noetic:/home/ubuntu/.config/
    docker exec -it plwitico-noetic bash -c "sudo chown -R ubuntu:ubuntu /home/ubuntu/.config/smartgit/"
    docker cp "%~dp0\noetic-init.sh" plwitico-noetic:/workspaces/
    docker exec -it plwitico-noetic bash -c "sudo chown ubuntu:ubuntu /workspaces/noetic-init.sh"
    docker exec -it plwitico-noetic bash -i "/workspaces/noetic-init.sh"
    docker exec -it plwitico-noetic bash -c "rm /workspaces/noetic-init.sh"
goto :eof

:rm
docker kill plwitico-noetic
docker rm -v -f plwitico-noetic
goto :eof

:shell
docker exec -it -w /workspaces/planning-with-tight-constraints plwitico-noetic bash -i
goto :eof

:start
docker start plwitico-noetic
goto :eof

:stop
docker stop plwitico-noetic
goto :eof
