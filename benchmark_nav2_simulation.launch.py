import os
import math
from launch import LaunchDescription, actions
from launch.actions import (
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    OpaqueFunction, TimerAction
)
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import (
    EnvironmentVariable,
    LaunchConfiguration,
    PathJoinSubstitution,
)
from launch_ros.substitutions import FindPackageShare
from launch_ros.actions import Node


def robot_spawn_calculation(context, *args, **kwargs):
    pkg_clearpath_gz = FindPackageShare("clearpath_gz")
    robot_spawn_launch = PathJoinSubstitution(
        [pkg_clearpath_gz, "launch", "robot_spawn.launch.py"]
    )

    origin_gps = context.launch_configurations.get("origin", "")
    spawn_gps = context.launch_configurations.get("spawn", "")

    x_val = context.launch_configurations.get("x")
    y_val = context.launch_configurations.get("y")
    z_val = context.launch_configurations.get("z")

    if origin_gps and spawn_gps:
        try:
            o_lat, o_lon, o_alt = [float(v) for v in origin_gps.split(",")]
            s_lat, s_lon, s_alt = [float(v) for v in spawn_gps.split(",")]

            R = 6378137.0
            lat_rad = math.radians(o_lat)

            x_val = str(math.radians(s_lon - o_lon) * R * math.cos(lat_rad))
            y_val = str(math.radians(s_lat - o_lat) * R)
            z_val = str(s_alt - o_alt)
        except ValueError:
            pass

    return [
        IncludeLaunchDescription(
            PythonLaunchDescriptionSource([robot_spawn_launch]),
            launch_arguments=[
                ("use_sim_time", LaunchConfiguration("use_sim_time")),
                ("setup_path", LaunchConfiguration("setup_path")),
                ("world", LaunchConfiguration("world")),
                ("rviz", LaunchConfiguration("rviz")),
                ("x", x_val),
                ("y", y_val),
                ("z", z_val),
                ("yaw", LaunchConfiguration("yaw")),
            ],
        )
    ]


def generate_launch_description():
    pkg_clearpath_gz = FindPackageShare("clearpath_gz")

    current_prefix = os.environ.get('AMENT_PREFIX_PATH', '')
    os.environ['AMENT_PREFIX_PATH'] = f'/workspace:{current_prefix}'
    arg_world = DeclareLaunchArgument(
        "world",
        default_value="warehouse",
        description="Gazebo World name (filename without .sdf)",
    )

    arg_rviz = DeclareLaunchArgument(
        "rviz",
        default_value="false",
        choices=["true", "false"],
        description="Start rviz.",
    )
    arg_sim_time = DeclareLaunchArgument(
        "use_sim_time",
        default_value="true",
        choices=["true", "false"],
        description="use_sim_time",
    )
    arg_setup_path = DeclareLaunchArgument(
        "setup_path",
        default_value=[EnvironmentVariable("HOME"), "/clearpath/"],
        description="Clearpath setup path",
    )

    pose_args = [
        DeclareLaunchArgument("x", default_value="0.0", description="x pose"),
        DeclareLaunchArgument("y", default_value="0.0", description="y pose"),
        DeclareLaunchArgument("z", default_value="0.3", description="z pose"),
        DeclareLaunchArgument("yaw", default_value="0.0", description="yaw pose"),
    ]

    gps_args = [
        DeclareLaunchArgument(
            "origin", default_value="", description="lat,lon,alt of world origin"
        ),
        DeclareLaunchArgument(
            "spawn", default_value="", description="lat,lon,alt of robot spawn"
        ),
    ]

    # gz_sim_launch = PathJoinSubstitution(
    #     [pkg_clearpath_gz, "launch", "gz_sim.launch.py"]
    # )

    # gz_sim = IncludeLaunchDescription(
    #     PythonLaunchDescriptionSource([gz_sim_launch]),
    #     launch_arguments=[("world", LaunchConfiguration("world"))],
    # )
    pkg_ros_gz_sim = FindPackageShare("ros_gz_sim")
    packages_paths = [os.path.join(p, 'share') for p in os.getenv('AMENT_PREFIX_PATH', '').split(':')]
    gz_sim_resource_path = actions.SetEnvironmentVariable(
        name='GZ_SIM_RESOURCE_PATH',
        value=[
            os.path.join(pkg_clearpath_gz.find('clearpath_gz'), 'worlds') + ':',
            os.path.join(pkg_clearpath_gz.find('clearpath_gz'), 'meshes') + ':',
            ':' + ':'.join(packages_paths)])
    gz_sim_launch = PathJoinSubstitution([pkg_ros_gz_sim, 'launch', 'gz_sim.launch.py'])
    gz_sim = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([gz_sim_launch]),
        launch_arguments=[
            ('gz_args', [LaunchConfiguration("world"), '.sdf -r -v 4'])
        ],
    )
    clock_bridge = Node(
        package='ros_gz_bridge',
        executable='parameter_bridge',
        name='clock_bridge',
        output='screen',
        arguments=['/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock']
    )

    ekf_config_path = "/workspace/husky-sim/husky_config/custom_ekf.yaml"
    ekf_local = Node(
        package="robot_localization",
        executable="ekf_node",
        name="ekf_node_local",
        namespace="husky",
        output="screen",
        parameters=[ekf_config_path, {
            "use_sim_time": LaunchConfiguration("use_sim_time"),
            "map_frame": "husky/map",
            "odom_frame": "husky/odom",
            "base_link_frame": "husky/base_link",
            "world_frame": "husky/odom"
        }],
        remappings=[("odometry/filtered", "odometry/local")],
    )

    ekf_global = Node(
        package="robot_localization",
        executable="ekf_node",
        name="ekf_node_global",
        namespace="husky",
        output="screen",
        parameters=[ekf_config_path, {
            "use_sim_time": LaunchConfiguration("use_sim_time"),
            "map_frame": "husky/map",
            "odom_frame": "husky/odom",
            "base_link_frame": "husky/base_link",
            "world_frame": "husky/map"
        }],
        remappings=[("odometry/filtered", "odometry/global")],
    )

    navsat_transform = Node(
        package="robot_localization",
        executable="navsat_transform_node",
        name="navsat_transform",
        namespace="husky",
        output="screen",
        parameters=[ekf_config_path, {
            "use_sim_time": LaunchConfiguration("use_sim_time"),
            "map_frame": "husky/map",
            "odom_frame": "husky/odom",
            "base_link_frame": "husky/base_link"
        }],
        remappings=[
            ("imu", "sensors/imu_0/data"),
            ("gps/fix", "sensors/gps_0/fix"),
            ("odometry/filtered", "odometry/global"),
            ("odometry/gps", "odometry/gps"),
        ],
    )

    tf_fix_imu = Node(
        package="tf2_ros",
        executable="static_transform_publisher",
        name="imu_tf_fix",
        output="screen",
        arguments=["0", "0", "0", "0", "0", "0", "husky/base_link", "imu_0_link"],
    )
    tf_fix_gps = Node(
        package="tf2_ros",
        executable="static_transform_publisher",
        name="gps_tf_fix",
        output="screen",
        arguments=["0", "0", "0", "0", "0", "0", "husky/base_link", "gps_0_link"],
    )
    tf_fix_lidar = Node(
        package="tf2_ros",
        executable="static_transform_publisher",
        name="lidar_tf_fix",
        output="screen",
        arguments=["0", "0", "0", "0", "0", "0", "husky/base_link", "lidar2d_0_laser"],
    )

    ld = LaunchDescription()
    ld.add_action(arg_world)
    ld.add_action(arg_rviz)
    ld.add_action(arg_sim_time)
    ld.add_action(arg_setup_path)
    for arg in pose_args:
        ld.add_action(arg)
    for arg in gps_args:
        ld.add_action(arg)

    ld.add_action(gz_sim_resource_path)
    ld.add_action(gz_sim)
    ld.add_action(clock_bridge)
    ld.add_action(OpaqueFunction(function=robot_spawn_calculation))
    ld.add_action(tf_fix_imu)
    ld.add_action(tf_fix_gps)
    ld.add_action(tf_fix_lidar)
    ld.add_action(ekf_local)
    ld.add_action(ekf_global)
    ld.add_action(navsat_transform)

    nav2_params_path = "/workspace/husky-sim/husky_config/benchmark_nav2_params.yaml"
    custom_controller_node = Node(
        package='goof_an_odd_husky',
        executable='benchmark_nav2',
        name='custom_controller_node',
        output='screen',
        parameters=[{'use_sim_time': LaunchConfiguration("use_sim_time")}],
        remappings=[
            ('odom', '/husky/odometry/global'),
            ('gps', '/husky/sensors/gps_0/fix'),
            ('scan', '/husky/sensors/lidar2d_0/scan')
        ]
    )
    nav2_controller_server = Node(
        package='nav2_controller',
        executable='controller_server',
        name='controller_server',
        output='screen',
        parameters=[nav2_params_path],
        remappings=[
            ('cmd_vel', '/husky/nav2_cmd_vel'), 
            ('odom', '/husky/odometry/global')
        ]
    )
    nav2_lifecycle_manager = Node(
        package='nav2_lifecycle_manager',
        executable='lifecycle_manager',
        name='lifecycle_manager_navigation',
        output='screen',
        parameters=[
            {'use_sim_time': LaunchConfiguration("use_sim_time")},
            {'autostart': True},
            {'node_names': ['controller_server']}
        ]
    )
    delayed_nav2_bringup = TimerAction(
        period=10.0,  # Wait 5 seconds before starting Nav2
        actions=[nav2_controller_server, nav2_lifecycle_manager]
    )
    ld.add_action(custom_controller_node)
    ld.add_action(delayed_nav2_bringup)

    return ld
