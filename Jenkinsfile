#!/usr/bin/env groovy

pipeline {
  agent { label 'executor-v2' }

  options {
    timestamps()
    buildDiscarder(logRotator(daysToKeepStr: '30'))
  }

  environment {
    INSTANCE_ID_FILE = "EC2.txt"
    AMI_ID_FILE = "AMI.txt"
  }

  parameters {
    string(name: 'CONJUR_VERSION', defaultValue: 'untagged', description: 'Version of Conjur to build into AMI (e.g. 5.x.x)')
  }

  stages {
    stage('Build the Conjur AMI') {
      steps {
        sh "summon ./build-ami.sh ${params.CONJUR_VERSION}"
        archiveArtifacts "*.txt,vars/*.yml"

        milestone(1)  // AMI is now built
      }
    }

    stage('Render CFN template for testing') {
      steps {
        sh "./render-cft.sh ${params.CONJUR_VERSION}"
        archiveArtifacts 'conjur*.yml'  // CFN stack files
      }
    }

    stage('Test the CFN template') {
      steps {
        sh "summon ./test.sh"
        milestone(2)  // AMI has been tested
      }
    }

    stage('Promote AMI to other regions') {
      when {
        branch 'master'
      }
      steps {
        sh './promote-to-regions.sh $(cat AMI.txt)'
        archiveArtifacts 'vars/*'

        sh "./render-cft.sh ${params.CONJUR_VERSION}"  // re-render here to pick up all AMIs
        archiveArtifacts 'conjur*.yml'
      }
    }

    stage('Publish CFT') {
      when {
        branch 'master'
      }
      steps {
        sh "summon ./publish-cft.sh ${params.CONJUR_VERSION}"
      }
    }
  }

  post {
    always {
      sh 'docker run -i --rm -v $PWD:/src -w /src alpine/git clean -fxd'
      deleteDir()
    }
    failure {
      slackSend(color: 'danger', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} FAILURE (<${env.BUILD_URL}|Open>)")
    }
    unstable {
      slackSend(color: 'warning', message: "${env.JOB_NAME} #${env.BUILD_NUMBER} UNSTABLE (<${env.BUILD_URL}|Open>)")
    }
  }
}
