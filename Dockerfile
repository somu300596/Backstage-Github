# Use the official NGINX image as base
FROM nginx:alpine

# Copy the contents of the 'html' directory into the NGINX default HTML directory
COPY index.html /usr/share/nginx/html

# Expose port 80 to allow external access to the NGINX server
EXPOSE 80
