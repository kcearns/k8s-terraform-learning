# Codespaces Environment Variables Template

This file lists the environment variables (secrets) you need to configure in GitHub Codespaces for this repository.

## How to Add Environment Variables

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. In the left sidebar: **Secrets and variables** → **Codespaces**
4. Click **New repository secret** for each environment variable below

## Required Environment Variables for AWS/EKS

### AWS_ACCESS_KEY_ID
- **Type**: String
- **Required**: Yes (for EKS clusters)
- **Description**: Your AWS Access Key ID
- **Example**: `AKIAIOSFODNN7EXAMPLE`
- **How to get**: AWS Console → IAM → Users → [Your User] → Security credentials → Create access key

### AWS_SECRET_ACCESS_KEY
- **Type**: String
- **Required**: Yes (for EKS clusters)
- **Description**: Your AWS Secret Access Key
- **Example**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
- **How to get**: Created together with AWS_ACCESS_KEY_ID (only shown once!)

### AWS_DEFAULT_REGION
- **Type**: String
- **Required**: No
- **Default**: `us-east-1`
- **Description**: Your preferred AWS region
- **Example**: `us-east-1`, `us-west-2`, `eu-west-1`, etc.
- **Tip**: Choose a region close to you for better latency

## Verification

After adding secrets:

1. Stop any running Codespaces
2. Create a new Codespace or reopen existing one
3. Once ready, run in terminal:
   ```bash
   aws sts get-caller-identity
   ```

You should see your AWS account information if configured correctly.

## Security Notes

⚠️ **Important Security Practices:**

- **Never** commit these values to your code
- **Never** share these values with anyone
- **Rotate** your access keys regularly (every 90 days)
- **Use** IAM users, not root account credentials
- **Delete** access keys you're not using
- **Enable** MFA (Multi-Factor Authentication) on your AWS account

## Troubleshooting

### Environment variables not being applied
- Make sure variables are in **Codespaces** section, NOT Actions
- Variable names must be exact (case-sensitive)
- After adding variables, completely restart Codespace (don't just rebuild)

### Still having issues?
See the complete setup guide: [AWS-SETUP.md](../AWS-SETUP.md)

## Alternative: Manual Configuration

If you prefer not to use Codespaces environment variables, you can always configure AWS manually in your Codespace:

```bash
aws configure
```

This will prompt you interactively for your credentials.

---

For more information, see [AWS-SETUP.md](../AWS-SETUP.md)
