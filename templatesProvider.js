/*******************************************************************************
 * 
 * Copyright (c) 2019 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 *
 * Contributors:
 *     IBM Corporation - initial API and implementation
 * 
 *******************************************************************************/

'use strict';

const { exec } = require('child_process');
const os = require('os');

module.exports = {

    getRepositories: async function() {
        return new Promise((resolve, reject) => {
            
            exec(`${__dirname}/appsody repo list -o json`, (err, stdout) => {

                if (err)
                    return reject(err);

                const repos = [];
                const json = JSON.parse(stdout);

                for (const repo of json.repositories) {

                    const name = repo.name;
                    let url = repo.url;

                    if (name != 'experimental' && url.endsWith('index.yaml')) {

                        url = url.substring(0, url.length - 10) + 'index.json';

                        repos.push({
                            id: name,
                            name: `Appsody Stacks - ${name}`,
                            description: 'Use Appsody in Codewind to develop applications with sharable technology stacks.',
                            url
                        });
                    }
                }

                resolve(repos);
            });
        });
    },

    getProjectTypes: async function() {
        return new Promise((resolve, reject) => {
            
            exec(`${__dirname}/appsody list -o json`, (err, stdout) => {

                if (err)
                    return reject(err);

                const projectTypes = [];
                const json = JSON.parse(stdout);

                for (const repo of json.repositories) {

                    if (repo.repositoryName == 'experimental')
                        continue;

                    for (const stack of repo.stacks) {

                        projectTypes.push({
                            projectType: 'appsodyExtension',
                            projectSubtypes: {
                                label: 'Appsody stack',
                                items: [{
                                    id: `${repo.repositoryName}/${stack.id}`,
                                    version: stack.version,
                                    label: `Appsody ${stack.id}`,
                                    description: stack.description
                                }]
                            }
                        });
                    }
                }

                resolve(projectTypes);
            });
        });
    }
}
