#!/bin/bash

export DEPOT_ID=$1
export DEPOT_DIR=/opt/steam/apps/$DEPOT_ID

mkdir -p $DEPOT_DIR
steamcmd +force_install_dir $DEPOT_DIR +login anonymous +app_update $DEPOT_ID +quit
