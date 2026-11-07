// ==============================================================================
// Jenkinsfile - Declarative CI/CD Pipeline for Full-Stack DevOps Application
// ==============================================================================
pipeline {
    agent any

    options {
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
    }

    triggers {
        // Triggered automatically on push to main branch via GitHub Webhook
        githubPush()
    }

    parameters {
        choice(
            name: 'REGISTRY_TYPE',
            choices: ['dockerhub', 'ghcr'],
            description: 'Target Container Registry for publishing'
        )
        string(
            name: 'REGISTRY_USERNAME',
            defaultValue: 'dnyanhvi',
            description: 'Docker Hub or GitHub Container Registry username/organization'
        )
        booleanParam(
            name: 'DEPLOY_LOCAL',
            defaultValue: true,
            description: 'Deploy application locally via Docker Compose after build'
        )
    }

    environment {
        // Secure credentials IDs configured in Jenkins Credential Manager
        DOCKER_CREDS_ID = 'docker-registry-credentials'
        
        // Dynamic image names based on registry selection
        BACKEND_IMAGE = "${params.REGISTRY_TYPE == 'ghcr' ? 'ghcr.io/' + params.REGISTRY_USERNAME + '/devops-backend' : params.REGISTRY_USERNAME + '/devops-backend'}"
        FRONTEND_IMAGE = "${params.REGISTRY_TYPE == 'ghcr' ? 'ghcr.io/' + params.REGISTRY_USERNAME + '/devops-frontend' : params.REGISTRY_USERNAME + '/devops-frontend'}"
        
        IMAGE_TAG = "${BUILD_NUMBER}"
        BACKEND_HEALTH_URL = 'http://localhost:8000/api/health/'
        FRONTEND_HEALTH_URL = 'http://localhost:3000'
    }

    stages {
        // ----------------------------------------------------------------------
        // Stage 1: Checkout Source Code
        // ----------------------------------------------------------------------
        stage('Checkout') {
            steps {
                echo "📥 Checking out source code from Git repository..."
                checkout scm
            }
        }

        // ----------------------------------------------------------------------
        // Stage 2: Source Code Validation
        // ----------------------------------------------------------------------
        stage('Source Validation') {
            steps {
                echo "🔍 Validating project file structure..."
                sh '''
                    test -d backend || { echo "❌ backend directory missing"; exit 1; }
                    test -d frontend || { echo "❌ frontend directory missing"; exit 1; }
                    test -f backend/Dockerfile || { echo "❌ backend/Dockerfile missing"; exit 1; }
                    test -f frontend/Dockerfile || { echo "❌ frontend/Dockerfile missing"; exit 1; }
                    test -f docker-compose.yml || { echo "❌ docker-compose.yml missing"; exit 1; }
                    echo "✅ Project files validated successfully."
                '''
            }
        }

        // ----------------------------------------------------------------------
        // Stage 3: Backend Dependency Installation & Tests
        // ----------------------------------------------------------------------
        stage('Backend Tests') {
            steps {
                echo "🧪 Running Django backend tests..."
                dir('backend') {
                    sh '''
                        pip3 install --break-system-packages --quiet -r requirements.txt
                        python3 manage.py check
                        python3 manage.py test core --verbosity=2
                    '''
                }
            }
        }

        // ----------------------------------------------------------------------
        // Stage 4: Frontend Dependency Installation & Build
        // ----------------------------------------------------------------------
        stage('Frontend Build') {
            steps {
                echo "🔨 Building React + Vite frontend assets..."
                dir('frontend') {
                    sh '''
                        npm ci
                        npm run build
                    '''
                }
            }
        }

        // ----------------------------------------------------------------------
        // Stage 5: Docker Images Build & Tagging
        // ----------------------------------------------------------------------
        stage('Docker Build & Tag') {
            steps {
                echo "🐳 Building multi-stage Docker images..."
                sh """
                    docker build -t ${BACKEND_IMAGE}:${IMAGE_TAG} -t ${BACKEND_IMAGE}:latest ./backend
                    docker build -t ${FRONTEND_IMAGE}:${IMAGE_TAG} -t ${FRONTEND_IMAGE}:latest ./frontend
                """
            }
        }

        // ----------------------------------------------------------------------
        // Stage 6: Push Images to Docker Registry
        // ----------------------------------------------------------------------
        stage('Docker Push') {
            when {
                expression { return params.REGISTRY_USERNAME != '' }
            }
            steps {
                echo "📤 Pushing images to container registry securely..."
                withCredentials([usernamePassword(
                    credentialsId: env.DOCKER_CREDS_ID,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        if [ "${params.REGISTRY_TYPE}" = "ghcr" ]; then
                            echo "\$DOCKER_PASS" | docker login ghcr.io -u "\$DOCKER_USER" --password-stdin
                        else
                            echo "\$DOCKER_PASS" | docker login -u "\$DOCKER_USER" --password-stdin
                        fi

                        docker push ${BACKEND_IMAGE}:${IMAGE_TAG}
                        docker push ${BACKEND_IMAGE}:latest
                        docker push ${FRONTEND_IMAGE}:${IMAGE_TAG}
                        docker push ${FRONTEND_IMAGE}:latest

                        docker logout
                    """
                }
            }
        }

        // ----------------------------------------------------------------------
        // Stage 7: Local Deployment with Docker Compose
        // ----------------------------------------------------------------------
        stage('Deploy Local') {
            when {
                expression { return params.DEPLOY_LOCAL == true }
            }
            steps {
                echo "🚀 Deploying containers locally with Docker Compose..."
                sh '''
                    chmod +x ./deploy.sh
                    ./deploy.sh
                '''
            }
        }

        // ----------------------------------------------------------------------
        // Stage 8: Health Verification
        // ----------------------------------------------------------------------
        stage('Health Verification') {
            when {
                expression { return params.DEPLOY_LOCAL == true }
            }
            steps {
                echo "🩺 Verifying endpoint connectivity..."
                sh """
                    curl -s -f ${BACKEND_HEALTH_URL} || { echo "❌ Backend health check failed"; exit 1; }
                    curl -s -f ${FRONTEND_HEALTH_URL} || { echo "❌ Frontend health check failed"; exit 1; }
                    echo "✅ All services healthy and responsive."
                """
            }
        }
    }

    post {
        always {
            echo "🧹 Cleaning up intermediate build artifacts..."
            cleanWs deleteDirs: true, notFailBuild: true
        }
        success {
            echo "🎉 Pipeline finished successfully! Application is live."
        }
        failure {
            echo "❌ Pipeline failed! Capturing container logs..."
            sh 'docker compose logs 2>&1 | tail -100 || true'
        }
    }
}

