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

b="(.*\s)?"	# beginning arguments
e="(\s.*)?"	# ending arguments

q="['\"]?"	# optional single or double quote
s="[/\\]"	# path separator 

regex="^${b}-Dmaven\.repo\.local=${q}(.*)${s}.m2${s}repository${s}?${q}${e}$"

if [[ $HOST_MAVEN_OPTS =~ $regex ]]; then
	echo ${BASH_REMATCH[2]//\\/\\\\}
else
	echo $HOST_HOME
fi
