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
                    echo 'Compile Hello World'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn compile"
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
            agent {label 'linux_slave'}
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
        stage('Package') {
            agent any
            steps {
                script{
                    echo 'Package Hello World'
                echo "Packaging version ${params.APPVERSION}"
                sh 'mvn package'
                }
                
            }
        }
        stage('PublishtoJfrog') {
            agent any
            input{
                message "Archive the artifact"
                ok "Platform selected"
                parameters{
                    choice(name:'Platform',choices:['Nexus','Jfrog'])
                }
            }
            steps {
                script{
                    echo 'Publish to Jfrog'
                    echo "Deploying in ${params.Env} environment"
                    sh "mvn -U deploy -s settings.xml"
                }
            }
        }
    }
}

