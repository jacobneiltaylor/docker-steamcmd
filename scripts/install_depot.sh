#!/bin/bash

export DEPOT_ID=$1
export DEPOT_DIR=/opt/steam/apps/$DEPOT_ID
export STEAMCMD_USERNAME=${2:-anonymous}
export STEAMCMD_PASSWORD=${3:-anonymous}

mkdir -p $DEPOT_DIR
if [ "$STEAMCMD_PASSWORD" = "anonymous" ]; then
  steamcmd +force_install_dir $DEPOT_DIR +login $STEAMCMD_USERNAME +app_update $DEPOT_ID +quit
else
  steamcmd +force_install_dir $DEPOT_DIR +login $STEAMCMD_USERNAME $STEAMCMD_PASSWORD +app_update $DEPOT_ID +quit
fi
