#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  environment {
    INSTANCE_ID_FILE = "EC2.txt"
    AMI_ID_FILE = "AMI.txt"
  }

  stages {
    stage('Build the Conjur CE AMI') {
      steps {
        sh "summon ./build.sh"

        archiveArtifacts "${INSTANCE_ID_FILE} ${AMI_ID_FILE}"
      }

    }

    stage('Test the AMI') {
      steps {
        sh "summon ./test.sh"
      }
    }
  }

  post {
    always {
      sh 'docker run -i --rm -v $PWD:/src -w /src alpine/git clean -fxd'
    }      
    failure {
      slackSend(color: 'danger', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} FAILURE (<${env.BUILD_URL}|Open>)")
    }
    unstable {
      slackSend(color: 'warning', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} UNSTABLE (<${env.BUILD_URL}|Open>)")
    }
  }
}
