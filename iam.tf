# resource "aws_iam_user" "individual_user" {
#   name = local.iam_user_name
#   tags = local.common_tags
#   path = "/department/${var.Department}/"
# }

# resource "aws_iam_user_policy" "individual_user_policy" {
#   name   = "S3PermissionFor-${local.iam_user_name}"
#   user   = aws_iam_user.individual_user.name
#   policy = local.policy_for_individual_user
# }
resource "aws_iam_user" "project_user" {
  name = local.iam_user_name
  tags = local.common_tags
  path = "/project/${var.Project_name}/"
}

resource "aws_iam_user_policy" "project_user_policy" {
  name   = "S3PermissionFor-${local.iam_user_name}"
  user   = aws_iam_user.project_user.name
  policy = local.policy_for_project_user
}

# # Enable console login
# resource "aws_iam_user_login_profile" "user-01_profile" {
#   user = aws_iam_user.user-01.name
# }

resource "aws_iam_user_policy_attachment" "name" {
  user = aws_iam_user.user-01.name
  policy_arn = "arn:aws:iam::334061921670:policy/dev_SourceIP_Control_FrontEnd_OS"
}

resource "aws_iam_access_key" "user-01_accesskey" {
  user    = aws_iam_user.user-01.name
}
