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

# wait until container exists (5 mins max)
until [ "$(docker ps -aq -f name=$CONTAINER_NAME)" -o $((COUNT++)) -eq 10 ]; do
	sleep 30;
done

# docker network disconnect bridge $CONTAINER_NAME
# docker network connect codewind_network $CONTAINER_NAME
