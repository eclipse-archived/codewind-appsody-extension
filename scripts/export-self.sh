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

PFE_LABEL="app=codewind-pfe,codewindWorkspace=$CHE_WORKSPACE_ID"

export CODEWIND_OWNER_NAME=`kubectl get rs --selector=$PFE_LABEL -o jsonpath='{.items[0].metadata.name}'`
export CODEWIND_OWNER_UID=`kubectl get rs --selector=$PFE_LABEL -o jsonpath='{.items[0].metadata.uid}'`
