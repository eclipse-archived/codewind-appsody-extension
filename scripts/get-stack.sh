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

if grep --quiet "nodejs" $1; then
	echo nodejs-default
elif grep --quiet "java-spring-boot2:" $1; then
	echo java-spring
elif grep --quiet "quarkus" $1; then
	echo java-spring
elif grep --quiet "java" $1; then
	echo java-default
fi
