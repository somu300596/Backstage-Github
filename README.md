# Backstage-Github

## Application

The application that will be used for this test is an simple Hello world Nginx application.  
The Dockerfile is quite simple. It fetches nginx:alpine as the base image and copies the index.html (which renders an Hello World message) to the default html dir **/usr/share/nginx/html**. The docker exposes port 80 so that it can be visible to the outside world.

## GitHub workflow

The GitHub workflow file has four steps, which will be triggered on push events:  
1. Checkout code
2. Build docker image
3. Run the docker container: In this step we port forward the 80 port in container to 8082 port in the host
4. We check if we get the output via performing curl on localhost:8082


## Backstage - GitHub
I have started with linking the Github repository with Backstage. There is a file called catalog-info.yml which when registered as an existing component will create a new component in the backstage.
To integrate the GitHub events with Backstage I intially started with GitHub webhooks and create a service in Backstage to subscribe to the events, but I couldn't get progress with that approach since webhooks in GitHub requires public IP of the backstage and since I was running backstage on localhost, I couldn't provide an URL for webhook and also had some issues with creating plugin in the backstage for subscribing to the events. Ofcourse this could be easier if there is an instance of backstage running in AWS EC2 instance but I did not have enough time to do setup for that approach. Polling could be also another approach (instead of webhooks).

**But eventually due to time constraints I coulnd't complete backstage and GitHub integration**

## Docker image deployment - AWS

In order to integrate with cloud services: AWS for instance, we need to perform the below:  
1. Provide AWS credentials to GitLab via secrets so it can be used by workflow.
2. First we need to push the built image to AWS ECR (Elastic Container Registry) and add something like below in the workflow yaml: **For this to work, there should already be an AWS account and ECR url available beforehand.**
````
steps:
  - name: Login to Amazon ECR
    id: login-ecr
    uses: aws-actions/amazon-ecr-login@v1
    with:
      registry: your-ecr-url
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}

  - name: Build and push Docker image to ECR
    run: |
      docker build -t your-image-name .
      docker tag your-image-name ${{ steps.login-ecr.outputs.registry }}:latest
      docker push ${{ steps.login-ecr.outputs.registry }}:latest
````

3. Additionally to orchestrate the docker image built in the previous step we can integrate ECS into it.
Amazon ECS is a fully managed container orchestration service that allows you to run Docker containers at scale. To deploy your Docker images to ECS, we will need to follow the below steps:
    1. Define an ECS task definition: This defines the containers you want to run, including the Docker image, CPU, memory, networking configuration, and other settings. Here we can specify the the docker image built in the previous step.
    2. Create an ECS service: This defines how many copies of your task definition to run and how to distribute traffic to them.
    3. Update the service with the new task definition revision: This triggers ECS to pull the latest Docker image from ECR and deploy it to your ECS cluster. 
    4. Since this task is a simple web server displaying hello world and does not have any interaction with other AWS services, we do not need to create an extensive task role. We just would need to open the 80 port in the inbound security group.