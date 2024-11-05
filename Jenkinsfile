pipeline {
   agent none
   tools{
//     jdk "myjava"
        maven "mymaven"
   }

   environment{
    DEV_SERVER_IP='ec2-user@172.31.10.177'
    //DEPLOY_SERVER_IP='ec2-user@172.31.11.81'
    IMAGE_NAME='devopstrainer/java-mvn-privaterepos:$BUILD_NUMBER'
    ACM_IP='ec2-user@172.31.9.150'
    AWS_ACCESS_KEY_ID=credentials('ACCESS_KEY')
    AWS_SECRET_ACCESS_KEY=credentials('SECRET_ACCESS_KEY')
    DOCKER_REG_PASSWORD=credentials("DOCKER_REG_PASSWORD")
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
                    sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER_IP} 'bash ~/server-script.sh ${IMAGE_NAME}'"
                    sh "ssh ${DEV_SERVER_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                    sh "ssh ${DEV_SERVER_IP} sudo docker push ${IMAGE_NAME}"

                   }
              }
               }
            }
        }
        stage('Provision the infra'){
            agent any
            steps{
                script{
                    dir('terraform'){
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                        EC2_PUBLIC_IP= sh (
                            script: "terraform output ec2-ip",
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
          stage('Deploy with ansible') {//slave2 -- /var/lib/jenkins/workspace
        //agent {label 'linux_slave'}
       
        when{
            expression{
                BRANCH_NAME == 'tf-cicd'
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
                  sshagent(['slave2']) {//ssh into ACM
                    echo "waiting for ec2 instance to intialise"
                    sleep(time:90,unit: "SECONDS")
                    echo "${EC2_PUBLIC_IP}"
                    //withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                    echo "Package the code ${params.APPVERSION}"
                    sh "scp -o StrickHostKeyChecking=no ansible/* ${ACM_IP}:/home/ec2-user"

                    // sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} sudo yum install docker -y"
                    // sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo systemctl start docker"
                    // sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                    // sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker run -itd -p 8080:8080 ${IMAGE_NAME}:${BUILD_NUMBER}"
                    withCredentials([sshUserPrivateKey(credentialsId: 'ansible_target',keyFileVariable: 'keyfile',usernameVariable: 'user')]){ 
                    sh "scp -o StrictHostKeyChecking=no $keyfile ${ACM_IP}:/home/ec2-user/.ssh/id_rsa"    
                    }
                    sh "ssh -o StrictHostKeyChecking=no ${ACM_IP} bash /home/ec2-user/ansible-config.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${DOCKER_REG_PASSWORD} ${IMAGE_NAME}"

            }
            }
            }
            }
            }
}