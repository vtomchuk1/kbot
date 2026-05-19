pipeline {
    agent any

    environment {
        REPO = 'https://github.com/vtomchuk1/kbot'
        BRANCH = 'main'
        PATH = "/usr/local/go/bin:${env.PATH}"
    }
    
    parameters {
        choice(
            name: 'OS',
            choices: ['linux', 'darwin', 'windows'],
            description: 'Target operating system'
        )
        choice(
            name: 'ARCH',
            choices: ['amd64', 'arm64'],
            description: 'Target architecture'
        )
        booleanParam(
            name: 'SKIP_TESTS',
            defaultValue: false,
            description: 'Skip running tests'
        )
        booleanParam(
            name: 'SKIP_LINT',
            defaultValue: false,
            description: 'Skip running linter'
        )
    }

    stages {

        stage('clone') {
            steps {
                echo 'Clone Repository'
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        
        stage('lint') {
            when {
                expression { return params.SKIP_LINT == false }
            }
            steps {
                echo 'Lint project'
                sh "make format"
            }
        }

        stage('test') {
            when {
                expression { return params.SKIP_TESTS == false }
            }
            steps {
                echo 'Testing started'
                sh "make test"
            }
        }

        stage('build') {
            steps {
                echo "Building binary started"
                sh "make build TARGETARCH=${params.ARCH} TARGETOS=${params.OS}"
            }
        }

        stage('image') {
            steps {
                echo "Building image started"
                sh "make image TARGETARCH=${params.ARCH} TARGETOS=${params.OS}"
            }
        }

        stage('login to GHCR') {
            steps {
                // Зв'язуємо ID секрету з Jenkins зі змінними для Bash
                withCredentials([usernamePassword(credentialsId: 'github-ghcr-token', 
                                                 passwordVariable: 'GITHUB_TOKEN_PSW', 
                                                 usernameVariable: 'GITHUB_TOKEN_USR')]) {
                    
                    // Обов'язково ставимо \$ перед змінними всередині подвійних лапок ""
                    sh "echo \$GITHUB_TOKEN_PSW | docker login ghcr.io -u \$GITHUB_TOKEN_USR --password-stdin"
                }
            }
        }
        
        stage('push image') {
            steps {
              sh "make push TARGETARCH=${params.ARCH} TARGETOS=${params.OS}"
            }
        } 
    }
}