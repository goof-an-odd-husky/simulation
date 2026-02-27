# Run

Custom simulation script:

```bash
ros2 launch custom_simulation.launch.py setup_path:=/workspace/husky-sim/husky_config slam:=false nav2:=true
```

And change the Topic to /husky/cmd_vel

# Custom world

```bash
ros2 launch custom_simulation.launch.py setup_path:=/workspace/husky-sim/husky_config slam:=false nav2:=true world:=sonoma z:=35
```

Works only with the custom script

When you download an .sdf world, under sdf/world/ add:

```sdf
    <plugin name="gz::sim::systems::Imu" filename="libgz-sim-imu-system.so"/>
    <plugin name="gz::sim::systems::NavSat" filename="libgz-sim-navsat-system.so"/>
    <spherical_coordinates>
      <surface_model>EARTH_WGS84</surface_model>
      <world_frame_orientation>ENU</world_frame_orientation>
      <latitude_deg>-22.986687</latitude_deg>
      <longitude_deg>-43.202501</longitude_deg>
      <elevation>35</elevation>
      <heading_deg>0</heading_deg>
    </spherical_coordinates>
```


# Foxglove

This is a tutorial for setuping Foxglove

1) Run this command to start the bridge

``` bash
ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8888
```

2) Open Foxglove studio dashboard and choose Open connection
3) Select Foxglove WebSocket and change port from 8765 to 8888
4) Launch your gazebo simulation
