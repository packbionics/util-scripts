# util-scripts
Automating boring stuff

## Descriptions
`collect_vision_bag`: Collect ROS2 bag files for stereo vision from Jetson Nano, store on specified machine using scp

`launch_foxy`: Create a Docker container on Jetson Nano for running ROS2 Foxy

`run_stereo_vision`: Start the ZED 2i camera and output a point cloud to a ROS 2 topic 

## Accessing the Zed2i Camera

### Preconditions
* Ensure the ZED Box is powered on
* Ensure the ZED 2i is connected to the ZED Box. **Note:** You may need to connect the camera using a USB 3.0 port. This is colored blue on the ZED Box.
* Ensure you have a ROS 2 distro installed on the machine. **Note:** The ZED Box should already have ROS 2 Eloquent installed
* Ensure RVIZ2 is installed on the machine.

### Steps

1. Run the script to start outputting the point cloud from the camera
```bash
sudo ./run_stereo_vision.sh
```
2. Enter the password to provide `sudo` access

3. Source the ROS 2 distro

```bash
. /opt/ros/{ROS2_DISTRO}/setup.bash
```

4. Start RVIZ2

```bash
rviz2
```

5. Find and add the PointCloud2 topic containing the text "registered," in RVIZ2

6. Set the QoS for the added topic to "Best Effort" on the topic added

At this point, you should see a point cloud on the RVIZ2 viewport.
