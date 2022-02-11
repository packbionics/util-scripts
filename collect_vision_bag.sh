read -p "Enter bag duration in seconds: " duration
read -p "Enter bag name: " bag_name
# modify bag_name if directory exists
if [ -d ~/dev_ws/bag_files/${bag_name} ]; then
    echo "Directory ~/dev_ws/bag_files/${bag_name} exists. Please enter a new bag name."
    read -p "Enter bag name: " bag_name
fi
read -p "Enter storage machine username: " local_username
read -p "Enter storage machine ip: " local_ip

# Startup container
bash launch_foxy.sh &
BACKGROUND_PID=$!
# Wait for container to start
wait $BACKGROUND_PID

# Find container id
CONTAINER_ID=$(docker ps --filter ancestor=dustynv/ros:foxy-slam-l4t-r32.5.0 -q)

# Start recording bag
docker exec $CONTAINER_ID bash -c "source ros_entrypoint.sh;\
                                cd home/packbionics/dev_ws/bag_files;\
                                ros2 bag record -o ${bag_name} -a" &
BAG_PID=$!
sleep 3
# Launch zed_wrapper
docker exec $CONTAINER_ID bash -c "source ros_entrypoint.sh;\
                                source home/packbionics/dev_ws/install/setup.bash;\
                                ros2 launch jetleg_vision jetleg_zed2i.launch.py" &
WRAPPER_PID=$!

abort_script() {
    echo "Aborting bag record..."
    kill -9 $BAG_PID
    kill -9 $WRAPPER_PID
    docker stop $CONTAINER_ID
    sudo rm -r ~/dev_ws/bag_files/${bag_name}
    exit
}

trap "abort_script" SIGINT SIGTERM

# Wait for recording to finish
sleep $(( $duration + 8 ))
docker stop $CONTAINER_ID

# Copy bag file to storage machine
scp -r ~/dev_ws/bag_files/$bag_name $local_username@$local_ip:~
if [ "$?" -eq "0" ];
then
    echo "Bag file saved to ~/$bag_name on $local_ip"
else
    sudo rm -r ~/dev_ws/bag_files/$bag_name
    echo "scp failed, abort
fi
