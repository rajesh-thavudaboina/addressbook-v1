pipeline {
   agent none
   tools{
//     jdk "myjava"
        maven "mymaven"
   }

   environment{
    DEV_SERVER_IP='ec2-user@172.31.0.118'
    //DEPLOY_SERVER_IP='ec2-user@172.31.11.81'
    IMAGE_NAME='devopstrainer/java-mvn-privaterepos'
    // ACCESS_KEY=credentials('ACCESS_KEY')
    // SECRET_ACCESS_KEY=credentials('SECRET_ACCESS_KEY')
     GIT_CREDENTIALS_ID = 'GITHUB1' // The username-password type ID of the Jenkins credentials
    GIT_USERNAME = 'preethid'
    GIT_EMAIL = 'preethi@example.com'
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
        //   stage('Deploy') {//slave2 -- /var/lib/jenkins/workspace
        // //agent {label 'linux_slave'}
       
        // when{
        //     expression{
        //         BRANCH_NAME == 'docker-1'
        //     }
        // }
        // agent any
        //    input{
        //     message "Select the version to deploy"
        //     ok "version selected"
        //     parameters{
        //         choice(name:'NEWAPP',choices:['1.2','2.1','3.1'])
        //     }
        //    }
        //     steps {
        //           script{
        //           sshagent(['slave2']) {
        //             withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
        //             echo "Package the code ${params.APPVERSION}"
        //             sh "ssh ${DEPLOY_SERVER_IP} sudo yum install docker -y"
        //             sh "ssh ${DEPLOY_SERVER_IP} sudo systemctl start docker"
        //             sh "ssh ${DEPLOY_SERVER_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
        //             sh "ssh ${DEPLOY_SERVER_IP} sudo docker run -itd -p 9991:8080 ${IMAGE_NAME}:${BUILD_NUMBER}"

        //            }
        //       }
        //        }
        // }}
        stage("Deploy on EKS with argocd"){
            agent any
            steps{
                script{
                    echo "Deploy on EKS cluster"
                    // sh 'aws --version'
                    // sh 'aws configure set aws_access_key_id ${ACCESS_KEY}'
                    // sh 'aws configure set aws_secret_access_key ${SECRET_ACCESS_KEY}'
                    // sh 'aws eks update-kubeconfig --region ap-south-1 --name myeks2'
                    // sh 'kubectl get nodes'
                    withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USER')]) {
                    sh "git config user.email ${GIT_EMAIL}"
                    sh "git config user.name ${GIT_USERNAME}"
                    sh 'envsubst < java-mvn-app-var.yml > k8s-manifests/java-mvn-app.yml'
                    sh 'git add k8s-manifests/java-mvn-app.yml'
                    sh "git commit -m 'Triggered Build:${env.BUILD_NUMBER}'"
                    sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/preethid/addressbook-v1.git HEAD:argocd-1"
                      }
                }
            }
        }
                  

                   }
              }
               