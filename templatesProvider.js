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
            
            exec(`${__dirname}/appsody list`, (err, stdout) => {

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
                    let repo = cols[0];

                    // chop of the default repo indicator if present
                    if (repo.startsWith('*'))
                        repo = repo.substring(1);

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
