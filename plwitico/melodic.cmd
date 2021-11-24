@echo off
if "%1"=="init" goto init
if "%1"=="rm" goto rm
if "%1"=="shell" goto shell
if "%1"=="start" goto start
if "%1"=="stop" goto stop
echo No start / stop supplied
exit /B 1

:init
    docker run -d -t ^
        --network=host ^
        --cap-add=SYS_PTRACE ^
        --security-opt=seccomp:unconfined ^
        --security-opt=apparmor:unconfined ^
        --gpus=all ^
        --name plwitico-melodic ^
        --env="DISPLAY=172.22.32.1:0" ^
        --env="QT_X11_NO_MITSHM=1" ^
        --volume="%~dp0\gurobi.lic":"/opt/gurobi950/gurobi.lic":ro ^
        ssilenzi/plwitico:melodic-light
    docker cp "%~dp0\smartgit" plwitico-melodic:/home/ubuntu/.config/
    docker exec -it plwitico-melodic bash -c "sudo chown -R ubuntu:ubuntu /home/ubuntu/.config/smartgit/"
    docker cp "%~dp0\melodic-init.sh" plwitico-melodic:/workspaces/
    docker exec -it plwitico-melodic bash -c "sudo chown ubuntu:ubuntu /workspaces/melodic-init.sh"
    docker exec -it plwitico-melodic bash -i "/workspaces/melodic-init.sh"
    docker exec -it plwitico-melodic bash -c "rm /workspaces/melodic-init.sh"
goto :eof

:rm
docker kill plwitico-melodic
docker rm -v -f plwitico-melodic
goto :eof

:shell
docker exec -it -w /workspaces/planning-with-tight-constraints plwitico-melodic bash -i
goto :eof

:start
docker start plwitico-melodic
goto :eof

:stop
docker stop plwitico-melodic
goto :eof
