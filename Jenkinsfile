pipeline {
    agent none

    tools{
        maven 'mymaven'
    }

    parameters{
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])
    }
     environment{
        BUILD_SERVER='ec2-user@172.31.14.32'  (creating manually)
       // DEPLOY_SERVER='ec2-user@172.31.4.216' (creating wth terraform)
        IMAGE_NAME='devopstrainer/addbook:$BUILD_NUMBER'
     }
    stages {
        stage('Compile') {
            agent any
            steps {
                script{
                    //  sshagent(['slave2']) {
                    echo 'Package Hello World'
                echo "Compiling version ${params.APPVERSION}"
                // sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                // sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'bash ~/server-script.sh'"
                sh "mvn compile"
                //}
                }
            }
        }
        stage('UnitTest') {
            agent any
              when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                script{
                    echo 'Run UnitTest cases for  Hello World'
                    sh 'mvn test'
                }
                
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('CodeReview') {
            //agent {label 'linux_slave'}
            agent any
            steps {
                script{
                    echo 'CodeReview Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn pmd:pmd"
                }
            }
        }
        stage('CodeCoverage') {
            agent any
            steps {
                script{
                    echo 'Coverage Analysis Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn verify"
                }
            }
        }
        // stage('Package') {
        //     agent any
           
        //     steps {
        //         script{
        //              echo 'Packaging Hello World'
        //             echo "packagin in ${params.Env} environment"
        //             sh "mvn package"
                
        //     }
        // }
        // }
        // stage('PublishtoJfrog') {
        //     agent any
        //     input{
        //         message "Archive the artifact"
        //         ok "Platform selected"
        //         parameters{
        //             choice(name:'Platform',choices:['Nexus','Jfrog'])
        //         }
        //     }
        //     steps {
        //         script{
        //             echo 'Publish to Jfrog'
        //             echo "Deploying in ${params.Env} environment"
        //             sh "mvn -U deploy -s settings.xml"
        //         }
        //     }
        // }
        stage('Dockerize the app and push the image'){//on build server
            agent any
            steps{
                script{
                    sshagent(['slave2']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        echo "Containerising the code and pushing the image"
                         sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                         sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                        // sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'docker build -t ${IMAGE_NAME} .'"
                        sh "ssh ${BUILD_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}"
                        //sh "ssh ${BUILD_SERVER} sudo docker run -itd -P ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
        stage('Provision deploy server with terraform'){
            agent any
            steps {
                script {
                    echo 'Provisioning the deploy server with Terraform'
                    dir('terraform') {
                        // Assuming the Terraform files are in a directory named 'terraform'
                        sh 'terraform init'
                        sh 'terraform apply -auto-approve'
                        EC2_PUBLIC_IP = sh(script: 'terraform output -raw ec2_public_ip', returnStdout: true).trim()
                    }
                }
            }
        }
        stage('Test/deploy the docker image'){//on deploy server
            agent any
            steps{
                script{
                    sshagent(['slave2']) {
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        echo "Running the Container for testing"
                        //  sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                        //  sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                        // sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} 'docker build -t ${IMAGE_NAME} .'"
                        sh "ssh -o StrictHostKeyChecking=no ec2-user@${EC2_PUBLIC_IP} sudo yum install -y docker"
                        sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo service docker start"
                        sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "ssh ec2-user@${EC2_PUBLIC_IP} sudo docker run -itd -P ${IMAGE_NAME}"
                        }
                    }
                }
            }
        }
    }
}

