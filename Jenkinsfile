pipeline {
    agent none
    tools {
        maven 'mymaven' 
    }
    parameters{
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])

    }
    environment{
        DEV_SERVER='ec2-user@172.31.9.75'
    }
    stages {
        stage('Compile') {
            agent any
            steps {
                echo 'Compiling the code'
                echo "compiling in env: ${params.Env}"
                sh "mvn compile"

            }
        }
         stage('CodeReview') {
            agent any
            steps {
                echo 'Reviewing the code'
                echo "Deploying the app version ${params.APPVERSION}"
                sh "mvn pmd:pmd"
            }
            // post{
            //     always{
            //         pmd pattern: 'target/pmd.xml'
            //     }
            // }
        }
         stage('UniTest') {//slave1
           agent {label 'linux_slave'}
            when{
                expression{
                    params.executeTests == true
                }
            }
            
            steps {
                echo 'UnitTest the code'
                sh "mvn test"
            }
            post{
                always{
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }
        stage('CodeCoverage'){
            agent any
            steps{
                script{
                    echo "codereview with Jacoco"
                    sh "mvn verfiy"
                }
            }
        }

         stage('Package') {//slave2
            //agent {label 'linux_slave'}
            agent any
            steps {
                script{
                sshagent(['slave2']) {
                echo 'Package the code'
                echo "Deploying the app version ${params.APPVERSION}"
                sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER}:/home/ec2-user"
                sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER} 'bash /home/ec2-user/server-script.sh'"
            }
        }
            }
         }
          stage('Deploy') {
            agent any
            input{
                message "Select the platform to deploy"
                ok "Platform selected"
                parameters{
                    choice(name:'Platform',choices:['On-prem','EKS','EC2'])
                }
            }
            steps {
                echo 'Deploy the code'
                echo "Deploying the app version ${params.APPVERSION}"
                echo "Deploying on ${params.Platform}"
            }
        }
    }
}
