pipeline {
   agent none
   tools{
//     jdk "myjava"
        maven "mymaven"
   }

   environment{
    DEV_SERVER_IP='ec2-user@172.31.9.12'
    DEPLOY_SERVER_IP='ec2-user@172.31.11.81'
    IMAGE_NAME='devopstrainer/java-mvn-privaterepos'
   }

   parameters{
        string(name:'Env',defaultValue:'Test',description:'Environment to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])

   }
    stages {
        stage('Compile') { //slave1 --- /tmp/workspace
        // agent {label 'linux_slave'}
        agent any
            steps {
                echo "Compile the code in ${params.Env}"
                sh "mvn compile"
            }
        }
         stage('UnitTest') { //slave1 -- /tmp/workpscae
         when{
            expression{
                params.executeTests == true 
            }
         }
          agent any
            steps {
                echo "Test the code"
                sh "mvn test"
            }
            post{
                always{
                     junit 'target/surefire-reports/*.xml'
                }
            }
        }
         stage('Package+push the image to registry') {//slave2 -- /var/lib/jenkins/workspace
        //agent {label 'linux_slave'}
        // when{
        //     expression{
        //         BRANCH_NAME == 'docker-1'
        //     }
        // }
        agent any
        //    input{
        //     message "Select the version to deploy"
        //     ok "version selected"
        //     parameters{
        //         choice(name:'NEWAPP',choices:['1.2','2.1','3.1'])
        //     }
        //    }
            steps {
                  script{
                  sshagent(['slave2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    echo "Package the code ${params.APPVERSION}"
                    sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER_IP}:/home/ec2-user"
                    sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER_IP} 'bash ~/server-script.sh ${IMAGE_NAME} ${BUILD_NUMBER}'"
                    sh "ssh ${DEV_SERVER_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                    sh "ssh ${DEV_SERVER_IP} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"

                   }
              }
               }
            }
        }
          stage('Deploy') {//slave2 -- /var/lib/jenkins/workspace
        //agent {label 'linux_slave'}
       
        when{
            expression{
                BRANCH_NAME == 'docker-1'
            }
        }
        agent any
           input{
            message "Select the version to deploy"
            ok "version selected"
            parameters{
                choice(name:'NEWAPP',choices:['1.2','2.1','3.1'])
            }
           }
            steps {
                  script{
                  sshagent(['slave2']) {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    echo "Package the code ${params.APPVERSION}"
                    sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEPLOY_SERVER_IP}:/home/ec2-user"
                    sh "ssh ${DEPLOY_SERVER_IP} sudo yum install docker -y"
                    sh "ssh ${DEPLOY_SERVER_IP} sudo systemctl start docker"
                    sh "ssh ${DEV_SERVER_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                    sh "ssh ${DEPLOY_SERVER_IP} sudo docker run -itd ${IMAGE_NAME}:${BUILD_NUMBER}"

                   }
              }
               }
        }}
                  

                   }
              }
               