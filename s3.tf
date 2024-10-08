resource "aws_s3_bucket" "websites3test" {
  lifecycle {
    ignore_changes = [
      tags,
      replication_configuration,
      server_side_encryption_configuration
    ]
  }
  provider = aws.noregion
  bucket = "websites3test"
  acl = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = <<RULES
[{
   "Condition": {
       "HttpErrorCodeReturnedEquals": "404"
   },
   "Redirect": {
       "HostName": "search.nyansq.ru",
       "HttpRedirectCode": "301",
       "Protocol": "https"
   }
}]
RULES
  }
}

data "local_file" "foo" {
  filename = "${path.module}/krol.txt"
}

resource "aws_s3_object" "krol" {
  depends_on = [
    aws_s3_bucket.websites3test
  ]
  provider = aws.noregion
  bucket  = "websites3test"
  key     = "krol.txt"
  content = data.local_file.foo.content
}
