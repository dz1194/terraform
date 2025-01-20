resource "aws_s3_bucket" "example" {
  for_each = toset(local.bucket_name)

  bucket = each.key
  tags = local.common_tags
  
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  for_each = aws_s3_bucket.example
  bucket = each.value.id
  policy = local.policy_for_bucket[each.key]
}

resource "aws_s3_bucket_logging" "example" {
  for_each = aws_s3_bucket.example
  bucket = each.value.id
  target_bucket = var.Bucket_Access_Logging
  target_prefix = ""
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}
