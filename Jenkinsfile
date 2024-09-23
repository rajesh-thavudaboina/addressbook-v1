pipeline {
   agent none
   tools{
//     jdk "myjava"
        maven "mymaven"
   }
   environment{
    DEV_SERVER_IP='ece2-user@172.31.1.95'
   }
   parameters{
        string(name:'Env',defaultValue:'Test',description:'Environment to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])

   }
    stages {
        stage('Compile') { //prod
        agent any
            steps {
                echo "Compile the code in ${params.Env}"
                sh "mvn compile"
            }
        }
         stage('UnitTest') { //test
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
         stage('Package') {//dev
        //agent {label 'linux_slave'}
        when{
            expression{
                BRANCH_NAME == 'b1'
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
                     echo "Package the code ${params.APPVERSION}"
                   sh "scp -o StrictHostKeyChecking=no server-script.sh ${DEV_SERVER_IP}:/home/ec2-user"
                  sh "ssh -o StrictHostKeyChecking=no ${DEV_SERVER_IP} 'bash ~/server-script.sh'"
                   }
              }
               }
        }
    }
}
