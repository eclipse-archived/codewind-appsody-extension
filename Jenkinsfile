#!groovy​

pipeline {
    agent any
    
    options {
        timestamps() 
        skipStagesAfterUnstable()
    }

    stages {
        stage('Build') {
            steps {
                script {
                    println("Starting codewind-appsody-extension build ...")
                    sh '''
                        export OUTPUT_NAME="codewind-appsody-extension"
                        
                        cd bin
                        ./pull.sh
                        cd ..
                        rm -rf .git
                        rm -rf .github
                        rm .gitignore
                        rm Jenkinsfile
                        zip $OUTPUT_NAME.zip -9 -r ./
                    '''
                }
            }
        } 
        
        stage('Deploy') {
            steps {
                sshagent ( ['projects-storage.eclipse.org-bot-ssh']) {
                    println("Deploying ccodewind-appsody-extension to downoad area...")
                  
                    sh '''
                        export REPO_NAME="codewind-appsody-extension"
                        export OUTPUT_NAME="codewind-appsody-extension"
                        export OUTPUT_DIR="$WORKSPACE/output"
                        export DOWNLOAD_AREA_URL="https://download.eclipse.org/codewind/$REPO_NAME"
                        export LATEST_DIR="latest"
                        export BUILD_INFO="build_info.properties"
                        export sshHost="genie.codewind@projects-storage.eclipse.org"
                        export deployDir="/home/data/httpd/download.eclipse.org/codewind/$REPO_NAME"
                    
                        mkdir $mkdir $OUTPUT_DIR
                        
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
