# SpectaclesXR

Snapchat Spectacles lens for teleop of Unitree humanoid robot.

- Server: Python (mocked connection)
- Client: Snapchat Spectacles lens

## Deployment

This devcontainer has Terraform and the AWS CLI installed.

1. Configure AWS CLI, and log in using a profile called `tf`.
   ```
   aws configure
   ```
2. Change Terraform variable defaults if needed.
3. Bootstrap essentials on AWS:
   ```
   aws s3api create-bucket \
      --bucket spectaclesxr-terraform-state \
      --region us-west-1 \
      --create-bucket-configuration LocationConstraint=us-west-1
   ```
   ```
   aws s3api put-bucket-encryption \
      --bucket spectaclesxr-terraform-state \
      --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
   ```
   ```
   aws s3api put-bucket-versioning \
      --bucket spectaclesxr-terraform-state \
      --versioning-configuration Status=Enabled
   ```
   ```
   aws dynamodb create-table \
      --table-name spectaclesxr-terraform-lock \
      --attribute-definitions AttributeName=LockID,AttributeType=S \
      --key-schema AttributeName=LockID,KeyType=HASH \
      --billing-mode PAY_PER_REQUEST \
      --region us-west-1
   ```
4. Deploy!
   ```
   export AWS_PROFILE=tf && \
   terraform init && \
   terraform apply
   ```
5. Copy outputs for 