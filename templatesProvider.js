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

            // list of repositories start on 3rd line
            exec(`${__dirname}/appsody repo list | tail -n+3`, (err, stdout) => {

                if (err)
                    return reject(err);

                const repos = [];

                stdout.split(os.EOL).forEach((line) => {

                    // split the line: <name> <url>
                    const pair = line.trim().split(/\s+/);
                    
                    // appsody uses index.yaml, change that to index.json
                    if (pair.length >= 2 && pair[1].endsWith('index.yaml')) {

                        let url = pair[1];
                        url = url.substring(0, url.length - 10) + 'index.json';

                        repos.push({
                            description: pair[0],
                            url: url
                        });
                    }
                });

                resolve(repos);
            });
        });
    }
}
