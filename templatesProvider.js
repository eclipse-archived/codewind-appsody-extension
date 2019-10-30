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

const { promisify } = require('util');
const exec = promisify(require('child_process').exec);

module.exports = {

    canHandle: function(repository) {
        return repository.projectStyles.includes('Appsody');
    },
    
    addRepository: async function(repository) {
        
        // no-op
        if (!repository.url.endsWith('index.json'))
            return;

        let url = repository.url;
        url = url.substring(0, url.length - 10) + 'index.yaml';

        await exec(`${__dirname}/appsody repo add ${repository.id} ${url}`);
    },

    removeRepository: async function(repository) {
        await exec(`${__dirname}/appsody repo remove ${repository.id}`);
    },

    getRepositories: async function() {
        
        const repos = [];
            
        const result = await exec(`${__dirname}/appsody repo list -o json`);
        const json = JSON.parse(result.stdout);

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

        return repos;
    },

    getProjectTypes: async function(id) {

        const projectTypes = [];

        const result = await exec(`${__dirname}/appsody list -o json`);
        const json = JSON.parse(result.stdout);

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

        return projectTypes;
    }
}
