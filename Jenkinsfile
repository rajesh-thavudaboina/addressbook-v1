pipeline{
  agent any
  parameters{
    string(name:'Env',defaultValue:'Test',description:'version to deploy')
    booleanParam(name:'executeTests',defaultValue:true ,description:'decide to run it')
    choice(name:'AppVersion',choices:['1','2','3'])
  }
  stages{
    stage ("compile") {
      steps{
          echo "compiling java code in ${params.Env}"
      }
    }
    stage ("code Review") {
      steps{
          echo "Reviewing the code with pmd"
      }
    }
    stage ("unit test") {
      when{
        expression{
        params.executeTests == true
        }
      }
      steps{
          echo "Testing the code with Junit"
      }
    }
    stage ("Coverage Analysis"){
      steps{
          echo "static code analysis with jacoco"
      }
    }
    stage ("Package") {
      steps{
          echo "Creating artifact ${params.AppVersion}"
      }
    }
  }
}