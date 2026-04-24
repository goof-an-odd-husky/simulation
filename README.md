# Setup

```bash
./init.sh
```

# Run

Custom simulation script:

```bash
ros2 launch custom_simulation.launch.py setup_path:=/workspace/husky-sim/husky_config slam:=false nav2:=true
```

And change the Topic to `/husky/cmd_vel`

# Custom world

```bash
ros2 launch custom_simulation.launch.py setup_path:=/workspace/husky-sim/husky_config slam:=false nav2:=true world:=sonoma z:=35
```

You can also generate a gazebo world of a projection of sattelite images onto elevation map. See https://github.com/saiaravind19/gazebo_terrain_generator. The recommended configuration is Bing Hybrid tiles of 19 depth.

When you download an .sdf world, under sdf/world/ add:

```sdf
    <plugin filename="libgz-sim-physics-system.so" name="gz::sim::systems::Physics"/>
    <plugin filename="libgz-sim-user-commands-system.so" name="gz::sim::systems::UserCommands"/>
    <plugin filename="libgz-sim-scene-broadcaster-system.so" name="gz::sim::systems::SceneBroadcaster"/>
    <plugin filename="libgz-sim-sensors-system.so" name="gz::sim::systems::Sensors">
      <render_engine>ogre2</render_engine>
    </plugin>

    <plugin name="gz::sim::systems::Imu" filename="libgz-sim-imu-system.so"/>
    <plugin name="gz::sim::systems::NavSat" filename="libgz-sim-navsat-system.so"/>

    <gui fullscreen='0'>
      <plugin filename="MinimalScene" name="3D View">
        <gz-gui>
          <title>3D View</title>
          <property type="bool" key="showTitleBar">false</property>
          <property type="string" key="state">docked</property>
        </gz-gui>
        <engine>ogre2</engine>
        <scene>park</scene>
        <ambient_light>0.4 0.4 0.4</ambient_light>
        <background_color>0.8 0.8 0.8</background_color>
        <camera_pose>-241 -603 15 0 0.5 0.7</camera_pose>
      </plugin>
      <plugin filename="Teleop" name="Teleop">
        <gz-gui>
          <title>Teleop</title>
          <property type="bool" key="showTitleBar">false</property>
          <property type="string" key="state">docked</property>
        </gz-gui>
      </plugin>
      <plugin filename="WorldControl" name="World control">
        <gz-gui>
          <title>World control</title>
          <property type="bool" key="showTitleBar">false</property>
          <property type="bool" key="resizable">false</property>
          <property type="double" key="height">72</property>
          <property type="double" key="width">121</property>
          <property type="double" key="z">1</property>
          <property type="string" key="state">floating</property>
          <anchors target="3D View">
            <line own="left" target="left"/>
            <line own="bottom" target="bottom"/>
          </anchors>
        </gz-gui>
        <play_pause>1</play_pause>
        <step>1</step>
        <start_paused>1</start_paused>
      </plugin>
      
      <plugin filename="WorldStats" name="World stats">
        <gz-gui>
          <title>World stats</title>
          <property type="bool" key="showTitleBar">false</property>
          <property type="bool" key="resizable">false</property>
          <property type="double" key="height">110</property>
          <property type="double" key="width">290</property>
          <property type="double" key="z">1</property>
          <property type="string" key="state">floating</property>
          <anchors target="3D View">
            <line own="right" target="right"/>
            <line own="bottom" target="bottom"/>
          </anchors>
        </gz-gui>
        <sim_time>1</sim_time>
        <real_time>1</real_time>
        <real_time_factor>1</real_time_factor>
        <iterations>1</iterations>
      </plugin>
      
      <plugin filename="GzSceneManager" name="Scene Manager">
        <gz-gui>
          <property type="string" key="state">floating</property>
          <property type="double" key="width">0</property>
          <property type="double" key="height">0</property>
          <property type="bool" key="showTitleBar">false</property>
          <property type="bool" key="resizable">false</property>
        </gz-gui>
      </plugin>
      
      <plugin filename="InteractiveViewControl" name="Interactive view control">
        <gz-gui>
          <property type="string" key="state">floating</property>
          <property type="double" key="width">0</property>
          <property type="double" key="height">0</property>
          <property type="bool" key="showTitleBar">false</property>
          <property type="bool" key="resizable">false</property>
        </gz-gui>
      </plugin>
      
      <plugin filename="CameraTracking" name="Camera Tracking">
        <gz-gui>
          <property type="string" key="state">floating</property>
          <property type="double" key="width">0</property>
          <property type="double" key="height">0</property>
          <property type="bool" key="showTitleBar">false</property>
          <property type="bool" key="resizable">false</property>
        </gz-gui>
      </plugin>
      <plugin filename="ComponentInspector" name="Component inspector"/>
      <plugin filename="EntityTree" name="Entity tree"/>
    </gui>

    <spherical_coordinates>
      <surface_model>EARTH_WGS84</surface_model>
      <latitude_deg>49.82358736969999</latitude_deg>
      <longitude_deg>24.027099609375</longitude_deg>
      <elevation>332.40000000000146</elevation>
    </spherical_coordinates>
```

Put the .sdf world in the `../worlds` (or in another place; then change the mount in `docker-compose.yaml`).

If you want to change the spawn of Husky, use the `origin:=lat,lon,alt spawn:=lat,lon,alt` parameters.
- You can get the `origin` from the sdf file at `sdf/world/spherical_coordinates`
- `spawn` are the coordinates you want the Husky to be at.

Recommended spawns for:
- Sonoma: `origin:=-22.986687,-43.202501,35.0 spawn:=-22.987875,-43.199822,38.108`
- Stryiskyi Park: `origin:=49.823587,24.027099,332.405 spawn:=49.81815,24.02364,344.5`

# Foxglove

1) Run this command to start the bridge
    - `ros2 launch foxglove_bridge foxglove_bridge_launch.xml port:=8888`
2) Open Foxglove studio dashboard and choose Open connection
3) Select Foxglove WebSocket and change port from 8765 to 8888
4) Launch your gazebo simulation
