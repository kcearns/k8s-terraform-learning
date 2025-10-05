# Contributing to k8s-terraform-learning

Thank you for your interest in contributing to this learning repository! This guide will help you get started.

## Project Purpose

This repository is designed to help people learn Kubernetes and Terraform through hands-on examples. We aim to:
- Provide clear, working examples
- Support multiple learning paths (local, eksctl, Terraform)
- Maintain beginner-friendly documentation
- Keep costs low for learners

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

1. **Documentation Improvements**
   - Fix typos or unclear explanations
   - Add missing examples
   - Improve existing tutorials
   - Translate documentation

2. **Code Examples**
   - Add new Kubernetes manifests
   - Create Terraform modules
   - Add automation scripts

3. **Bug Fixes**
   - Fix broken commands
   - Correct configuration errors
   - Update deprecated syntax

4. **New Features**
   - Add support for new tools
   - Create additional learning paths
   - Add monitoring or observability examples

## Getting Started

### Prerequisites

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/k8s-terraform-learning.git
   cd k8s-terraform-learning
   ```
3. Set up the development environment:
   - Use the devcontainer (recommended), or
   - Install tools manually (kubectl, kind, terraform, eksctl)

### Development Setup

Using devcontainer (easiest):

```bash
# Open in VS Code
code .

# Reopen in Container when prompted
# Or use Command Palette: "Dev Containers: Reopen in Container"
```

Manual setup:

```bash
# Install required tools
# See .devcontainer/setup.sh for installation commands

# Verify installations
kubectl version --client
kind version
terraform version
eksctl version
```

## Making Changes

### Workflow

1. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

2. **Make your changes**:
   - Follow the existing code style
   - Test your changes locally
   - Update documentation as needed

3. **Test your changes**:
   ```bash
   # For Kubernetes manifests
   kubectl apply --dry-run=client -f k8s/manifests/your-file.yaml
   
   # For Kind configurations
   kind create cluster --config k8s/kind.yaml --name test-cluster
   
   # For Terraform
   cd terraform
   terraform init
   terraform plan
   terraform validate
   
   # For eksctl configs
   eksctl create cluster --dry-run -f eksctl/your-config.yaml
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Description of your changes"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Go to the original repository on GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the PR template

### Commit Message Guidelines

Use clear, descriptive commit messages:

```bash
# Good examples
git commit -m "Add AWS load balancer controller example"
git commit -m "Fix typo in eksctl README"
git commit -m "Update terraform to support latest EKS version"

# Avoid
git commit -m "Update files"
git commit -m "Fix stuff"
git commit -m "WIP"
```

## Code Style Guidelines

### Markdown Documentation

- Use clear, simple language
- Include code examples where helpful
- Use proper headings hierarchy (##, ###, ####)
- Keep lines under 120 characters when possible
- Add blank lines between sections

Example:
```markdown
## Section Title

Brief introduction to the section.

### Subsection

Content here with examples:

\`\`\`bash
command --example
\`\`\`

Explanation of the command.
```

### Kubernetes Manifests

- Use 2 spaces for indentation
- Include resource limits and requests
- Add meaningful labels
- Include comments for complex configurations

Example:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:1.0.0
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
```

### Terraform Code

- Use 2 spaces for indentation
- Add descriptions to variables
- Use meaningful resource names
- Include comments for complex logic
- Follow [Terraform style conventions](https://www.terraform.io/docs/language/syntax/style.html)

Example:
```hcl
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-cluster"
}

resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  
  vpc_config {
    subnet_ids = data.aws_subnets.selected.ids
  }
  
  # Ensure IAM role is created before cluster
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}
```

### Shell Scripts

- Use bash as the shebang: `#!/bin/bash`
- Include `set -e` to exit on errors
- Add comments for complex commands
- Use meaningful variable names
- Quote variables: `"$VAR"` not `$VAR`

Example:
```bash
#!/bin/bash
set -e

CLUSTER_NAME="${1:-default-cluster}"

echo "Creating cluster: $CLUSTER_NAME"

if kind get clusters | grep -q "$CLUSTER_NAME"; then
    echo "Cluster already exists"
    exit 1
fi

kind create cluster --name "$CLUSTER_NAME"
```

## Testing

### Local Testing

Before submitting a PR, test your changes:

1. **Documentation changes**: Read through for clarity and correctness

2. **Kubernetes manifests**:
   ```bash
   # Syntax validation
   kubectl apply --dry-run=client -f your-file.yaml
   
   # Test in Kind cluster
   just kind
   kubectl apply -f your-file.yaml
   kubectl get all
   ```

3. **Terraform configurations**:
   ```bash
   cd terraform
   terraform fmt -check  # Check formatting
   terraform validate    # Validate syntax
   terraform plan        # Preview changes (if possible)
   ```

4. **Scripts**:
   ```bash
   # Check syntax
   bash -n your-script.sh
   
   # Run with dry-run or test flags if available
   ./your-script.sh --dry-run
   ```

### Testing Checklist

- [ ] Code runs without errors
- [ ] Documentation is clear and accurate
- [ ] Examples work as described
- [ ] No hardcoded credentials or secrets
- [ ] Compatible with stated versions
- [ ] Follows existing code style
- [ ] New features have documentation

## Pull Request Guidelines

### PR Template

When creating a PR, include:

**Description**:
- What does this PR do?
- Why is this change needed?

**Testing**:
- How did you test these changes?
- What environments did you test in?

**Checklist**:
- [ ] Tested locally
- [ ] Documentation updated
- [ ] No secrets or credentials in code
- [ ] Follows code style guidelines

### PR Review Process

1. Maintainers will review your PR
2. Address any feedback or requested changes
3. Once approved, your PR will be merged
4. Your contribution will be credited in the commit history

## Areas Where Help is Needed

We especially welcome contributions in these areas:

- **Documentation**: Improving clarity for beginners
- **Examples**: Adding more real-world scenarios
- **Cost optimization**: Tips for reducing AWS costs
- **Troubleshooting**: Common issues and solutions
- **CI/CD**: GitHub Actions workflows for testing
- **Monitoring**: Prometheus, Grafana examples
- **Security**: Best practices and examples
- **Multi-cloud**: Support for GCP, Azure

## Questions or Issues?

- **Questions**: Open a GitHub issue with the "question" label
- **Bug reports**: Open an issue with detailed reproduction steps
- **Feature requests**: Open an issue describing the feature and use case
- **Security issues**: Email the repository owner directly

## Code of Conduct

### Our Pledge

This is a learning environment. We are committed to providing a welcoming and inclusive experience for everyone.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and beginners
- Provide constructive feedback
- Focus on what's best for the learning community
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discriminatory language
- Trolling or insulting comments
- Personal or political attacks
- Publishing others' private information
- Any conduct that could be considered inappropriate in a professional setting

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).

## Recognition

Contributors are recognized in:
- Git commit history
- GitHub contributors list
- Release notes (for significant contributions)

Thank you for contributing to help others learn Kubernetes and Terraform!
