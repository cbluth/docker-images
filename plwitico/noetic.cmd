@echo off
if "%1"=="init" goto init
if "%1"=="remove" goto remove
if "%1"=="shell" goto shell
if "%1"=="start" goto start
if "%1"=="stop" goto stop
echo No start / stop supplied
exit /B 1

:init
    docker run -d ^
        --shm-size=4g ^
        -p 127.0.0.1:2222:22 ^
        -p 127.0.0.1:5901:6080 ^
        -p 127.0.0.1:11311:11311 ^
        --expose 11311 ^
        --cap-add=SYS_PTRACE ^
        --security-opt seccomp=unconfined ^
        --name plwitico-noetic ^
        ssilenzi/plwitico:noetic-local
    ssh-keygen -f "%USERPROFILE%\.ssh\known_hosts" -R "[localhost]:2222"
    docker exec -it plwitico-noetic bash -c "mkdir /home/ubuntu/.ssh"
    docker cp "%USERPROFILE%\.ssh\id_ed25519" plwitico-noetic:/home/ubuntu/.ssh/
    docker cp "%~dp0\noetic-ssh-agent.sh" plwitico-noetic:/workspace/
    docker exec -it plwitico-noetic bash -c "sudo chown ubuntu:ubuntu /workspace/noetic-ssh-agent.sh"
    docker exec -it plwitico-noetic bash "/workspace/noetic-ssh-agent.sh"
    docker exec -it plwitico-noetic bash -c "rm /workspace/noetic-ssh-agent.sh"
    docker cp "%~dp0\smartgit" plwitico-noetic:/home/ubuntu/.config/
    docker exec -it plwitico-noetic bash -c "sudo chown -R ubuntu:ubuntu /home/ubuntu/.config/smartgit/"
    docker cp "%~dp0\noetic-init.sh" plwitico-noetic:/workspace/
    docker exec -it plwitico-noetic bash -c "sudo chown ubuntu:ubuntu /workspace/noetic-init.sh"
    docker exec -it plwitico-noetic bash -i "/workspace/noetic-init.sh"
    docker exec -it plwitico-noetic bash -c "rm /workspace/noetic-init.sh"
goto :eof

:remove
docker rm -v -f plwitico-noetic
goto :eof

:shell
docker exec -it -w /workspace/planning-with-tight-constraints plwitico-noetic bash -i
goto :eof

:start
docker start plwitico-noetic
goto :eof

:stop
docker stop plwitico-noetic
goto :eof
