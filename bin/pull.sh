#!/usr/bin/env bash

set -e
set -o pipefail

default_appsody_version=0.4.6
default_appsody_controller_version=0.2.4

appsody_version=${APPSODY_VERSION}
appsody_controller_version=${APPSODY_CONTROLLER_VERSION}

download_appsody() {
    if [[ -z $appsody_version ]]; then
        appsody_version=$1
    fi

    if [[ -z $appsody_version ]]; then
        appsody_controller_version=$1
    fi

    if [[ -z $appsody_version ]]; 
        then
            appsody_version=${default_appsody_version}
            echo "\$APPSODY_VERSION is not set in enviroment, downloading default version ${default_appsody_version}"
    fi

    if [[ -z $appsody_controller_version ]]; 
        then
            appsody_controller_version=${default_appsody_controller_version}
            echo "\$APPSODY_CONTROLLER_VERSION is not set in enviroment, downloading default version ${default_appsody_controller_version}"
    fi
    
    appsody_download_base_url="https://github.com/appsody/appsody/releases/download/${appsody_version}"
    appsody_controller_download_url="https://github.com/appsody/controller/releases/download/${appsody_controller_version}"
    
    appsody_filename="appsody-${appsody_version}-linux-amd64.tar.gz"
    appsody_controller_filename="appsody-controller"
    appsody_download_url="${appsody_download_base_url}/${appsody_filename}"
    appsody_controller_download_url="${appsody_controller_download_url}/${appsody_controller_filename}"

    echo "Downloading Appsody version ${appsody_version}"
    curl -fsSL $appsody_download_url -o $appsody_filename

    echo "Downloading Appsody controller version ${appsody_controller_version}"
    curl -fsSL $appsody_controller_download_url -o $appsody_controller_filename

    tar xzf $appsody_filename "appsody"
    rm -rf $appsody_filename
    echo "Successfully downloaded Appsody version ${appsody_version}"

    chmod +x $appsody_controller_filename
    echo "Successfully downloaded Appsody controller version $appsody_controller_version"

}

download_appsody_latest() {
    echo "\$APPSODY_VERSION is not set in enviroment, downloading latest release"
    latest_release=$(curl -s https://github.com/appsody/appsody/releases/latest)
    latest_version=$(echo $ latest_release | grep -o 'tag/[v.0-9]*' | cut -d/ -f2)
    echo "Latest appsody release version: ${latest_version}"  
    echo "Downloading Appsody version ${latest_version}"
    curl -fsSL "https://github.com/appsody/appsody/releases/download/${latest_version}/appsody-${latest_version}-linux-amd64.tar.gz" -o "appsody-${latest_version}-linux-amd64.tar.gz"
    tar xzf "appsody-${latest_version}-linux-amd64.tar.gz" "appsody"
    rm -rf "appsody-${latest_version}-linux-amd64.tar.gz"
    echo "Successfully downloaded Appsody version ${latest_version}"
}

download_appsody