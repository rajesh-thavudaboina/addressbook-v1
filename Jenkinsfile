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
                echo "compiling in env: ${params.ENV}"
            }
        }
         stage('UniTest') {
            steps {
                echo 'UnitTest the code'
            }
        }
         stage('Package') {
            steps {
                echo 'Package the code'
                echo "Deploying the app version ${params.APPVERSION}"
            }
        }
    }
}
