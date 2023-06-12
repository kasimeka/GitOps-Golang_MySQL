pipeline {
    agent any

    stages {
        stage('build') {
            steps {
                sh 'exit 1'
                script {
                    tag = env.GIT_COMMIT.substring(0, 7) + '-' + env.BUILD_NUMBER
                }
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-login',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    sh 'echo $PASSWORD | docker login -u $USERNAME --password-stdin'
                }
                sh "docker build -t janw4ld/go-serve:${tag} ."
                sh "docker push janw4ld/go-serve:${tag}"
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
                message: "job:${env.JOB_NAME}failed :("
                         "\n  @branch:${env.GIT_BRANCH}"
                         "\n  @commit:${env.GIT_COMMIT}"
            )
        }
    }
}
