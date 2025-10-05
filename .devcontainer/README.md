# Development Environment Setup

This directory contains the configuration for the VS Code development container (devcontainer) that provides a pre-configured development environment for this project.

## What is a Devcontainer?

A development container (devcontainer) is a full-featured development environment that runs inside a Docker container. It ensures everyone on the team has the same tools and dependencies, regardless of their host operating system.

## Prerequisites

To use the devcontainer, you need:

1. **Docker Desktop** (or Docker Engine)
   - [Windows](https://docs.docker.com/desktop/install/windows-install/)
   - [macOS](https://docs.docker.com/desktop/install/mac-install/)
   - [Linux](https://docs.docker.com/desktop/install/linux-install/)

2. **Visual Studio Code**
   - [Download VS Code](https://code.visualstudio.com/)

3. **Dev Containers Extension**
   - Install from [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## Quick Start

### Open in Devcontainer

1. Open this project in VS Code
2. VS Code will detect the devcontainer configuration
3. Click "Reopen in Container" when prompted (or use Command Palette: `Dev Containers: Reopen in Container`)
4. Wait for the container to build and the setup script to complete (~5-10 minutes first time)

### What Gets Installed

The `setup.sh` script automatically installs:

**Core Tools**:
- `kubectl` - Kubernetes command-line tool
- `kind` - Kubernetes in Docker (local clusters)
- `terraform` - Infrastructure as code tool
- `eksctl` - EKS cluster management tool
- `just` - Command runner (like make but better)
- `aws-cli` - AWS command-line interface
- `k9s` - Terminal UI for Kubernetes

**System Tools**:
- `curl`, `wget` - Download utilities
- `jq` - JSON processor
- `git` - Version control
- Docker CLI (via devcontainer feature)

### Verify Installation

After the container is ready, verify tools are installed:

```bash
# Check tool versions
kubectl version --client
kind version
terraform version
eksctl version
just --version
aws --version
k9s version --short
```

## Configuration

### devcontainer.json

The main configuration file that defines:

- **Base Image**: Ubuntu 22.04 from Microsoft's devcontainer images
- **VS Code Extensions**:
  - GitHub Copilot (AI pair programmer)
  - Nord theme (color scheme)
  - Material Icon Theme (file icons)
  - HashiCorp Terraform (syntax highlighting and IntelliSense)
  - Kubernetes Tools (cluster management and YAML support)
  - YAML Language Support (validation and completion)
  - Docker (Dockerfile and docker-compose support)
  - ShellCheck (shell script linting)
  - Shell Format (shell script formatting)
  - Just (justfile syntax support)
- **Features**:
  - Docker-outside-of-Docker (access host's Docker daemon)
- **Post-Create Command**: Runs `setup.sh` after container creation

### setup.sh

The automated setup script that:

1. Installs system packages via `apt-get`
2. Downloads and installs Kubernetes tools
3. Downloads and installs AWS tools
4. Sets up command-line utilities
5. Verifies all installations

## Usage

### First Time Setup

After opening in devcontainer for the first time:

1. **Wait for setup to complete** - Check the terminal output

2. **Configure AWS credentials** (if using EKS):
   
   **Option A: GitHub Codespaces Secrets (Recommended)**
   - Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your repository's Codespaces secrets
   - Credentials will be automatically configured when the Codespace starts
   - See [AWS-SETUP.md](../AWS-SETUP.md) for detailed instructions
   
   **Option B: Manual Configuration**
   ```bash
   aws configure
   ```

3. **Verify AWS credentials** (if configured):
   ```bash
   aws sts get-caller-identity
   ```

4. **Create your first cluster**:
   ```bash
   # Local cluster (free)
   just kind
   
   # Or cloud cluster (AWS costs apply)
   just eks-create-dev
   ```

### Daily Workflow

The devcontainer persists your environment between sessions:

```bash
# Morning: Start Kind cluster
just kind

# Work: Deploy and test
just nginx
kubectl get pods
kubectl logs -f <pod-name>

# Evening: Clean up
just teardown
```

### Working with Multiple Terminals

Open multiple terminals in VS Code to:
- Run commands in one terminal
- Watch logs in another
- Keep k9s running in a third

```bash
# Terminal 1: Interactive cluster viewer
k9s

# Terminal 2: Deploy and test
kubectl apply -f k8s/manifests/
kubectl get pods -w

# Terminal 3: View logs
kubectl logs -f deployment/nginx-deployment
```

## Customization

### Add More Tools

Edit `setup.sh` to add additional tools:

```bash
# Add to setup.sh
echo "Installing my-tool..."
curl -Lo /usr/local/bin/my-tool https://example.com/my-tool
chmod +x /usr/local/bin/my-tool
```

### Change VS Code Settings

Edit `devcontainer.json` to customize VS Code:

```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "editor.fontSize": 14,
        "terminal.integrated.fontSize": 12
      },
      "extensions": [
        "hashicorp.terraform"
      ]
    }
  }
}
```

### Persist Data

The devcontainer automatically mounts:
- Your source code
- Git configuration
- SSH keys (for GitHub access)

AWS credentials and kube configs persist in the container's file system between sessions.

**For GitHub Codespaces users**: Use repository secrets to automatically configure AWS credentials. See [AWS-SETUP.md](../AWS-SETUP.md) for instructions.

## Troubleshooting

### Container Won't Start

```bash
# Rebuild container
1. Command Palette (Ctrl+Shift+P / Cmd+Shift+P)
2. "Dev Containers: Rebuild Container"
```

### Tool Not Found

```bash
# Re-run setup script
bash .devcontainer/setup.sh

# Check if tool was installed
which kubectl
ls -la /usr/local/bin/
```

### Docker Issues

```bash
# Check Docker is running
docker ps

# Check Docker daemon is accessible
docker info
```

### Permission Issues

```bash
# Check user
whoami  # Should be 'vscode' or 'root'

# Fix permissions if needed
sudo chown -R $(whoami) ~/.kube
```

## Alternative: Manual Installation

If you prefer not to use devcontainer, install tools manually:

### macOS (Homebrew)

```bash
brew install kubectl kind terraform eksctl just awscli derailed/k9s/k9s
```

### Linux (Ubuntu/Debian)

```bash
# Follow the commands in setup.sh
# Or use package managers:
sudo apt-get install -y kubectl
snap install terraform --classic
# ... etc
```

### Windows (Chocolatey)

```powershell
choco install kubernetes-cli kind terraform eksctl just awscli k9s
```

## Docker-outside-of-Docker

The devcontainer uses "Docker-outside-of-Docker" which means:
- The container doesn't run its own Docker daemon
- It connects to the host's Docker daemon
- Kind clusters run on the host, not in the container

**Benefits**:
- Better performance
- Less resource usage
- Clusters persist even if container is rebuilt

## Resources

- [VS Code Dev Containers Documentation](https://code.visualstudio.com/docs/devcontainers/containers)
- [Dev Container Spec](https://containers.dev/)
- [Docker Documentation](https://docs.docker.com/)

## Tips

1. **Use k9s**: It's installed and provides a great UI for exploring clusters
   ```bash
   k9s
   ```

2. **Bash completion**: Tools support tab completion
   ```bash
   kubectl get po<TAB>  # Autocompletes to 'pods'
   ```

3. **Command history**: Search command history with Ctrl+R

4. **Multiple clusters**: Switch between contexts easily
   ```bash
   kubectl config get-contexts
   kubectl config use-context kind-platform-sandbox
   ```

5. **Quick navigation**: Use `just` commands for common tasks
   ```bash
   just --list  # Show all available commands
   ```
