#!/bin/bash
mkdir -p "${HOME}/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/imageConfigs" 2> /dev/null
find $(dirname ""$0"") -type f -name "*.json" | xargs -I{} cp {} "${HOME}/.config/Code/User/globalStorage/ms-vscode-remote.remote-containers/imageConfigs/"
