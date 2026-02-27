# Run

```bash
ros2 launch clearpath_gz simulation.launch.py setup_path:=/workspace/husky-sim/husky_config slam:=true nav2:=true
```

And change the Topic to /husky/cmd_vel

# Foxglove

This is a tutorial for setuping Foxglove

1) Run this command to start the bridge

``` bash
ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8888
```

2) Open Foxglove studio dashboard and choose Open connection
3) Select Foxglove WebSocket and change port from 8765 to 8888
4) Launch your gazebo simulation
