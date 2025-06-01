pipeline{
  agent none
  tools {
    maven "maven3.9"
  }
  parameters{
    string(name:'Env',defaultValue:'Test',description:'version to deploy')
    booleanParam(name:'executeTests',defaultValue:true ,description:'decide to run it')
    choice(name:'AppVersion',choices:['1','2','3'])
  }
  stages{
    stage ("compile") {
      agent any
      steps{
          script{
            echo "compiling java code in ${params.Env}"
            sh "mvn compile"
          }
          
      }
    }
    stage ("code Review") {
      agent any
      steps{
        script{
          echo "Reviewing the code with pmd"
          sh "mvn pmd:pmd"
        }
      }
    }
    stage ("unit test") {
      agent any
      when{
        expression{
        params.executeTests == true
        }
      }
      steps{
          script{
          echo "Testing the code with Junit"
          sh "mvn test"
      }
      }
    }
    stage ("Coverage Analysis"){
      agent any
      steps{
          script{
          echo "static code analysis with jacoco"
          sh "mvn verify"
      }
      }
    }
    stage ("Package") {
      agent {label 'slave'}
      steps{
        script{
          echo "Creating artifact ${params.AppVersion}"
          sh "mvn package"
      }

      }
    }
  }
}