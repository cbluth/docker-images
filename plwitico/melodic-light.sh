#!/usr/bin/env bash

function check_nvidia2() {
    # If we don't have an NVIDIA graphics card, bail out
    lspci | grep -qi "vga .*nvidia" || return 1
    # If we don't have the nvidia runtime, bail out
    if ! docker -D info | grep -qi "runtimes.* nvidia" ; then
       echo "nvidia-docker v2 not installed (see https://github.com/NVIDIA/nvidia-docker/wiki)"
       return 2
    fi
    echo "found nvidia-docker v2"
    DOCKER_PARAMS="\
      --runtime=nvidia \
      --env=NVIDIA_VISIBLE_DEVICES=${NVIDIA_VISIBLE_DEVICES:-all} \
      --env=NVIDIA_DRIVER_CAPABILITIES=${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}all"
    return 0
}

function check_nvidia1() {
    # If we don't have an NVIDIA graphics card, bail out
    lspci | grep -qi "vga .*nvidia" || return 1
    # Check whether nvidia-docker is available
    if ! which nvidia-docker > /dev/null ; then
       echo "nvidia-docker v1 not installed either"
       return 2
    fi
    # Check that nvidia-modprobe is installed
    if ! which nvidia-modprobe > /dev/null ; then
       echo "nvidia-docker-plugin requires nvidia-modprobe. Please install it!"
       return 3
    fi
    # Retrieve device parameters from nvidia-docker-plugin
    if ! DOCKER_PARAMS=$(curl -s http://localhost:3476/docker/cli) ; then
       echo "nvidia-docker-plugin not responding on http://localhost:3476/docker/cli"
       echo "See https://github.com/NVIDIA/nvidia-docker/wiki/Installation-(version-1.0)"
       return 3
    fi
    echo "found nvidia-docker v1"
    DOCKER_EXECUTABLE=nvidia-docker
}

function check_dri() {
    # If there is no /dev/dri, bail out
    test -d /dev/dri || return 1
    DOCKER_PARAMS="--device=/dev/dri --group-add video"
}

function transfer_x11_permissions() {
    # store X11 access rights in temp file to be passed into docker container
    XAUTH=/tmp/.docker.xauth
    touch $XAUTH
    xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
}

function count_positional_args() {
    while true ; do
       case "${1:-}" in
          # Skip common options with a subsequent positional argument
          # This list is not exhaustive! Augment as you see fit.
          -v|--volume) shift ;;
          -w) shift ;;
          -e) shift ;;
          # Skip all other options
          -*) ;;
          *) break ;;
       esac
       shift
    done
    # Return remaining number of arguments
    echo $#
}

ACTION=
if [ $# -eq 0 ] ; then
   # If no options are specified at all, use the name "plwitico-melodic-light"
   CONTAINER_NAME=plwitico-melodic-light
else
  case "$1" in
    rm|remove)
      shift
      ACTION="remove"
      ;;
    stop)
      shift
      ACTION="stop"
      ;;
    *)
      # Check for option -c or --container in first position
      case "$1" in
        -c|--container)
          shift
          # If next argument is not an option, use it as the container name
          if [[ "${1:-}" != -* ]] ; then
             CONTAINER_NAME="${1:-}"
             shift
          fi
          ;;
      esac
      ;;
  esac
  # Set default container name if still undefined
  CONTAINER_NAME="${CONTAINER_NAME:-plwitico-melodic-light}"
fi

if [ "${ACTION}" = "remove" ] ; then
  docker kill ${CONTAINER_NAME}
  docker rm -v -f ${CONTAINER_NAME}
  exit 0
fi

if [ "${ACTION}" = "stop" ] ; then
  docker stop ${CONTAINER_NAME}
  exit 0
fi

transfer_x11_permissions

# Probe for nvidia-docker (version 2 or 1)
check_nvidia2 || check_nvidia1 || check_dri || echo "No supported graphics card found"

DOCKER_EXECUTABLE=${DOCKER_EXECUTABLE:-docker}

# If CONTAINER_NAME was specified and this container already exists, continue it
if [ -n "${CONTAINER_NAME:-}" ] ; then
    if [ -z "$($DOCKER_EXECUTABLE ps -aq --filter name=^$CONTAINER_NAME\$)" ] ; then
       # container not yet existing: add an option to name the container when running docker below
       NAME_OPTION="--name=$CONTAINER_NAME"
       if [ "$(count_positional_args $@)" == "0" ] ; then
          # If no further (positional) arguments were provided, start a bash in the default image (for dummy users)
          DUMMY_DEFAULTS="-t -d ssilenzi/plwitico:melodic-light"
       fi
    else
       if [ -z "$($DOCKER_EXECUTABLE ps -q --filter name=^$CONTAINER_NAME\$)" ] ; then
          echo -n "Start existing, but stopped container: "
          docker start $CONTAINER_NAME
       fi
       echo "Entering container: $CONTAINER_NAME"
       if [ $# -eq 0 ] ; then
          docker exec -it $CONTAINER_NAME bash -i
       else
          docker exec $CONTAINER_NAME $@
       fi
       rm $XAUTH
       exit 0
    fi
fi

${DOCKER_EXECUTABLE:-docker} run \
    -p 127.0.0.1:11311:11311 \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="XAUTHORITY=$XAUTH" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="$XAUTH:$XAUTH" \
    --volume=$(dirname "$0")/gurobi.lic:/opt/gurobi950/gurobi.lic:ro \
    --volume=$HOME/mosek/mosek.lic:/home/ubuntu/mosek/mosek.lic:ro \
    ${NAME_OPTION:-} \
    ${DOCKER_PARAMS:-} \
    $@ ${DUMMY_DEFAULTS:-}
docker cp $(dirname "$0")/smartgit $CONTAINER_NAME:/home/ubuntu/.config/
docker exec -it $CONTAINER_NAME bash -c "sudo chown -R ubuntu:ubuntu /home/ubuntu/.config/smartgit/"
docker cp $(dirname "$0")/melodic-init.sh $CONTAINER_NAME:/workspaces/
docker exec -it $CONTAINER_NAME bash -i -c "sudo chown ubuntu:ubuntu /workspaces/melodic-init.sh; \
                              bash /workspaces/melodic-init.sh; \
                              rm /workspaces/melodic-init.sh"

# cleanup
rm $XAUTH

