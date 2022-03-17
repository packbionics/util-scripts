# Startup a docker container with ROS2 Foxy + SLAM
sudo docker run --gpus all \
                --net=host \
                --privileged \
                --runtime nvidia \
                --rm --ipc=host \
                -v /tmp/.X11-unix/:/tmp/.X11-unix/ \
                -v /tmp/argus_socket:/tmp/argus_socket \
                -v /home/packbionics/dev_ws:/home/packbionics/dev_ws \
                --cap-add SYS_PTRACE -e DISPLAY=$DISPLAY \
                -dit dustynv/ros:foxy-slam-l4t-r32.6.1
