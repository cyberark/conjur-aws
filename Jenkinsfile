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
        archiveArtifacts "*.txt,vars-amis.yml"

        milestone(1)  // AMI is now built
      }
    }

    stage('Render CFN template for testing') {
      steps {
        sh "./render-cft.sh ${params.CONJUR_VERSION}"
        archiveArtifacts 'conjur*.yml'  // CFN stack files
      }
    }

    stage('Test the AMI') {
      steps {
        sh "summon ./test.sh"
        milestone(2)  // AMI has been tested
      }
    }

    stage('Fix permissions') {
      steps {
        sh 'sudo chown -R jenkins:jenkins .'  // bad docker mounts create unreadable files TODO fix this
      }
    }

    stage('Promote AMI to other regions') {
      when { allOf {
        branch 'master'
        expression { return params.PROMOTE_TO_REGIONS }
      }}
      steps {
        sh './promote-to-regions.sh $(cat AMI.txt)'

        sh "./render-cft.sh ${params.CONJUR_VERSION}"  // re-render here to pick up all AMIs
        archiveArtifacts 'vars-amis.yml,conjur*.yml,amis.json'
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
