pipeline {
     agent {
        docker {
            image 'greatnate27/weather-application-build-env:latest'
            args '-u 115:999 -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    environment {
        HOME = '.'
        DOCKERHUB_CREDENTIALS= credentials('b28bbdd7-0345-46b2-a3c8-050a04a90660')
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url:'https://github.com/GreatNatesTrait/weather-application.git'
            }
        }


        stage('Build and push app image') {      	
            steps{               
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'    
                sh 'docker build -t greatnate27/weather-application:latest .' 
                sh 'docker push greatnate27/weather-application:latest'           
            }      
            post{
                always {  
                sh 'docker logout'     
                }      
            }              
        }   


        stage('Deploy to EKS') {
            environment {
                AWS_REGION = 'us-east-1'
                EKS_CLUSTER_NAME = 'nates-eks-cluster'
            }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "new",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {       
                    // Update kubeconfig to connect to EKS cluster
                    sh 'aws sts get-caller-identity'
                    sh 'aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME'
        
                    // Apply Kubernetes deployment
                    sh 'kubectl apply -f deployment.yaml'
                    sh 'kubectl create -f loadbalancer.yaml'
                    }
            }
        }


        stage('Show external address to load balancer') {
            steps {             
                script {
                input "Continue?"                               
                    withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'c49b4767-615c-47ed-8880-e33d5b620515',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    sh 'kubectl get services'
                    }                 
                }
            }
        }


        stage('Destroy services and deployment') {
            steps {             
                script {
                input "Continue?"                               
                    withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'c49b4767-615c-47ed-8880-e33d5b620515',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                    sh 'kubectl delete service service-loadbalancer'
                    sh 'kubectl delete service kubernetes'
                    sh 'kubectl delete deployment weather-deployment'
                    }                 
                }
            }
        }
    }
}