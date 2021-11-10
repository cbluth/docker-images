@echo off
md "%APPDATA%\Code\User\globalStorage\ms-vscode-remote.remote-containers\imageConfigs" 2> NUL
copy "%~dp0*.json" ^
  "%APPDATA%\Code\User\globalStorage\ms-vscode-remote.remote-containers\imageConfigs\"
