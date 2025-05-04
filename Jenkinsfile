pipeline {
  agent any

  environment {
    TAG = "${env.GIT_COMMIT.substring(0, 7)}-${env.BUILD_NUMBER}"
  }

  stages {
    stage('audit-code') {
      steps {
        sh 'grype dir:src --fail-on medium'
      }
    }

    stage('build') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-login',
          usernameVariable: 'USERNAME',
          passwordVariable: 'PASSWORD'
        )]) {
          sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
        }
        sh "docker build -t janw4ld/go-serve:$TAG ."
      }
    }

    stage('audit-image') {
      steps {
        sh "grype janw4ld/go-serve:$TAG --fail-on medium"
      }
    }

    stage('push') {
      steps {
        sh "docker push janw4ld/go-serve:$TAG"
      }
    }
  }

  post {
    failure {
      slackSend(
        botUser: true,
        tokenCredentialId: 'slack-oauth-bot',
        channel: '#ana-w-jenkins',
        color: '#ff0000',
        message: "job:${env.JOB_NAME}-${env.BUILD_NUMBER} failed :(" +
             "\n  @branch:${env.GIT_BRANCH}" +
             "\n  @commit:${env.GIT_COMMIT}"
      )
    }

    always {
      sh 'docker logout'
      sh "docker rmi janw4ld/go-serve:$TAG"
    }
  }
}
