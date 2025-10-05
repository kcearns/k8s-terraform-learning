# AWS Credentials Setup for GitHub Codespaces

This guide explains how to configure your AWS credentials so that `aws` and `eksctl` commands work with your AWS account in GitHub Codespaces.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Method 1: GitHub Codespaces Secrets (Recommended)](#method-1-github-codespaces-secrets-recommended)
- [Method 2: Manual Configuration](#method-2-manual-configuration)
- [Verification](#verification)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, you need:

1. **An AWS Account** - [Create one here](https://aws.amazon.com/) if you don't have one
2. **AWS Access Keys** - Follow these steps to create them:
   - Sign in to the [AWS Console](https://console.aws.amazon.com/)
   - Navigate to IAM → Users → Your User → Security credentials
   - Click "Create access key"
   - Select "Command Line Interface (CLI)" as the use case
   - Download or copy your Access Key ID and Secret Access Key
   - ⚠️ **Important**: Store these securely - the Secret Access Key is only shown once!

## Method 1: GitHub Codespaces Secrets (Recommended)

This method automatically configures AWS credentials when your Codespace starts. It's the most secure and convenient option.

### Step 1: Add Secrets to Your Repository

1. Go to your GitHub repository
2. Click **Settings** (in the repository menu)
3. In the left sidebar, expand **Secrets and variables** → click **Codespaces**
4. Click **New repository secret**
5. Add the following secrets:

#### Required Secrets:

| Secret Name | Value | Example |
|-------------|-------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |

#### Optional Secret:

| Secret Name | Value | Default | Example |
|-------------|-------|---------|---------|
| `AWS_DEFAULT_REGION` | Your preferred AWS region | `us-east-1` | `us-west-2` |

### Step 2: Restart Your Codespace

If your Codespace is already running:
1. Stop the current Codespace
2. Start a new Codespace or reopen the existing one

The credentials will be automatically configured during setup!

### Step 3: Verify Configuration

Open a terminal in your Codespace and run:

```bash
aws sts get-caller-identity
```

You should see output like:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

## Method 2: Manual Configuration

If you prefer not to use Codespaces secrets, you can manually configure AWS credentials.

### Option A: Using `aws configure`

```bash
aws configure
```

You'll be prompted to enter:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-east-1`)
- Default output format (e.g., `json`)

### Option B: Using Environment Variables

Add these to your shell session:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

To make these persistent across sessions, add them to your `~/.bashrc` or `~/.zshrc`:

```bash
echo 'export AWS_ACCESS_KEY_ID="your-access-key-id"' >> ~/.bashrc
echo 'export AWS_SECRET_ACCESS_KEY="your-secret-access-key"' >> ~/.bashrc
echo 'export AWS_DEFAULT_REGION="us-east-1"' >> ~/.bashrc
source ~/.bashrc
```

### Option C: Manual Credentials File

Create/edit the AWS credentials file:

```bash
mkdir -p ~/.aws
nano ~/.aws/credentials
```

Add your credentials:

```ini
[default]
aws_access_key_id = your-access-key-id
aws_secret_access_key = your-secret-access-key
```

Create/edit the AWS config file:

```bash
nano ~/.aws/config
```

Add your region:

```ini
[default]
region = us-east-1
output = json
```

Set proper permissions:

```bash
chmod 600 ~/.aws/credentials
chmod 600 ~/.aws/config
```

## Verification

After configuring credentials using any method, verify they work:

### 1. Check AWS Identity

```bash
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/your-username"
}
```

### 2. List S3 Buckets (Optional)

```bash
aws s3 ls
```

This verifies your credentials have basic AWS permissions.

### 3. Test eksctl

```bash
eksctl get clusters --region us-east-1
```

This should list any existing EKS clusters (or return empty if you have none).

## Security Best Practices

### ✅ DO:

1. **Use IAM Users with Limited Permissions**: Don't use root account credentials
2. **Create Access Keys for CLI/API Use**: Generate keys specifically for programmatic access
3. **Use Codespaces Secrets**: Store credentials in GitHub Codespaces secrets, not in code
4. **Rotate Keys Regularly**: Change your access keys periodically
5. **Enable MFA**: Add multi-factor authentication to your AWS account
6. **Use Least Privilege**: Only grant necessary permissions

### ❌ DON'T:

1. **Never Commit Credentials**: Don't put credentials in code or configuration files
2. **Don't Share Keys**: Each developer should have their own AWS credentials
3. **Don't Use Root Keys**: Create IAM users instead
4. **Don't Leave Keys in Public Repos**: Always use secrets management
5. **Don't Hardcode Credentials**: Use environment variables or AWS secrets

### Recommended IAM Permissions

For learning and development with EKS, your IAM user should have these permissions:

- `AmazonEKSClusterPolicy`
- `AmazonEKSWorkerNodePolicy`
- `AmazonEC2ContainerRegistryFullAccess`
- `IAMFullAccess` (for eksctl to create service roles)
- `AmazonVPCFullAccess` (for eksctl to create VPCs)

Or create a custom policy with these permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "cloudformation:*",
        "elasticloadbalancing:*",
        "autoscaling:*"
      ],
      "Resource": "*"
    }
  ]
}
```

**Note**: These are broad permissions suitable for learning. In production, use more restrictive policies.

## Troubleshooting

### Problem: "Unable to locate credentials"

**Solution**: Ensure credentials are configured properly:

```bash
# Check if credentials file exists
ls -la ~/.aws/

# View credentials (be careful not to share output)
cat ~/.aws/credentials

# Re-run configuration
aws configure
```

### Problem: "An error occurred (UnauthorizedOperation)"

**Solution**: Your IAM user doesn't have sufficient permissions. Check:

1. Your IAM user has the necessary policies attached
2. Your access key is active (check in AWS Console → IAM → Users → Security credentials)

### Problem: Codespaces secrets not being applied

**Solution**:

1. Verify secrets are added to **Codespaces** (not Actions secrets)
2. Restart your Codespace completely (don't just rebuild)
3. Check the setup log during Codespace creation:
   ```bash
   # Check if secrets are available
   env | grep AWS
   ```

### Problem: "Access Denied" when creating EKS cluster

**Solution**:

1. Ensure your IAM user has EKS and related service permissions
2. Check if your region is correct
3. Verify your AWS account has no service limits preventing cluster creation

### Problem: Credentials work but eksctl fails

**Solution**:

```bash
# Verify eksctl is installed
eksctl version

# Check eksctl can access AWS
eksctl get clusters --region us-east-1

# Update eksctl if needed
sudo rm /usr/local/bin/eksctl
curl -Lo eksctl.tar.gz "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz"
tar -xzf eksctl.tar.gz
sudo mv eksctl /usr/local/bin/
```

## Next Steps

Once your AWS credentials are configured:

1. **Create a local cluster first** (free):
   ```bash
   just kind
   just nginx
   ```

2. **Then try EKS** (AWS costs apply):
   ```bash
   just eks-create-dev
   just eks-update-kubeconfig-dev
   just nginx
   ```

3. **Don't forget to clean up**:
   ```bash
   just eks-delete-dev
   ```

## Additional Resources

- [AWS CLI Configuration Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html)
- [GitHub Codespaces Secrets Documentation](https://docs.github.com/en/codespaces/managing-your-codespaces/managing-encrypted-secrets-for-your-codespaces)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [eksctl Documentation](https://eksctl.io/)
- [AWS Free Tier](https://aws.amazon.com/free/) - Learn about free tier eligible services

## Support

If you encounter issues not covered here:

1. Check the [eksctl documentation](https://eksctl.io/)
2. Review AWS CloudTrail logs for permission errors
3. Consult the [AWS CLI troubleshooting guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-troubleshooting.html)
