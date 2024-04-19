# Backstage-Github

## Application

The application that will be used for this test is an simple Hello world Nginx application.  
The Dockerfile is quite simple. It fetches nginx:alpine as the base image and copies the index.html (which renders an Hello World message) to the default html dir **/usr/share/nginx/html**. The docker exposes port 80 so that it can be visible to the outside world.

