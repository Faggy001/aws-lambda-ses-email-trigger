# 📧 Automated Email Notifications using AWS Lambda and SES

This project implements an automated serverless system that sends alert emails via AWS SES whenever an IAM user's access key is approaching expiration. The notification is triggered via API Gateway, powered by a Python-based AWS Lambda function.

## Architecture

![Architecture Diagram](./architecture.png)

**Components:**

- **AWS Lambda** (Python): Checks IAM user access keys and sends warning emails via SES.

- **AWS SES**: Sends the email. Configured in Sandbox mode.

- **API Gateway**: Exposes an HTTP POST endpoint to trigger the Lambda.

- **CloudWatch Logs**: Captures logs for Lambda execution and debugging.

- **Terraform**: Provisions all infrastructure.


## Features

- 📩 Email alerts before IAM access key expiration (default 10 days before)
- 🧪 SES Sandbox-compatible (both sender and receiver must be verified)
- 🔐 Uses environment variables to configure IAM user, email recipients, etc.
- 🛠 Fully managed using Terraform


---

## 🚀 How It Works

1. You trigger the API Gateway endpoint via HTTP `POST`
2. The Lambda runs:
   - Lists IAM access keys for the specified user
   - Calculates key age
   - If any key is expiring soon, it sends an email using SES
3. If no keys are near expiry, it returns a quiet message

---

## ⚙️ Setup Instructions

### 1. Prerequisites

- AWS CLI configured (`aws configure`)
- Verified AWS SES email addresses (sender and recipient)
- IAM user with at least 1 active access key
- Python 3.12 for Lambda runtime


### 2. Update Your Config

Edit `terraform/terraform.tfvars`:
sender_email    = "@gmail.com"
recipient_email = "@gmail.com"
iam_user        = ""
expiry_days     = 90

