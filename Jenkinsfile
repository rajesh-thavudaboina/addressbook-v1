pipeline{
  ageent any
  stages{
    stage ("compile") {
      steps{
          echo "compiling java code"
      }
    }
    stage ("code Review") {
      steps{
          echo "Reviewing the code with pmd"
      }
    }
    stage ("unit test") {
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
          echo "Creating artifact"
      }
    }
  }
}