read -p "Enter bag duration in seconds: " duration
read -p "Enter bag name: " bag_name
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
# Launch zed_wrapper
docker exec $CONTAINER_ID bash -c "source ros_entrypoint.sh;\
                                source home/packbionics/dev_ws/install/setup.bash;\
                                ros2 launch jetleg_vision jetleg_zed2i.launch.py" &

# Wait for recording to finish
sleep $(( $duration + 5 ))
docker stop $CONTAINER_ID

# Copy bag file to storage machine
scp -r ~/dev_ws/bag_files/$bag_name $local_username@$local_ip:~

echo "Bag file saved to ~/$bag_name on $local_ip"