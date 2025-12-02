# IP Allocation - Terraform + GitHub Actions

This project deploys 5 EC2 instances on AWS with advanced networking configuration using Terraform and automates deployment via GitHub Actions.

## Architecture Overview

Each EC2 instance is configured with:
- **Primary Network Interface**: 3 private IPs (1 primary + 2 secondary)
- **Secondary Network Interface**: 1 private IP
- **2 Elastic IPs**: One associated to each network interface for public internet access

This configuration provides each instance with **3 private IPs** and **2 public IPs (EIPs)**.

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml          # GitHub Actions CI/CD pipeline
├── terraform/
│   ├── main.tf                    # Root module - VPC, IGW, subnets, SG
│   ├── variables.tf               # Variable definitions
│   ├── outputs.tf                 # Output definitions
│   ├── terraform.tfvars.example   # Example variables file
│   └── modules/
│       └── ec2/
│           ├── main.tf            # EC2 instances, ENIs, and EIPs
│           ├── variables.tf       # Module variables
│           └── outputs.tf         # Module outputs
└── README.md
```

## Prerequisites

### Local Development
- Terraform >= 1.0
- AWS CLI configured with credentials
- AWS account with appropriate permissions

### GitHub Actions
- GitHub repository with secrets configured:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## Setup Instructions

### 1. Clone and Configure

```bash
git clone <repository-url>
cd ip_allocation
```

### 2. Create terraform.tfvars

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your desired values:

```hcl
aws_region = "us-east-1"
instance_count = 5
instance_type = "t3.micro"
environment = "production"
project_name = "ip-allocation"
```

### 3. Local Deployment

Initialize Terraform:
```bash
cd terraform
terraform init
```

Review the plan:
```bash
terraform plan
```

Apply the configuration:
```bash
terraform apply
```

### 4. GitHub Actions Setup

#### Add AWS Credentials to GitHub Secrets

1. Go to your GitHub repository → Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your AWS access key
   - `AWS_SECRET_ACCESS_KEY`: Your AWS secret key

#### Trigger Deployment

The GitHub Actions workflow (`terraform.yml`) automatically runs on:
- **Push to main branch**: Executes `terraform apply`
- **Pull requests**: Executes `terraform plan` for review

Push to main to trigger deployment:
```bash
git push origin main
```

## Terraform Configuration Details

### Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | us-east-1 | AWS region |
| `instance_count` | number | 5 | Number of EC2 instances |
| `instance_type` | string | t3.micro | EC2 instance type |
| `ami` | string | ami-0c02fb55956c7d316 | Amazon Linux 2 AMI ID |
| `environment` | string | production | Environment name |
| `project_name` | string | ip-allocation | Project name |

### Resources Created

#### Root Module (main.tf)
- **VPC**: 10.0.0.0/16 CIDR block
- **Internet Gateway**: For public internet access
- **Public Subnet**: 10.0.1.0/24
- **Route Table**: Routes 0.0.0.0/0 to IGW
- **Security Group**: Allows SSH (22), HTTP (80), HTTPS (443)

#### EC2 Module
- **5 EC2 Instances**: With primary and secondary network interfaces
- **5 Primary ENIs**: Each with 3 private IPs
- **5 Secondary ENIs**: Each with 1 private IP
- **10 Elastic IPs**: 2 per instance (5 primary + 5 secondary)

## Outputs

### Terraform Outputs

After applying the configuration, retrieve outputs:

```bash
terraform output
```

Key outputs include:
- `instances`: Detailed instance information
- `instance_summary`: Summary of all instances with IPs
- `vpc_id`: VPC ID
- `subnet_id`: Public subnet ID
- `security_group_id`: Security group ID

### Instance Details

Each instance includes:
```json
{
  "instance_id": "i-xxx",
  "primary_eni": {
    "eni_id": "eni-xxx",
    "private_ips": ["10.0.1.x", "10.0.1.y", "10.0.1.z"],
    "eip": "1.2.3.4",
    "eip_id": "eipalloc-xxx"
  },
  "secondary_eni": {
    "eni_id": "eni-yyy",
    "private_ip": "10.0.1.a",
    "eip": "5.6.7.8",
    "eip_id": "eipalloc-yyy"
  }
}
```

## GitHub Actions Workflow Details

### Workflow Steps

1. **Checkout**: Clone repository
2. **Setup Terraform**: Install specified Terraform version
3. **Configure AWS**: Set up AWS credentials from secrets
4. **Format Check**: Validate Terraform code formatting
5. **Init**: Initialize Terraform backend
6. **Validate**: Validate Terraform configuration
7. **Plan**: Generate execution plan
8. **Save Artifact**: Upload plan for PR review
9. **Apply**: Execute only on main branch push
10. **Output**: Display infrastructure details

### Workflow Triggers

- **On Push to main**: Applies infrastructure changes
- **On Pull Requests**: Plans changes for review

## State Management

### Local State (Development)
By default, state is stored locally in `terraform.tfstate`.

### Remote State (Production Recommended)

To use S3 backend, uncomment in `terraform/main.tf`:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "ip-allocation/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

Create S3 bucket and DynamoDB table first:

```bash
aws s3api create-bucket --bucket your-terraform-state-bucket --region us-east-1
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

## Cleanup

### Destroy Infrastructure

```bash
cd terraform
terraform destroy
```

To destroy via GitHub Actions, update the workflow to include a destroy job trigger (manual workflow dispatch recommended).

## Troubleshooting

### Common Issues

#### 1. "InvalidAMIID.NotFound" Error
- The AMI ID may not exist in your region
- Update `ami` variable in `terraform.tfvars`
- Find valid AMI: `aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2"`

#### 2. "InsufficientInstanceCapacity" Error
- Try different instance type or availability zone
- Update `instance_type` variable

#### 3. GitHub Actions Secrets Not Found
- Ensure `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` are added to repository secrets
- Verify secret names match exactly

#### 4. Terraform State Lock
- Check for incomplete apply operations
- DynamoDB item might be stuck; manually clear if needed

## Security Considerations

1. **Secrets Management**: Never commit AWS credentials or tfvars with real values
2. **State File**: Use S3 with encryption and versioning for production
3. **IAM Policies**: Limit IAM user permissions to required services
4. **Security Groups**: Restrict ingress rules based on your needs
5. **source_dest_check**: Currently disabled; enable for security if not needed for routing

## Monitoring and Logging

### CloudWatch
Instances have monitoring enabled. View metrics in AWS CloudConsole:
- CPU Utilization
- Network In/Out
- Disk Read/Write

### GitHub Actions Logs
View workflow execution logs in GitHub:
- Actions tab → Workflow run → View details

## Next Steps

1. Configure remote state (S3 + DynamoDB)
2. Add CloudWatch monitoring dashboards
3. Implement auto-scaling groups
4. Add load balancer for multi-instance traffic
5. Implement CI/CD for application deployment on instances

## Support

For issues or questions:
1. Check Terraform documentation: https://www.terraform.io/docs
2. Review AWS documentation: https://docs.aws.amazon.com
3. Check GitHub Actions docs: https://docs.github.com/en/actions

## License

MIT
