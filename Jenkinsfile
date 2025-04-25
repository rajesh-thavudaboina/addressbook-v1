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
                echo 'Compile Hello World'
                echo "Deploying in ${params.Env} environment"
            }
        }
        stage('UnitTest') {
              when{
                expression{
                    params.executeTests == true
                }
            }
            steps {
                echo 'Run UnitTest cases for  Hello World'
            }
        }
        stage('Package') {
            steps {
                echo 'Package Hello World'
                echo "Packaging version ${params.APPVERSION}"
            }
        }
    }
}

