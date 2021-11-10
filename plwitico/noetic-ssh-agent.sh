#!/bin/bash
sudo chown ubuntu:ubuntu ~/.ssh/id_ed25519 && \
chmod 600 ~/.ssh/id_ed25519 && \
( \
  echo ''; \
  echo '# ssh-agent'; \
  echo 'SSH_ENV="${HOME}/.ssh/agent-environment"'; \
  echo ''; \
  echo 'function start_agent {'; \
  echo '    /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"'; \
  echo '    chmod 600 "${SSH_ENV}"'; \
  echo '    . "${SSH_ENV}" > /dev/null'; \
  echo '    ssh-add;'; \
  echo '}'; \
  echo ''; \
  echo '# Source SSH settings, if applicable'; \
  echo ''; \
  echo 'if [ -f "${SSH_ENV}" ]; then'; \
  echo '    . "${SSH_ENV}" > /dev/null'; \
  echo '    #ps ${SSH_AGENT_PID} doesn'"'"'t work under cywgin'; \
  echo '    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {'; \
  echo '        start_agent;'; \
  echo '    }'; \
  echo 'else'; \
  echo '    start_agent;'; \
  echo 'fi'; \
) >> ~/.bashrc

