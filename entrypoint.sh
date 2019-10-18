#!/bin/bash
###################################################################################
#
# Copyright (c) 2019 IBM Corporation and others.
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html
#
# Contributors:
#     IBM Corporation - initial API and implementation
#
###################################################################################

DIR=`dirname $0`
EXT_NAME=`basename $DIR`

ROOT=$1
LOCAL_WORKSPACE=$2
PROJECT_ID=$3
COMMAND=$4
CONTAINER_NAME=$5
AUTO_BUILD_ENABLED=$6
LOGNAME=$7
START_MODE=$8
DEBUG_PORT=$9
FORCE_ACTION=${10}
FOLDER_NAME=${11}
DEPLOYMENT_REGISTRY=${12}

WORKSPACE=/codewind-workspace

# DOCKER_BUILD=docker.build
APP_LOG=app

LOG_FOLDER=$WORKSPACE/.logs/$FOLDER_NAME

echo "*** APPSODY"
echo "*** PWD = $PWD"
echo "*** ROOT = $ROOT"
echo "*** LOCAL_WORKSPACE = $LOCAL_WORKSPACE"
echo "*** PROJECT_ID = $PROJECT_ID"
echo "*** COMMAND = $COMMAND"
echo "*** CONTAINER_NAME = $CONTAINER_NAME"
echo "*** AUTO_BUILD_ENABLED = $AUTO_BUILD_ENABLED"
echo "*** LOGNAME = $LOGNAME"
echo "*** START_MODE = $START_MODE"
echo "*** DEBUG_PORT = $DEBUG_PORT"
echo "*** FORCE_ACTION = $FORCE_ACTION"
echo "*** LOG_FOLDER = $LOG_FOLDER"
echo "*** DEPLOYMENT_REGISTRY = $DEPLOYMENT_REGISTRY"
echo "*** HOST_OS = $HOST_OS"

tag=codewind-dev-appsody
projectName=$( basename "$ROOT" )
project=$CONTAINER_NAME

# Cache constants
# dockerfile=Dockerfile
# dockerfileKey=DOCKERFILE_HASH
# dockerfileTools=Dockerfile-tools
# dockerfileToolsKey=DOCKERFILE_TOOLS_HASH
# packageJson=package.json
# packageJsonKey=PACKAGE_JSON_HASH
# nodemonJson=nodemon.json
# nodemonJsonKey=NODEMON_JSON_HASH
# chartDir=chart
# chartDirKey=CHARTDIRECTORY_HASH
# cacheUtil=/file-watcher/scripts/cache-util.sh
util=/file-watcher/scripts/util.sh

#Import general constants
source /file-watcher/scripts/constants.sh

echo project=$project
cd "$ROOT" 2> /dev/null

# Export some APPSODY env vars
# export APPSODY_MOUNT_HOME=`$DIR/scripts/get-home.sh | xargs $util getWorkspacePathForVolumeMounting`
if [ "$IN_K8" == "true" ]; then
	export APPSODY_K8S_EXPERIMENTAL=TRUE
	hostWorkspacePath="/$CHE_WORKSPACE_ID/projects"
else
	hostWorkspacePath=`$util getWorkspacePathForVolumeMounting $LOCAL_WORKSPACE`
fi
export APPSODY_MOUNT_CONTROLLER="$hostWorkspacePath/.extensions/$EXT_NAME/bin/appsody-controller"
export APPSODY_MOUNT_PROJECT="$hostWorkspacePath/$projectName"

echo APPSODY_MOUNT_CONTROLLER=$APPSODY_MOUNT_CONTROLLER
echo APPSODY_MOUNT_PROJECT=$APPSODY_MOUNT_PROJECT

set -o pipefail

function appsodyStop() {
	$DIR/appsody stop --name $CONTAINER_NAME |& tee -a $LOG_FOLDER/appsody.log
}

function appsodyStart() {

	cmd=$START_MODE

	if [ "$START_MODE" != "run" ]; then
		cmd=debug
	fi

	$DIR/appsody $cmd --name $CONTAINER_NAME --network codewind_network -P |& tee -a $LOG_FOLDER/appsody.log &
	$DIR/scripts/wait-for-container.sh $CONTAINER_NAME |& tee -a $LOG_FOLDER/appsody.log
}

function resetStates() {
	# appsody projects don't really need to "build"
	# $util updateBuildState $PROJECT_ID $BUILD_STATE_INPROGRESS "buildscripts.buildImage"
	imageLastBuild=$(($(date +%s)*1000))
	$util updateBuildState $PROJECT_ID $BUILD_STATE_SUCCESS " " "$imageLastBuild"

	$util updateAppState $PROJECT_ID $APP_STATE_STARTING
}

function cleanContainer() {
	if [ "$IN_K8" != "true" ]; then
		if [ "$($IMAGE_COMMAND ps -aq -f name=$project)" ]; then
			$util updateAppState $PROJECT_ID $APP_STATE_STOPPING
			$IMAGE_COMMAND rm -f $project
			# $IMAGE_COMMAND rmi -f $project
		fi
	fi
}

function create() {
	
	echo "Appsody deploy for $projectName"

	resetStates

	echo "Triggering log file event for: appsody app log"
	echo "Appsody app log file $LOG_FOLDER/appsody.log"
	$util newLogFileAvailable $PROJECT_ID "app"

	echo "Run appsody"
	appsodyStart
}

# Initialize the cache with the hash for select files.  Called from project-watcher.
# function initCache() {
# 	# Cache the hash codes for main files
# 	echo "Initializing cache for: $projectName"
# 	dockerfileHash=$(sha256sum $dockerfile)
# 	dockerfileToolsHash=$(sha256sum $dockerfileTools)
# 	packageJsonHash=$(sha256sum $packageJson)
# 	nodemonJsonHash=$(sha256sum $nodemonJson)
# 	$cacheUtil "$PROJECT_ID" update $dockerfileKey "$dockerfileHash" $dockerfileToolsKey "$dockerfileToolsHash" $packageJsonKey "$packageJsonHash" $nodemonJsonKey "$nodemonJsonHash"
# 	if [ "$IN_K8" == "true" ]; then
# 		chartDirHash=$(find $chartDir -type f -name "*.yaml" -exec sha256sum {} + | awk '{print $1}' | sort | sha256sum)
# 		$cacheUtil "$PROJECT_ID" update $chartDirKey "$chartDirHash"
# 	fi
# }

# Clear the node related cache files (anything that would get picked up on a node start/restart)
# function clearNodeCache() {
# 	packageJsonHash=$(sha256sum $packageJson)
# 	nodemonJsonHash=$(sha256sum $nodemonJson)
# 	$cacheUtil "$PROJECT_ID" update $packageJsonKey "$packageJsonHash" $nodemonJsonKey "$nodemonJsonHash"
# }

# Create the application image and container and start it
if [ "$COMMAND" == "create" ]; then
	# clean the container
	cleanContainer

	# Initialize the cache
	# initCache

	# Set initial state to stopped
	$util updateAppState $PROJECT_ID $APP_STATE_STOPPED
	create

# Update the application as needed
elif [ "$COMMAND" == "update" ]; then
	# dockerfileHash=$(sha256sum $dockerfile)
	# dockerfileToolsHash=$(sha256sum $dockerfileTools)
	# packageJsonHash=$(sha256sum $packageJson)
	# nodemonJsonHash=$(sha256sum $nodemonJson)
	# changedList=`$cacheUtil "$PROJECT_ID" getChanged $dockerfileKey "$dockerfileHash" $dockerfileToolsKey "$dockerfileToolsHash" $packageJsonKey "$packageJsonHash" $nodemonJsonKey "$nodemonJsonHash"`
	# if [ "$IN_K8" == "true" ]; then
	# 	chartDirHash=$(find $chartDir -type f -name "*.yaml" -exec sha256sum {} + | awk '{print $1}' | sort | sha256sum)
	# 	changedListK8=`$cacheUtil "$PROJECT_ID" getChanged $chartDirKey "$chartDirHash"`
	# 	changedList+=("${changedListK8[@]}")
	# fi
	action=NONE
	if [ $FORCE_ACTION ] && [ "$FORCE_ACTION" != "NONE" ]; then
		action=$FORCE_ACTION
	# else
	# 	for item in ${changedList[@]}; do
	# 		echo "$item changed"
	# 		if [ "$item" == "$dockerfileKey" ] || [ "$item" == "$dockerfileToolsKey" ] || [ "$item" == "$chartDirKey" ]; then
	# 			action=REBUILD
	# 			break
	# 		elif [ "$item" == "$packageJsonKey" ] || [ "$item" == "$nodemonJsonKey" ]; then
	# 			action=RESTART
	# 			# need to keep looking in case a Dockerfile was changed
	# 		fi
	# 	done
	fi
	echo "Action for project $projectName: $action"
	if [ "$action" == "REBUILD" ]; then
		echo "Rebuilding project: $projectName"
		cleanContainer
		create
	elif [ "$action" == "RESTART" ]; then
	# 	if [ "$IN_K8" == "true" ]; then
	# 		# On Kubernetes, changed files are only copied over through docker build
	# 		echo "Rebuilding project: $projectName"
	# 		create
	# 	else
			echo "Restarting project: $projectName"
			appsodyStop
			$util updateAppState $PROJECT_ID $APP_STATE_STOPPING
			resetStates
			appsodyStart
	# 	fi
	else
	# 	if [ "$IN_K8" == "true" ]; then
	# 		# No nodemon on Kubernetes and changed files are only copied over through docker build
	# 		echo "Rebuilding project: $projectName"
	# 		create
	# 	elif [ "$AUTO_BUILD_ENABLED" != "true" ]; then
			# echo "Restarting project: $projectName"
			# appsodyStop
			# $util updateAppState $PROJECT_ID $APP_STATE_STOPPING
			resetStates
			# appsodyStart
	# 	fi
	fi

# Stop the application (not supported on Kubernetes)
elif [ "$COMMAND" == "stop" ]; then
	echo "Stopping appsody project $projectName"
	appsodyStop
	$util updateAppState $PROJECT_ID $APP_STATE_STOPPING
# Start the application (not supported on Kubernetes)
elif [ "$COMMAND" == "start" ]; then
	echo "Starting appsody project $projectName"
	# Clear the cache since restarting node will pick up any changes to package.json or nodemon.json
	# clearNodeCache
	resetStates
	appsodyStart
# Enable auto build
elif [ "$COMMAND" == "enableautobuild" ]; then
	echo "Enabling auto build for appsody project $projectName"
	# Wipe out any changes to package.json or nodemon.json since restarting node will take care of them
	# clearNodeCache
	# $IMAGE_COMMAND exec $project /scripts/noderun.sh stop
	# $util updateAppState $PROJECT_ID $APP_STATE_STOPPING
	# $IMAGE_COMMAND exec $project /scripts/noderun.sh start true $START_MODE
	# $util updateAppState $PROJECT_ID $APP_STATE_STARTING
	echo "Auto build for appsody project $projectName enabled"
# Disable auto build
elif [ "$COMMAND" == "disableautobuild" ]; then
	echo "Disabling auto build for appsody project $projectName"
	# $IMAGE_COMMAND exec $project /scripts/noderun.sh stop
	# $util updateAppState $PROJECT_ID $APP_STATE_STOPPING
	# $IMAGE_COMMAND exec $project /scripts/noderun.sh start false $START_MODE
	# $util updateAppState $PROJECT_ID $APP_STATE_STARTING
	echo "Auto build for appsody project $projectName disabled"
# Remove the application
elif [ "$COMMAND" == "remove" ]; then
	echo "Removing the container for app $ROOT."

	# if [ "$IN_K8" == "true" ]; then
	# 	helm delete $project --purge
	# else
		# Remove container
		$DIR/appsody stop --name $CONTAINER_NAME
		sleep 3

		if [ "$IN_K8" != "true" ]; then
			# Remove the deps volume, as it needs to be deleted separately.
			if [ "$($IMAGE_COMMAND volume ls -q -f name=$projectName-deps)" ]; then
				$IMAGE_COMMAND volume rm $projectName-deps
			fi
		fi
	# fi

	# Remove image
	# if [ "$($IMAGE_COMMAND images -qa -f reference=$project)" ]; then
	# 	$IMAGE_COMMAND rmi -f $project
	# else
	# 	echo The application image $project has already been removed.
	# fi
# Rebuild the application
elif [ "$COMMAND" == "rebuild" ]; then
	echo "Rebuilding project: $projectName"
	cleanContainer
	create
# Just return configuration information as last line of output
else
	knStack=`$DIR/scripts/get-stack.sh .appsody-config.yaml`
	echo -n "{ \"language\": \"$knStack\" }"
fi
