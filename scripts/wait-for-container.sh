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

CONTAINER_NAME=$1
COUNT=0

# wait until container exists (20 mins max)
if [ "$IN_K8" == "true" ]; then
	until [ "$(kubectl get pods --selector=release=$CONTAINER_NAME 2> /dev/null | grep 'Running')" -o $((COUNT++)) -eq 40 ]; do
		sleep 30;
	done
else
	until [ "$(docker ps -aq -f name=$CONTAINER_NAME)" -o $((COUNT++)) -eq 40 ]; do
		sleep 30;
	done
fi
