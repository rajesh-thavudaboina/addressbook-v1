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
                script{
                    echo 'Compile Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn compile"
                }
            }
        }
        stage('UnitTest') {
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
        }
        stage('CodeReview') {
            steps {
                script{
                    echo 'Compile Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn pmd:pmd"
                }
            }
        }
        stage('CodeCoverage') {
            steps {
                script{
                    echo 'Compile Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn verify"
                }
            }
        }
        stage('Package') {
            steps {
                script{
                    echo 'Package Hello World'
                echo "Packaging version ${params.APPVERSION}"
                sh 'mvn package'
                }
                
            }
        }
        stage('PublishtoJfrog') {
            steps {
                script{
                    echo 'Compile Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn -u deploy -s settings.xml"
                }
            }
        }
    }
}

