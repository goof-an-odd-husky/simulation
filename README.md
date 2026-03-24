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
    <plugin filename="libgz-sim-physics-system.so" name="gz::sim::systems::Physics"/>
    <plugin filename="libgz-sim-user-commands-system.so" name="gz::sim::systems::UserCommands"/>
    <plugin filename="libgz-sim-scene-broadcaster-system.so" name="gz::sim::systems::SceneBroadcaster"/>
    <plugin
      filename="ignition-gazebo-sensors-system"
      name="ignition::gazebo::systems::Sensors">
      <render_engine>ogre2</render_engine>
    </plugin>

    <plugin name="gz::sim::systems::Imu" filename="libgz-sim-imu-system.so"/>
    <plugin name="gz::sim::systems::NavSat" filename="libgz-sim-navsat-system.so"/>
    <spherical_coordinates>
      <surface_model>EARTH_WGS84</surface_model>
      <world_frame_orientation>ENU</world_frame_orientation>
      <latitude_deg>49.820517251129985</latitude_deg>
      <longitude_deg>24.02485719952034</longitude_deg>
      <elevation>339.40000000000146</elevation>
      <heading_deg>0</heading_deg>
    </spherical_coordinates>
```

Put the .sdf world in the root of this repository (at least for now it works this way)

If you want to change the spawn of Husky, use the `world:=sonoma origin:=-22.986687,-43.202501,35.0 spawn:=-22.98787540402462,-43.19982241436838,38.107444597408175` parameters.
- You can get the `origin` from the sdf file at sdf/world/spherical_coordinates
- `spawn` are the coordinates you want the Husky to be at.


# Foxglove

This is a tutorial for setuping Foxglove

1) Run this command to start the bridge

``` bash
ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8888
```

2) Open Foxglove studio dashboard and choose Open connection
3) Select Foxglove WebSocket and change port from 8765 to 8888
4) Launch your gazebo simulation
