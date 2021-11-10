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
        -p 127.0.0.1:4444:22 ^
        -p 127.0.0.1:5902:6080 ^
        -p 127.0.0.1:22622:11311 ^
        --expose 11311 ^
        --cap-add=SYS_PTRACE ^
        --security-opt seccomp=unconfined ^
        --name plwitico-melodic ^
        ssilenzi/plwitico:melodic-local
    ssh-keygen -f "%USERPROFILE%\.ssh\known_hosts" -R "[localhost]:2222"
    docker exec -it plwitico-melodic bash -c "mkdir /home/ubuntu/.ssh"
    docker cp "%USERPROFILE%\.ssh\id_ed25519" plwitico-melodic:/home/ubuntu/.ssh/
    docker cp "%~dp0\melodic-ssh-agent.sh" plwitico-melodic:/workspace/
    docker exec -it plwitico-melodic bash -c "sudo chown ubuntu:ubuntu /workspace/melodic-ssh-agent.sh"
    docker exec -it plwitico-melodic bash "/workspace/melodic-ssh-agent.sh"
    docker exec -it plwitico-melodic bash -c "rm /workspace/melodic-ssh-agent.sh"
    docker cp "%~dp0\smartgit" plwitico-melodic:/home/ubuntu/.config/
    docker exec -it plwitico-melodic bash -c "sudo chown -R ubuntu:ubuntu /home/ubuntu/.config/smartgit/"
    docker cp "%~dp0\melodic-init.sh" plwitico-melodic:/workspace/
    docker exec -it plwitico-melodic bash -c "sudo chown ubuntu:ubuntu /workspace/melodic-init.sh"
    docker exec -it plwitico-melodic bash -i "/workspace/melodic-init.sh"
    docker exec -it plwitico-melodic bash -c "rm /workspace/melodic-init.sh"
goto :eof

:remove
docker rm -v -f plwitico-melodic
goto :eof

:shell
docker exec -it -w /workspace/planning-with-tight-constraints plwitico-melodic bash -i
goto :eof

:start
docker start plwitico-melodic
goto :eof

:stop
docker stop plwitico-melodic
goto :eof
