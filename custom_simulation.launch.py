import math
from launch import LaunchDescription
from launch.actions import (
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    OpaqueFunction,
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

    gz_sim_launch = PathJoinSubstitution(
        [pkg_clearpath_gz, "launch", "gz_sim.launch.py"]
    )

    gz_sim = IncludeLaunchDescription(
        PythonLaunchDescriptionSource([gz_sim_launch]),
        launch_arguments=[("world", LaunchConfiguration("world"))],
    )

    custom_ekf = Node(
        package="robot_localization",
        executable="ekf_node",
        name="ekf_node",
        namespace="husky",
        output="screen",
        parameters=["/workspace/husky-sim/husky_config/custom_ekf.yaml"],
        remappings=[("odometry/filtered", "platform/odom/filtered")],
    )

    tf_fix = Node(
        package="tf2_ros",
        executable="static_transform_publisher",
        name="imu_tf_fix",
        output="screen",
        arguments=["0", "0", "0", "0", "0", "0", "husky/base_link", "imu_0_link"],
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

    ld.add_action(gz_sim)
    ld.add_action(OpaqueFunction(function=robot_spawn_calculation))
    ld.add_action(tf_fix)
    ld.add_action(custom_ekf)

    return ld
