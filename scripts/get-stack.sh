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

stack=$1

if [[ $stack =~ "nodejs" ]]; then
	echo nodejs-default
elif [[ $stack =~ "liberty" ]]; then
	echo java-default
elif [[ $stack =~ "spring" ]]; then
	echo java-spring
elif [[ $stack =~ "quarkus" ]]; then
	echo java-spring
elif [[ $stack =~ "java" ]]; then
	echo java-default
elif [[ $stack =~ "python" ]]; then
	echo python-default
elif [[ $stack =~ "kitura" ]]; then
	echo swift-default
fi
