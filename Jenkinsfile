#!groovy​

pipeline {
    agent any
    
    options {
        timestamps() 
        skipStagesAfterUnstable()
    }

    stages {
        stage('Build') {
            // This when clause disables Tagged build
            when {
                beforeAgent true
                not {
                    buildingTag()
                }
            }
            
            steps {
                script {
                    println("Starting codewind-appsody-extension build ...")
                    sh '''#!/usr/bin/env bash
                        export DIR=`pwd`
                        export REPO_NAME="codewind-appsody-extension"
                        if [ $GIT_BRANCH == "master" ]; then
                            export VERSION="9.9.9999"
                        else
                            export VERSION="$GIT_BRANCH"
                        fi
                        export OUTPUT_NAME="$REPO_NAME-$VERSION"

                        cd bin
                        ./pull.sh
                        cd ..
                        rm -rf .git .github .gitignore Jenkinsfile
                        mkdir $OUTPUT_NAME
                        # move everything inside output folder, suppress error about moving output folder inside itself
                        mv * .* $OUTPUT_NAME 2> /dev/null
                        zip $OUTPUT_NAME.zip -9 -r $OUTPUT_NAME
                    '''
                }
            }
        } 
        
        stage('Deploy') {
            // This when clause disables Tagged build
            when {
                beforeAgent true
                not {
                    buildingTag()
                }
            }
            
            steps {
                sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
                    println("Deploying codewind-appsody-extension to downoad area...")
                  
                    sh '''#!/usr/bin/env bash
                        export REPO_NAME="codewind-appsody-extension"
                        if [ $GIT_BRANCH == "master" ]; then
                            export VERSION="9.9.9999"
                        else
                            export VERSION="$GIT_BRANCH"
                        fi
                        export OUTPUT_NAME="$REPO_NAME-$VERSION"
                        export OUTPUT_DIR="$WORKSPACE/output"
                        export DOWNLOAD_AREA_URL="https://download.eclipse.org/codewind/$REPO_NAME"
                        export LATEST_DIR="latest"
                        export BUILD_INFO="build_info.properties"
                        export sshHost="genie.codewind@projects-storage.eclipse.org"
                        export deployDir="/home/data/httpd/download.eclipse.org/codewind/$REPO_NAME"
                    
                        mkdir $OUTPUT_DIR
                        
                        # if not a pull request build, copy it to 'latest' directory
                        if [ -z $CHANGE_ID ]; then
                            UPLOAD_DIR="$GIT_BRANCH/$BUILD_ID"
                            BUILD_URL="$DOWNLOAD_AREA_URL/$UPLOAD_DIR"
                  
                            ssh $sshHost rm -rf $deployDir/$GIT_BRANCH/$LATEST_DIR
                            ssh $sshHost mkdir -p $deployDir/$GIT_BRANCH/$LATEST_DIR
                            
                            scp $OUTPUT_NAME.zip $sshHost:$deployDir/$GIT_BRANCH/$LATEST_DIR/$OUTPUT_NAME.zip
                        
                            echo "# Build date: $(date +%F-%T)" >> $BUILD_INFO
                            echo "build_info.url=$BUILD_URL" >> $BUILD_INFO
                            SHA1=$(sha1sum ${OUTPUT_NAME}.zip | cut -d ' ' -f 1)
                            echo "build_info.SHA-1=${SHA1}" >> $BUILD_INFO
                            
                            scp $BUILD_INFO $sshHost:$deployDir/$GIT_BRANCH/$LATEST_DIR/$BUILD_INFO
                            rm $BUILD_INFO
                        else
                            UPLOAD_DIR="pr/$CHANGE_ID/$BUILD_ID"
                        fi
                        
                        ssh $sshHost rm -rf $deployDir/${UPLOAD_DIR}
                        ssh $sshHost mkdir -p $deployDir/${UPLOAD_DIR}
                        scp $OUTPUT_NAME.zip $sshHost:$deployDir/${UPLOAD_DIR}
                    '''
                }
            }
        }
    }    
}
