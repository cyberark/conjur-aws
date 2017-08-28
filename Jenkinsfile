#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }

  environment {
    AMI_FILE = "AMI.txt"
  }

  stages {
    stage('Build the Conjur CE AMI') {
      steps {
        // It would feel more natural to have build.sh write out the AMI ID to stdout and redirect it to a file. Ansible
        // is sloppy with its handling of stdout and stderr, though, so that's not really an option.
        sh "summon ./build.sh ${AMI_FILE}"

        archiveArtifacts "${AMI_FILE}"
      }

    }

    stage('Test the AMI') {
      steps {
        sh "summon ./test.sh ${AMI_FILE}"
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
