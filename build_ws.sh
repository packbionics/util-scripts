bash launch_foxy.sh &
BACKGROUND_PID=$!
# Wait for container to start
wait $BACKGROUND_PID

# Find container id
CONTAINER_ID=$(docker ps --filter ancestor=dustynv/ros:foxy-slam-l4t-r32.6.1 -q)

docker exec $CONTAINER_ID bash -c "source ros_entrypoint.sh;\
				   cd home/packbionics/dev_ws;\
			           colcon build --symlink-install" &
BUILDER_PID=$!

abort_script() {
    echo "Aborting build..."
    kill -9 $BUILDER_PID
    docker stop $CONTAINER_ID
    exit
}

trap "abort_script" SIGINT SIGTERM

wait $BUILDER_PID
docker stop $CONTAINER_ID
