pipeline {
    agent any

    stages {
        stage('build') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-login',
                    usernameVariable: 'USERNAME',
                    passwordVariable: 'PASSWORD'
                )]) {
                    script {
                        tag = env.GIT_COMMIT.substring(0, 7) + '-' + env.BUILD_NUMBER
                    }

                    sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    sh "docker build -t janw4ld/go-serve:${tag} ."
                    sh "docker push janw4ld/go-serve:${tag}"
                }
            }
        }
    }

    post {
        failure {
            slackSend(
                botUser: true,
                tokenCredentialId: 'slack-oauth-bot',
                channel: '#ana-w-go',
                color: '#ff0000',
                message: 'Build failed :('
            )
        }
    }
}
