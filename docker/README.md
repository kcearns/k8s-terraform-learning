# Docker Configuration

This directory contains Docker container configurations for the project.

## Dockerfile

A simple nginx-based Dockerfile that can be used as a starting point for building custom container images.

### Base Image

- **Image**: `nginx:1.25.4-alpine`
- **Why Alpine**: Smaller image size (~40MB vs ~140MB for standard nginx)
- **Security**: Alpine is a minimal Linux distribution with fewer potential vulnerabilities

### Configuration

The Dockerfile is set up with placeholders for common nginx customizations:

```dockerfile
FROM nginx:1.25.4-alpine

# Copy custom configuration if needed
# COPY nginx.conf /etc/nginx/nginx.conf

# Copy website files
# COPY ./html /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

## Usage

### Build the Image

```bash
# Build with default tag
docker build -t my-nginx:latest .

# Build with custom tag
docker build -t my-nginx:v1.0.0 .

# Build from project root
docker build -t my-nginx:latest -f docker/Dockerfile .
```

### Run the Container

```bash
# Run on port 8080
docker run -d -p 8080:80 --name my-nginx my-nginx:latest

# Access at http://localhost:8080
```

### Stop and Remove

```bash
# Stop container
docker stop my-nginx

# Remove container
docker rm my-nginx

# Remove image
docker rmi my-nginx:latest
```

## Customization

### Add Custom nginx Configuration

1. Create an `nginx.conf` file in this directory
2. Uncomment the COPY line in the Dockerfile:
   ```dockerfile
   COPY nginx.conf /etc/nginx/nginx.conf
   ```
3. Rebuild the image

### Add Static Website Files

1. Create an `html/` directory with your website files
2. Uncomment the COPY line in the Dockerfile:
   ```dockerfile
   COPY ./html /usr/share/nginx/html
   ```
3. Rebuild the image

### Example: Serving a Custom HTML Page

```bash
# Create html directory
mkdir -p docker/html

# Create a simple index.html
cat > docker/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>My Custom Page</title>
</head>
<body>
    <h1>Hello from my custom nginx container!</h1>
</body>
</html>
EOF

# Update Dockerfile to copy html files
# Then build and run
docker build -t my-custom-nginx docker/
docker run -d -p 8080:80 my-custom-nginx
```

## Best Practices

### Multi-stage Builds

For more complex applications, consider multi-stage builds to reduce image size:

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM nginx:1.25.4-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Security Considerations

1. **Use specific versions**: Always pin image versions (e.g., `nginx:1.25.4-alpine` not `nginx:latest`)
2. **Run as non-root**: Consider using nginx's non-root variant
3. **Scan for vulnerabilities**: Use tools like `docker scan` or Trivy
4. **Minimize layers**: Combine RUN commands where possible

### Image Optimization

```dockerfile
# Good: Smaller image, fewer layers
FROM nginx:1.25.4-alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/ /usr/share/nginx/html/

# Avoid: Larger image, more layers
FROM nginx:1.25.4
RUN apt-get update
RUN apt-get install -y curl
COPY nginx.conf /etc/nginx/nginx.conf
COPY html/ /usr/share/nginx/html/
```

## Docker Commands Reference

### Image Management

```bash
# List images
docker image ls

# Remove unused images
docker image prune

# Remove all images
docker system prune -a

# View image history
docker history my-nginx:latest

# Inspect image
docker inspect my-nginx:latest
```

### Container Management

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# View container logs
docker logs my-nginx

# Follow logs
docker logs -f my-nginx

# Execute command in container
docker exec -it my-nginx sh

# View container stats
docker stats my-nginx
```

### Debugging

```bash
# Run container in interactive mode
docker run -it --rm nginx:1.25.4-alpine sh

# Check nginx configuration
docker exec my-nginx nginx -t

# Reload nginx configuration
docker exec my-nginx nginx -s reload

# View nginx error log
docker exec my-nginx cat /var/log/nginx/error.log

# View nginx access log
docker exec my-nginx cat /var/log/nginx/access.log
```

## Integration with Kubernetes

This Dockerfile can be used to build custom images for Kubernetes deployments:

1. **Build the image**:
   ```bash
   docker build -t my-registry/my-nginx:v1.0.0 docker/
   ```

2. **Push to registry**:
   ```bash
   # Docker Hub
   docker push my-registry/my-nginx:v1.0.0

   # AWS ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   docker tag my-nginx:v1.0.0 <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-nginx:v1.0.0
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/my-nginx:v1.0.0
   ```

3. **Update Kubernetes manifest**:
   ```yaml
   spec:
     containers:
     - name: nginx
       image: my-registry/my-nginx:v1.0.0
   ```

4. **Deploy to cluster**:
   ```bash
   kubectl apply -f k8s/manifests/nginx.yaml
   ```

## Local Testing with Kind

You can test your Docker images directly in your Kind cluster without pushing to a registry:

```bash
# Build the image
docker build -t my-nginx:test docker/

# Load image into Kind cluster
kind load docker-image my-nginx:test --name platform-sandbox

# Update manifest to use local image
# Set imagePullPolicy: Never in the manifest

# Deploy
kubectl apply -f k8s/manifests/nginx.yaml
```

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [nginx Docker Official Image](https://hub.docker.com/_/nginx)
- [Alpine Linux](https://alpinelinux.org/)
