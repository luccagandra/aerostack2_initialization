#!/bin/bash

# Source and destination paths
SOURCE_x500_model="/root/sim/src/aerostack2_initialization/to_copy/models/x500_px4"
DESTINATION_x500_model="/root/aerostack2_ws/src/aerostack2/as2_simulation_assets/as2_gazebo_assets/models/"

SOURCE_PX4_default_world='/root/sim/src/aerostack2_initialization/to_copy/models/default.sdf.jinja'
DESTINATION_PX4_default_world='/root/aerostack2_ws/src/aerostack2/as2_simulation_assets/as2_gazebo_assets/worlds/'

# Create destination directories if they don't exist
mkdir -p "$DESTINATION_x500_model"
mkdir -p "$DESTINATION_PX4_default_world"

# Copy folder
if [ -d "$SOURCE_x500_model" ]; then
    cp -r "$SOURCE_x500_model" "$DESTINATION_x500_model"
    echo "Folder x500_px4 copied successfully."
else
    echo "Error: Folder $SOURCE_x500_model not found!"
fi

# Copy file
if [ -f "$SOURCE_PX4_default_world" ]; then
    cp "$SOURCE_PX4_default_world" "$DESTINATION_PX4_default_world"
    echo "File default.sdf.jinja copied successfully."
else
    echo "Error: File $SOURCE_PX4_default_world not found!"
fi
