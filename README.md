# codewind-appsody-extension

[![License](https://img.shields.io/badge/License-EPL%202.0-red.svg?label=license&logo=eclipse)](https://www.eclipse.org/legal/epl-2.0/)
[![Build Status](https://ci.eclipse.org/codewind/buildStatus/icon?job=Codewind%2Fcodewind-appsody-extension%2Fmaster)](https://ci.eclipse.org/codewind/job/Codewind/job/codewind-appsody-extension/job/master/)
[![Chat](https://img.shields.io/static/v1.svg?label=chat&message=mattermost&color=145dbf)](https://mattermost.eclipse.org/eclipse/channels/eclipse-codewind)

This repository is an extension to Codewind that adds support for [Appsody](https://appsody.dev) projects.

## Installing the Appsody Extension on Codewind

Download the desired build from [Eclipse Downloads](https://archive.eclipse.org/codewind/codewind-appsody-extension/) and unzip the archive under the Codewind workspace's `.extensions` folder, i.e.

`/some_path/codewind-workspace/.extensions/codewind-appsody-extension`

Restart Codewind to pick up the new extension.

## Creating an Appsody Project

After installing the Appsody extension, the Appsody project templates will become available in Codewind, allowing you to create Appsody projects the same way you create other projects.

## Optional: Building the Full Application Image

1. Open a terminal into the Codewind server container:

   `docker exec -it codewind-pfe bash`
   
2. Run the following command, replacing *projectName* with the name of the project to build:

   `export APPSODY_MOUNT_PROJECT=$HOST_WORKSPACE_DIRECTORY/projectName`

3. Go into the project directory:

   `cd /codewind-workspace/projectName`
   
4. Run the command below. A docker image of the application will be built with the name *projectName*.

   `/codewind-workspace/.extensions/codewind-appsody-extension/appsody build`

## Current Limitations

- Enabling and disabling auto build in Codewind is not supported for Appsody projects.

## Contributing

Submit issues and contributions:

1. [Submitting issues](https://github.com/eclipse/codewind/issues)
2. [Contributing](CONTRIBUTING.md)
