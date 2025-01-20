# Biến đầu vào (Input Variables)
variable "Project_name" {
  description = "Name of Project"
  type        = string
  default     = ""
}

variable "Project_code" {
  description = "Code of Project"
  type        = string
  default     = ""
}

variable "Department" {
  description = "Code of Project"
  type        = string
  default     = ""
}

variable "Project_Manager" {
  description = "Manager of Project"
  type        = string
  default     = ""
}

variable "Requested_by" {
  description = "Requester"
  type        = string
  default     = ""
}

variable "Created_by" {
  description = "Resource creator"
  type        = string
  default     = "dinh.luu@ntte-moi.com"
}

variable "Environment" {
  description = "Environment"
  type        = string
  default     = ""
}

variable "Bucket_Access_Logging" {
  description = "Bucket stores logs"
  type        = string
  default     = ""
}

variable "s3_bucket_names" {
  description = "List of S3 bucket names"
  type        = list(string)
  default     = []
}

# Biến cục bộ (Local Variables)
locals {
  # Tên người dùng IAM, được tạo từ môi trường và tên dự án
  iam_user_name = "${var.Environment}-${var.Project_name}"
}

locals {
  # Các thẻ chung cho tài nguyên, bao gồm thông tin về dự án, bộ phận, người quản lý, người yêu cầu và người tạo
  common_tags = {
    ProjectName = var.Project_name
    ProjectCode = var.Project_code
    ProjectManager = var.Project_Manager
    Department = var.Department
    RequestedBy = var.Requested_by
    CreatedBy = var.Created_by
  }
}

locals {
  # Danh sách các tên bucket S3, được tạo từ môi trường và tên bucket
  bucket_name = [for bucket in var.s3_bucket_names : "${var.Environment}-${bucket}"]
}

locals {
  # Chính sách IAM cho người dùng dự án, cho phép truy cập vào các bucket cụ thể
  policy_for_project_user = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "BucketPolicyAllowSpecificBucket",
        Action   = [
          "s3:PutObject", 
          "s3:GetObject", 
          "s3:DeleteObject", 
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = flatten([
          for bucket in local.bucket_name : [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ]
        ])
      }
    ]
  })
}

locals {
  # Chính sách IAM cho người dùng cá nhân, cho phép truy cập vào các bucket cụ thể và liệt kê tất cả các bucket
  policy_for_individual_user = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "BucketPolicyAllowSpecificBucket",
        Action   = [
          "s3:PutObject", 
          "s3:GetObject", 
          "s3:DeleteObject", 
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = flatten([
          for bucket in local.bucket_name : [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ]
        ])
      },
      {
        Sid      = "BucketPolicyAllowListAllBucket",
        Action   = [
          "s3:ListAllMyBuckets"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

locals {
  # Chính sách IAM cho bucket, từ chối tất cả các hành động trừ khi người dùng có thẻ Department là "SRE" hoặc ARN của người dùng khớp với ARN của người dùng cụ thể
  policy_for_bucket = {
    for bucket in local.bucket_name : bucket => jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid      = "BucketPolicyDeny",
          Action   = "s3:*",
          Effect   = "Deny",
          Principal = "*",
          Resource = [
            "arn:aws:s3:::${bucket}",
            "arn:aws:s3:::${bucket}/*"
          ],
          Condition = {
            StringNotEquals = {
              "aws:PrincipalTag/Department" = "SRE"
            },
            ArnNotEquals = {
              "aws:PrincipalArn" = aws_iam_user.user-01.arn
            }
          }
        }
      ]
    })
  }
}