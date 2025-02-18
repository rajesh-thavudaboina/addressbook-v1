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
            agent {label 'linux_slave_aws'}
            steps {  
                script{
                 echo 'Static Code Coverage with jacoco'
                sh "mvn verify"
            }
            }
        }
        stage('Package') {
            agent any
            steps {
               script{
                 echo "Packaging the code ${params.APPVERSION}"
                sh "mvn package"
            }
            }
        }
        stage('Publish') {
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
                echo 'publishing the artifact to jfrog'
                sh "mvn -U deploy -s settings.xml"
            }
            }
        }
    }
}
