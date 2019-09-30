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

            // not support on k8s at the moment, return empty list
            if (global.codewind && global.codewind.RUNNING_IN_K8S)
                return resolve([]);

            // list of repositories start on 3rd line
            exec(`${__dirname}/appsody repo list | tail -n+3`, (err, stdout) => {

                if (err)
                    return reject(err);

                const repos = [];

                stdout.split(os.EOL).forEach((line) => {

                    // split the line: <name> <url>
                    const pair = line.trim().split(/\s+/);
                    
                    // appsody uses index.yaml, change that to index.json
                    if (pair.length >= 2) {
                    
                        let name = pair[0];

                        // chop of the default repo indicator if present
                        if (name.startsWith('*'))
                            name = name.substring(1);

                        if (name != 'experimental' && pair[1].endsWith('index.yaml')) {

                            let url = pair[1];
                            url = url.substring(0, url.length - 10) + 'index.json';

                            repos.push({
                                description: `Appsody Stacks - ${name}`,
                                url: url
                            });
                        }
                    }
                });

                resolve(repos);
            });
        });
    },

    getProjectTypes: async function() {
        return new Promise((resolve, reject) => {

            // list of stacks start on 3rd line
            exec(`${__dirname}/appsody list | tail -n+3`, (err, stdout) => {

                if (err)
                    return reject(err);

                const projectTypes = [];
                let descStart;

                for (const line of stdout.split(os.EOL)) {
                    
                    // found header line, note where the description starts
                    if (line.startsWith('REPO')) {
                        descStart = line.indexOf('DESCRIPTION');
                        continue;
                    }

                    // haven't found the header line yet
                    if (!descStart)
                        continue;

                    // split the line: <repo> <id> <version> <templates> (leave <description> for later)
                    const cols = line.substring(0, descStart).split(/\s+/);
                    const repo = cols[0];

                    // check if it's a valid, non-experimental entry
                    if (cols.length < 4 || repo == 'experimental')
                        continue;

                    const stack = cols[1];

                    projectTypes.push({
                        projectType: 'appsodyExtension',
                        projectSubtypes: {
                            label: 'Appsody stack',
                            items: [{
                                id: `${repo}/${stack}`,
                                version: cols[2],
                                label: `Appsody ${stack}`,
                                description: line.substring(descStart).trimRight()
                            }]
                        }
                    });
                }

                resolve(projectTypes);
            });
        });
    }
}
