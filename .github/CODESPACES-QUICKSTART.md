# GitHub Codespaces Quick Start

Get up and running with this repository in GitHub Codespaces in minutes!

## 🚀 Quick Setup

### Step 1: Configure AWS Credentials (Optional - for EKS clusters)

If you plan to use AWS EKS clusters, set up your AWS credentials **before** creating the Codespace:

1. Go to your repository → **Settings** → **Secrets and variables** → **Codespaces**
2. Add these secrets:
   - `AWS_ACCESS_KEY_ID` - Your AWS Access Key ID
   - `AWS_SECRET_ACCESS_KEY` - Your AWS Secret Access Key  
   - `AWS_DEFAULT_REGION` (optional) - e.g., `us-east-1`

> 📖 **Need help?** See the complete guide: [AWS-SETUP.md](../AWS-SETUP.md)

### Step 2: Create Your Codespace

1. Click the green **Code** button
2. Select **Codespaces** tab
3. Click **Create codespace on main** (or your branch)

The Codespace will:
- Build the development container (~5-10 minutes first time)
- Install kubectl, eksctl, terraform, AWS CLI, and other tools
- Automatically configure AWS credentials if you set up the secrets

### Step 3: Verify Setup

Once your Codespace is ready, open a terminal and run:

```bash
# Check tools are installed
kubectl version --client
eksctl version
aws --version

# If you configured AWS credentials, verify them:
aws sts get-caller-identity
```

Expected output for AWS verification:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

## 🎯 What to Do Next

### Option 1: Local Development (Free)

Start with a local Kubernetes cluster using Kind:

```bash
# Create local cluster
just kind

# Deploy sample app
just nginx

# View cluster with k9s
k9s

# Clean up
just teardown
```

### Option 2: AWS EKS Cluster (AWS costs apply)

Create a cloud-based Kubernetes cluster on AWS:

```bash
# Create development EKS cluster (cost-optimized)
just eks-create-dev

# Update kubectl context
just eks-update-kubeconfig-dev

# Deploy sample app
just nginx

# ⚠️ IMPORTANT: Clean up when done to avoid charges
just eks-delete-dev
```

## 🔧 Manual AWS Configuration

If you didn't set up Codespaces secrets, you can configure AWS manually:

```bash
aws configure
```

You'll be prompted for:
- AWS Access Key ID
- AWS Secret Access Key
- Default region (e.g., us-east-1)
- Output format (json)

## 📚 Documentation

- **[AWS-SETUP.md](../AWS-SETUP.md)** - Complete AWS credentials setup guide
- **[README.md](../README.md)** - Main project documentation
- **[.devcontainer/README.md](../.devcontainer/README.md)** - Development environment details
- **[eksctl/README.md](../eksctl/README.md)** - EKS cluster management
- **[NEXTJS-DEPLOYMENT-GUIDE.md](../NEXTJS-DEPLOYMENT-GUIDE.md)** - Deploy Next.js on EKS

## ❓ Troubleshooting

### Codespace won't start
- Try rebuilding the container: Press `F1` → "Codespaces: Rebuild Container"

### AWS credentials not working
- Verify secrets are in **Codespaces** section (not Actions secrets)
- Restart the Codespace completely
- Check secrets are named exactly: `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`

### Tools not found
- Re-run setup: `sudo bash .devcontainer/setup.sh`

## 💡 Tips

1. **Use `just` for common tasks**: Run `just --list` to see all available commands
2. **Keep k9s open**: It provides a great real-time view of your cluster
3. **Start local first**: Test with Kind before moving to expensive AWS clusters
4. **Watch costs**: Always delete EKS clusters when done learning

## 🔒 Security Reminder

- Never commit AWS credentials to code
- Use Codespaces secrets for automatic configuration
- Rotate AWS access keys regularly
- Delete test clusters immediately after use

---

Need more help? Check out the full documentation or open an issue!
