# codewind-appsody-extension

[![License](https://img.shields.io/badge/license-Eclipse-brightgreen.svg)](https://www.eclipse.org/legal/epl-2.0/)
[![Chat](https://img.shields.io/static/v1.svg?label=chat&message=mattermost&color=145dbf)](https://mattermost.eclipse.org/eclipse/channels/eclipse-codewind)

This repository is an extension to Codewind that adds support for [Appsody](https://appsody.dev) projects.

- Appsody version: [0.3.0](https://github.com/appsody/appsody/releases/tag/0.3.0)
- Appsody controller version: [0.2.2](https://github.com/appsody/controller/releases/tag/0.2.2)

## Installing the Appsody Extension on Codewind

Download the latest [release](https://github.com/eclipse/codewind-appsody-extension/releases) and unzip or untar it to a folder named `appsodyExtension` under the Codewind workspace's `.extensions` folder, i.e.

`/some_path/codewind-workspace/.extensions/appsodyExtension`

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

   `/codewind-workspace/.extensions/appsodyExtension/appsody build`

## Optional: Using the Same Appsody Configuration Between Local CLI and Codewind

If you have a local install of the Appsody CLI, you can configure it to use the same configuration as Codewind.

1. Open the `.appsody.yaml` configuration file that the Appsody CLI is using in an editor (by default, this file is located in your home directory, under the `.appsody` folder, but this can be changed via Appsody's [`--config`](https://appsody.dev/docs/using-appsody/cli-commands) flag)

2. Change the `home` property to point the Codewind's copy of the Appsody configuration

   `home: /some_path/codewind-workspace/.appsody`

## Current Limitations

- Enabling and disabling auto build in Codewind is not supported for Appsody projects.
- Appsody is supported on Codewind on VS Code and on Eclipse, but not on Eclipse Che at this time.

## Contributing

Submit issues and contributions:

1. [Submitting issues](https://github.com/eclipse/codewind-appsody-extension/issues)
2. [Contributing](CONTRIBUTING.md)
