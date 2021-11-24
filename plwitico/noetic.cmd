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
        --name plwitico-noetic ^
        --env="DISPLAY=172.22.32.1:0" ^
        --env="QT_X11_NO_MITSHM=1" ^
        --volume="%~dp0\gurobi.lic":"/opt/gurobi950/gurobi.lic":ro ^
        ssilenzi/plwitico:noetic-light
    docker exec -it plwitico-noetic bash -c "echo ^"127.0.0.1 %COMPUTERNAME%^" | sudo tee -a /etc/hosts" 1> NUL 2>&1
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
