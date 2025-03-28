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
        BUILD_SERVER='ec2-user@172.31.9.33'
        IMAGE_NAME='devopstrainer/java-mvn-privaterepos'
        DEPLOY_SERVER='ec2-user@172.31.10.182'
        ACCESS_KEY=credentials('aws_access_key_id')
        SECRET_ACCESS_KEY=credentials('aws_secret_access_key')
         GIT_CREDENTIALS_ID = 'GIT_CREDENTIALS_ID' // The username-password type ID of the Jenkins credentials
    GIT_USERNAME = 'preethid'
    GIT_EMAIL = 'preethi@example.com'
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                script{
                echo "Compiling the code in ${params.Env}"
                sh "mvn compile"
            }
            }
        }
        stage('CodeReview') {
            agent any
            steps {               
                script{
                 echo 'Reviewing the code with pmd'
                sh "mvn pmd:pmd"
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
                 echo 'Testing the code with junit'
                sh "mvn test"
            }
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('CoverageAnalysis') {
           // agent {label 'linux_slave_aws'}
           agent any
            steps {  
                script{
                 echo 'Static Code Coverage with jacoco'
                sh "mvn verify"
            }
            }
        }
        stage('Dockerize and push the image to dockerhub') {
            agent any
            steps {
               script{
                sshagent(['slave2']) {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                echo "Packaging the code ${params.APPVERSION}"
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${BUILD_SERVER}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${BUILD_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME} ${BUILD_NUMBER}"
                sh "ssh ${BUILD_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                sh "ssh ${BUILD_SERVER} sudo docker push ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
                }
            }
            }
        }
        // stage('Publish the war to jfrog') {
        //     agent any
        //     steps {  
        //     script{
        //         echo 'publishing the artifact to jfrog'
        //         sh "mvn -U deploy -s settings.xml"
        //     }
        //     }
        // }
        stage('Deploy the image to deploy server in Staging env') {
            agent any
            steps {
               script{
                sshagent(['slave2']) {//deploy server as jenkins slave   //ACM is jenkins slave--ansible-playbook--deployservers
                withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                echo "Packaging the code ${params.APPVERSION}"
                // sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEPLOY_SERVER}:/home/ec2-user"
                // sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} bash /home/ec2-user/server-script.sh ${IMAGE_NAME}"
                sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo yum install docker -y"
                sh "ssh -o StrictHostKeyChecking=no ${DEPLOY_SERVER} sudo systemctl start docker"
                sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                sh "ssh ${DEPLOY_SERVER} sudo docker run -itd -P ${IMAGE_NAME}:${BUILD_NUMBER}"
                }
                }
            }
            }
        }
         stage('Deploy on k8s cluster') {
            agent any
             input{
                 message "Select the platform to deploy"
                ok "platform selected"
                parameters{
                    choice(name:'NEWAPP',choices:['EKS','Ec2','on-premise'])
                }
            }
            steps {
               script{
               
                // sh 'aws configure set aws_access_key_id ${ACCESS_KEY}'
                // sh 'aws configure set aws_secret_access_key ${SECRET_ACCESS_KEY}'
                // sh 'aws eks update-kubeconfig --region ap-south-1 --name myeks'
                // sh "kubectl get nodes"
                // sh "envsubst < k8s-manifests/java-mvn-app.yml | kubectl apply -f -"
                // sh "kubectl get all"                
                withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", passwordVariable: 'GIT_TOKEN', usernameVariable: 'GIT_USER')]) {
                        sh 'envsubst < java-mvn-app-var.yml > k8s-manifests/java-mvn-app.yml'
                        sh "git config user.email ${GIT_EMAIL}"
                        sh "git config user.name ${GIT_USERNAME}"
                        sh "git add k8s-manifests/java-mvn-app.yml"
                        sh "git commit -m 'Triggered Build: ${env.BUILD_NUMBER}'"
                        sh "git push https://${GIT_USER}:${GIT_TOKEN}@github.com/preethid/addressbook-v1.git HEAD:argocd-demo"
                    }
                }
                }
            }           
        }
}