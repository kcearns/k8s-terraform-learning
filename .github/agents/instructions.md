# AI Agent Instructions for k8s-terraform-learning

This file provides guidance for AI agents working on this repository.

## Repository Overview

This is a **learning repository** designed to help people learn Kubernetes and Terraform through hands-on examples. The primary audience is beginners and intermediate users who want to understand:

- Kubernetes cluster management
- Infrastructure as Code with Terraform
- AWS EKS deployment
- Local development with Kind
- Container orchestration concepts

## Project Structure

```
├── .devcontainer/         # VS Code development container configuration
├── .github/               # GitHub-specific files (workflows, agents)
├── docker/                # Docker container configurations (nginx examples)
├── eksctl/                # EKS cluster configurations using eksctl
├── k8s/                   # Kubernetes manifests and Kind configuration
├── terraform/             # Terraform IaC for EKS clusters
├── justfile              # Command shortcuts using just
├── README.md             # Main project documentation
├── CONTRIBUTING.md       # Contribution guidelines
└── CLUSTER-COMPARISON.md # Comparison of different cluster approaches
```

## Core Principles

When working on this repository, always keep these principles in mind:

1. **Educational Focus**: Changes should enhance learning. Add comments, explanations, and documentation.
2. **Beginner-Friendly**: Assume users are learning. Provide clear examples and avoid advanced concepts without explanation.
3. **Cost-Conscious**: This is for learners who may have limited AWS budgets. Optimize for minimal costs (t2.micro, spot instances, etc.).
4. **Working Examples**: All code must be tested and functional. Broken examples harm learning.
5. **Multiple Paths**: Support three learning paths: Kind (local), eksctl (quick cloud), Terraform (IaC).

## Code Style Guidelines

### Kubernetes Manifests (YAML)
- Use 2 spaces for indentation
- Include resource limits and requests
- Add meaningful labels (app, component, environment)
- Include comments for complex configurations
- Follow Kubernetes best practices

### Terraform Code
- Use descriptive variable names
- Include default values where appropriate
- Add comments explaining "why" not just "what"
- Follow HashiCorp style guide
- Use terraform fmt before committing

### Shell Scripts
- Use `#!/usr/bin/env bash` shebang
- Include error handling (`set -e` for critical scripts)
- Add comments for complex logic
- Test scripts locally before committing

### Markdown Documentation
- Use clear, simple language
- Include code examples with proper syntax highlighting
- Use proper heading hierarchy (##, ###, ####)
- Keep lines under 120 characters when reasonable
- Add blank lines between sections for readability

## Testing Requirements

Before submitting changes:

### Kubernetes Manifests
```bash
# Validate syntax
kubectl apply --dry-run=client -f k8s/manifests/your-file.yaml

# Test in Kind cluster (if applicable)
just kind
kubectl apply -f k8s/manifests/your-file.yaml
kubectl get all
```

### Terraform Configurations
```bash
cd terraform
terraform fmt -check    # Check formatting
terraform validate      # Validate syntax
terraform plan          # Preview changes (if possible)
```

### eksctl Configurations
```bash
# Validate syntax
eksctl create cluster --dry-run -f eksctl/your-config.yaml
```

### Shell Scripts
```bash
# Check syntax
bash -n your-script.sh

# Run with dry-run if available
./your-script.sh --dry-run
```

## Common Tasks and Approaches

### Adding New Kubernetes Examples
1. Create manifest in `k8s/manifests/`
2. Test with Kind cluster locally
3. Update `k8s/README.md` with usage instructions
4. Consider adding a `just` command for easy deployment

### Updating Infrastructure Code
1. Check both eksctl and Terraform versions for consistency
2. Test changes in a development environment if possible
3. Update relevant README files
4. Consider cost implications of changes

### Documentation Updates
1. Ensure accuracy - test all commands
2. Provide context for why something is done a certain way
3. Include expected output where helpful
4. Link to official documentation for deeper learning

### Adding New Tools or Features
1. Add to `.devcontainer/setup.sh` if it's a common tool
2. Document installation in relevant README
3. Update justfile with convenient commands
4. Explain use case and when to use it

## Important Constraints

### Do Not
- Add expensive AWS resources without clear warnings
- Remove working examples without replacement
- Add complex abstractions that obscure learning
- Include secrets, credentials, or personal information
- Break existing functionality
- Add dependencies without clear justification

### Do
- Provide clear examples with explanations
- Include cost estimates for AWS resources
- Test all changes thoroughly
- Update documentation alongside code changes
- Consider the learning experience
- Use existing patterns and conventions

## File-Specific Guidelines

### justfile
- Commands should be simple and self-documenting
- Include comments explaining what each command does
- Test commands before committing
- Follow existing naming conventions (kebab-case)

### .devcontainer/setup.sh
- Pin versions to avoid breaking changes
- Include verification steps
- Handle errors gracefully
- Keep installation order logical (dependencies first)

### terraform/main.tf
- Use modules for reusability when appropriate
- Comment complex data sources and logic
- Include tags for AWS resources
- Use variables for customization

### k8s/manifests/
- Each manifest should be deployable independently
- Include namespace if not using default
- Add labels for service discovery
- Resource requests/limits are required

## Version Compatibility

Current versions (update as needed):
- Kubernetes: 1.33
- Terraform: ~> 5.0 (AWS provider)
- eksctl: latest stable
- Kind: latest stable
- AWS CLI: v2

When updating versions:
1. Test thoroughly in development
2. Update all relevant documentation
3. Check for breaking changes
4. Update version constraints in code

## AWS Resource Management

### EKS Clusters
- Default to t2.micro (free tier eligible)
- Use managed node groups
- Support auto-scaling (1-3 nodes typically)
- Tag all resources appropriately
- Document cleanup procedures

### Networking
- Use default VPC for simplicity
- Support both public and private subnets
- Document security group configurations
- Avoid opening unnecessary ports

## Git Commit Messages

Follow these patterns:
- `Add [feature]` - New functionality
- `Update [component]` - Modify existing code
- `Fix [issue]` - Bug fixes
- `Docs: [description]` - Documentation only
- `Refactor: [description]` - Code restructuring

Examples:
- `Add Prometheus monitoring example`
- `Update EKS cluster to Kubernetes 1.33`
- `Fix typo in terraform README`
- `Docs: Add troubleshooting section for Kind`

## Resources and References

Key external documentation:
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [eksctl Documentation](https://eksctl.io/)
- [Kind Documentation](https://kind.sigs.k8s.io/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)

## Questions and Clarifications

When unsure:
1. Check existing patterns in the repository
2. Refer to CONTRIBUTING.md for guidelines
3. Look at similar examples in the codebase
4. Prioritize educational value and clarity
5. Test thoroughly before submitting

## Special Considerations

### For AI Agents Specifically

1. **Preserve Learning Value**: When refactoring or updating, maintain or improve the educational value. If you're abstracting complexity, add comments explaining what you're abstracting and why.

2. **Cost Awareness**: Always consider AWS costs. When suggesting infrastructure changes, note the cost implications.

3. **Testing Limitations**: The devcontainer provides tools, but you may not have AWS credentials. Document testing steps for users to verify.

4. **Version Pinning**: When adding dependencies, pin versions to avoid unexpected breakage for learners.

5. **Documentation First**: If you're adding something complex, start with documentation explaining the concept before showing the implementation.

6. **No Breaking Changes**: This repository may be actively used by learners. Avoid breaking changes unless absolutely necessary, and document migration paths clearly.

## Success Criteria

A good change to this repository:
- ✅ Is thoroughly tested
- ✅ Includes updated documentation
- ✅ Follows existing code style
- ✅ Enhances learning value
- ✅ Considers cost implications
- ✅ Works with existing examples
- ✅ Is explained clearly for beginners
- ✅ Has no hardcoded secrets
- ✅ Includes helpful comments
- ✅ Can be easily cleaned up/removed

---

Remember: This repository exists to help people learn. Every change should make that learning experience better, clearer, or more accessible.
