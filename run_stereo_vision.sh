# Startup container
bash launch_foxy.sh &
BACKGROUND_PID=$!
# Wait for container to start
wait $BACKGROUND_PID

# Find container id
CONTAINER_ID=$(docker ps --filter ancestor=dustynv/ros:foxy-slam-l4t-r32.6.1 -q)

# Launch vision nodes
docker exec $CONTAINER_ID bash -c "source ros_entrypoint.sh;\
                                source home/packbionics/dev_ws/install/setup.bash;\
                                ros2 launch jetleg_bringup jetleg_vision_bringup.launch.py" &
VISION_PID=$!

abort_script() {
    echo "Stopping vision node..."
    kill -9 $VISION_PID
    docker stop $CONTAINER_ID
    exit
}

trap "abort_script" SIGINT SIGTERM
wait $VISION_PID
