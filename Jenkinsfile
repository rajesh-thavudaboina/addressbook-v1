pipeline {
    agent any

    parameters{
        string(name:'Env',defaultValue:'Test',description:'version to deploy')
        booleanParam(name:'executeTests',defaultValue: true,description:'decide to run tc')
        choice(name:'APPVERSION',choices:['1.1','1.2','1.3'])
    }


    stages {
        stage('Compile') {
            steps {
                echo "Compiling the code in ${params.Env}"
            }
        }
        stage('CodeReview') {
            steps {
                echo 'Reviewing the code with pmd'
            }
        }
        stage('UnitTest') {
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                echo 'Testing the code with junit'
            }
        }
        stage('CoverageAnalysis') {
            steps {
                echo 'Static Code Coverage with jacoco'
            }
        }
        stage('Package') {
            steps {
                echo "Packaging the code ${params.APPVERSION}"
            }
        }
        stage('Publish') {
            input{
                 message "Select the platform to deploy"
                ok "platform selected"
                parameters{
                    choice(name:'NEWAPP',choices:['EKS','Ec2','on-premise'])
                }
            }
            steps {
                echo 'publishing the artifact to jfrog'
            }
        }
    }
}
