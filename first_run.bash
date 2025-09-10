#!/bin/bash

# If not working, first try: sudo rm -rf /tmp/.docker.xauth
# If still not working, try running the script as root.

# User inputs
read -p "Project name (base): " NAME_BASE
read -p "Which Platform? (PX4 / Mavlink): " PLATFORM
read -p "Which Mode? (Hardware / Simulation): " MODE

echo "alias ${NAME_BASE}_docker='docker start -i ${NAME_BASE}_drone_env_cont && docker exec -it ${NAME_BASE}_drone_env_cont /bin/bash'" >> ~/.bashrc
echo "Alias '${NAME_BASE}_docker' added to ~/.bashrc"

XAUTH=/tmp/.docker.xauth

echo "=== Exporting DOCKER_BUILDKIT ==="
export DOCKER_BUILDKIT=1

echo "=== Building Docker Image ==="
docker build --ssh default -t ${NAME_BASE}_drone_env_img -f Dockerfile_${PLATFORM}_${MODE} .

echo "=== Preparing Xauthority ==="
xauth_list=$(xauth nlist :0 | tail -n 1 | sed -e 's/^..../ffff/')
if [ ! -f $XAUTH ]; then
    if [ ! -z "$xauth_list" ]; then
        echo $xauth_list | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

echo "=== Done ==="
echo ""
echo "Checking file content:"
file $XAUTH
echo "--> It should say \"X11 Xauthority data\"."
echo ""
echo "Permissions:"
ls -FAlh $XAUTH
echo ""
echo "Running Docker container..."

# Hook to current SSH_AUTH_SOCK (it changes dynamically)
ln -sf $SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock

docker run -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --env="TERM=xterm-256color" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="/dev:/dev" \
    --volume="/var/run/dbus/:/var/run/dbus/:z" \
    --volume ~/.ssh/ssh_auth_sock:/ssh-agent \
    --env SSH_AUTH_SOCK=/ssh-agent \
    --net=host \
    --privileged \
    --gpus all \
    --name ${NAME_BASE}_drone_env_cont \
    ${NAME_BASE}_drone_env_img

# Create dynamic alias in ~/.bashrc
echo "alias ${NAME_BASE}_docker='docker start -i ${NAME_BASE}_drone_env_cont && docker exec -it ${NAME_BASE}_drone_env_cont /bin/bash'" >> ~/.bashrc
echo "Alias '${NAME_BASE}_docker' added to ~/.bashrc"
