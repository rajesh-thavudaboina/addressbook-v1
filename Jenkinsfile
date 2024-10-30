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
                echo 'Compiling the code'
                echo "compiling in env: ${params.Env}"
                sh "mvn compile"

            }
        }
         stage('CodeReview') {
            steps {
                echo 'Reviewing the code'
                echo "Deploying the app version ${params.APPVERSION}"
                sh "mvn pmd:pmd"
            }
        }
         stage('UniTest') {
            when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                echo 'UnitTest the code'
                sh "mvn test"
            }
        }

         stage('Package') {
            steps {
                echo 'Package the code'
                echo "Deploying the app version ${params.APPVERSION}"
                sh "mvn package"
            }
        }
          stage('Deploy') {
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
