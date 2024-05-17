```bash
pipeline {
    agent any
    
    environment {
        imageName = "jaesung/a406-develop"
        registryCredential = 'jaesung-docker'
        dockerImage = ''
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        releaseServerAccount = 'ubuntu'
        releaseServerUri = 'k10a406.p.ssafy.io'
        releasePort = '8000'
    }

    stages {
        stage('Check Docker') {
            steps {
                script {
                    // Docker 경로 확인
                    sh 'echo $PATH'
                    sh 'which docker || echo "Docker not found"'
                }
            }
        }
        
        stage('Git Clone') {
            steps {
                git branch: 'develop',
                    credentialsId: 'Jaesung-Gitlab',
                    url: 'https://lab.ssafy.com/s10-final/S10P31A406'
            }
        }

        stage('Build and Deploy') {
            steps {
                echo 'Container Build Start !! '
                dir('backend') { // 모든 docker-compose 명령은 backend 디렉토리에서 실행
                    script {
                            // docker-compose를 사용하여 빌드 및 푸시
                            sh "docker-compose -f ${DOCKER_COMPOSE_FILE} pull" // 의존성 있는 이미지들을 먼저 Pull
                            sh "docker-compose -f ${DOCKER_COMPOSE_FILE} build"
                            sh "docker-compose -f ${DOCKER_COMPOSE_FILE} push"
                    }
                }
            }
        }

        stage('Before Service Stop') {
            steps {
                echo 'Befroe Service Stop~!'
                dir('backend') {
                    script {
                        // 서비스 중지
                        sh "docker-compose -f ${DOCKER_COMPOSE_FILE} down"
                    }
                }
            }
        }

        stage('Service Start') {
            steps {
                echo 'start container~!'
                dir('backend') {
                    script {
                        // 서비스 시작
                        sh "docker-compose -f ${DOCKER_COMPOSE_FILE} up -d"
                    }
                }
            }
        }
        
    }

    post {
            success {
            	script {
                    sleep(20)
                    def Author_ID = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
                    def Author_Name = sh(script: "git show -s --pretty=%ae", returnStdout: true).trim()
                    mattermostSend (color: 'good', 
                        // message: "# :birth_cong: [경] 조성호 탄신일 [축] :birth_cong: ${env.JOB_NAME} #${env.BUILD_NUMBER} by ${Author_ID}(${Author_Name}) \n(<${env.BUILD_URL}|Details>)"
                        message: ":white_check_mark: [빌드 성공] ${env.JOB_NAME} #${env.BUILD_NUMBER} by ${Author_ID}(${Author_Name}) \n(<${env.BUILD_URL}|Details>)"
                        )
                }
            }
            failure {
            	script {
                    def Author_ID = sh(script: "git show -s --pretty=%an", returnStdout: true).trim()
                    def Author_Name = sh(script: "git show -s --pretty=%ae", returnStdout: true).trim()
                    mattermostSend (color: 'danger', 
                        message: ":x: [빌드 실패] ${env.JOB_NAME} #${env.BUILD_NUMBER} by ${Author_ID}(${Author_Name}) \n(<${env.BUILD_URL}|Details>)"
                        )
                }
            }
        }
    
}

```