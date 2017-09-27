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

  parameters {
    string(name: 'CONJUR_VERSION', defaultValue: 'latest', description: 'Version of Conjur to build into AMI')
    booleanParam(name: 'PROMOTE_TO_REGIONS', defaultValue: false, description: 'Promote AMI across regions')
  }

  stages {
    stage('Build the Conjur CE AMI') {
      steps {
        sh "summon ./build.sh ${params.CONJUR_VERSION}"
        archiveArtifacts "*.txt"

        milestone(1)  // AMI is now built
      }
    }

    stage('Fetch and update the CFT') {
      steps {
        sh './fetch-cft.sh'
      }
    }

    stage('Test the AMI') {
      steps {
        sh "summon ./test.sh"
        milestone(2)  // AMI has been tested
      }
    }

    stage('Promote AMI to other regions') {
      when { allOf {
        branch 'master'
        expression { return params.PROMOTE_TO_REGIONS }
      }}
      steps {
        sh './promote-to-regions.sh $(cat AMI.txt)'
        archive "AMIS.json"
      }
    }

    stage('Publish CFT') {
      when {
        branch 'master'
      }
      steps {
        sh 'summon ./publish-cft.sh'
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
