#Backend configuration for Terraform Cloud 
terraform {
 cloud {
   organization = "Shirubia"

   workspaces {
     name = "TestAPI"
   }
 }
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.59.0"
    }
  }
}

provider "aws" {
    region      =var.region
    access_key  =var.access_key
    secret_key  =var.secret_key
}    

# resource "aws_s3_bucket" "bucket" {
#   bucket = "myblogexample-${random_string.random.result}"
#   force_destroy = true
# }
# resource "aws_s3_bucket_website_configuration" "blog" {
#   bucket = aws_s3_bucket.bucket.id
#   index_document {
#     suffix = "index.html"
#   }
#   error_document {
#     key = "error.html"
#   }
# }
# resource "aws_s3_bucket_public_access_block" "public_access_block" {
#   bucket = aws_s3_bucket.bucket.id
#   block_public_acls       = false
#   block_public_policy     = false
#   ignore_public_acls      = false
#   restrict_public_buckets = false
# }

# resource "aws_s3_object" "upload_object" {
#   for_each      = fileset("${path.module}/../html", "*")
#   bucket        = aws_s3_bucket.bucket.bucket
#   key           = each.value
#   source        = "${path.module}/../html/${each.value}"
#   etag          = filemd5("${path.module}/../html/${each.value}")
#   content_type  = "text/html"
# }

# resource "aws_s3_bucket_policy" "read_access_policy" {
#   bucket = aws_s3_bucket.bucket.id
#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "PublicReadGetObject",
#       "Effect": "Allow",
#       "Principal": "*",
#       "Action": [
#         "s3:GetObject"
#       ],
#       "Resource": [
#         "${aws_s3_bucket.bucket.arn}",
#         "${aws_s3_bucket.bucket.arn}/*"
#       ]
#     }
#   ]
# }
# POLICY
# }

# Create an IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name               = "lambdaRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Create an iam policy for dynamodb
# resource "aws_iam_policy" "iam_policy_for_resume_project" {

#   name        = "aws_iam_policy_for_terraform_resume_project_policy"
#   path        = "/"
#   description = "AWS IAM Policy for managing the resume project role"
#     policy = jsonencode(
#     {
#       "Version" : "2012-10-17",
#       "Statement" : [
#         {
#           "Action" : [
#             "logs:CreateLogGroup",
#             "logs:CreateLogStream",
#             "logs:PutLogEvents"
#           ],
#           "Resource" : "arn:aws:logs:*:*:*",
#           "Effect" : "Allow"
#         },
#         {
#           "Effect" : "Allow",
#           "Action" : [
#             "dynamodb:UpdateItem",
# 			      "dynamodb:GetItem"
#           ],
#           "Resource" : "arn:aws:dynamodb:*:*:table/resume-challenge"
#         },
#       ]
#   })
# }


# #Attach the necessary policies to the Lambda execution role
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
#   role       = aws_iam_role.lambda_role.name
# }

#Create a policy to provide DynamoDB full access
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name   = "Dynamodb_Policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "dynamodb:*"  
      ],
      Resource = "*"   
    }]
  })
}
# Attach the DynamoDB policy to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy" {
  role       = aws_iam_role.lambda_role.name  
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn   
}

#Upload the function code in a zip file

resource "aws_lambda_function" "func" {
  function_name     = "lambda-function"
  description       = "Lambda execution Function"
  handler           = "lambda-function.lambda_handler"
  runtime           = "python3.11"
  role              = aws_iam_role.lambda_role.arn
  filename          = "${path.module}/../project_files/lambda-function.zip"
  timeout           = 10
}
output "aws_lambda_function" {
  value = aws_lambda_function.func.function_name
}
# resource "aws_lambda_function_url" "url1" {
#   function_name      = aws_lambda_function.myfunc.function_name
#   authorization_type = "NONE"
# }  
#   cors {
#     allow_credentials = true
#     allow_origins     = ["*"]
#     allow_methods     = ["*"]
#     allow_headers     = ["date", "keep-alive"]
#     expose_headers    = ["keep-alive", "date"]
#     max_age           = 86400
#   }
# }
#Create a REST API in API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name          = "resume_api"
  description   = "Cloud resume API Challenge"

  endpoint_configuration {
    types = ["REGIONAL"]  
  }
}

# Define a GET method for the root resource of the API Gateway
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id  
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id  
  http_method   = "GET"                        
  authorization = "NONE"                       
}

#Configure integration between API Gateway and Lambda Function
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_rest_api.api.root_resource_id  
  http_method             = aws_api_gateway_method.get_method.http_method  
  integration_http_method = "POST"  
  type        = "AWS_PROXY"
  uri= aws_lambda_function.func.invoke_arn
}

#Allow API Gateway to invoke the Lambda Function
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "api_gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  lifecycle {
    create_before_destroy = true               
  }

  depends_on = [
    aws_api_gateway_integration.integration,
    aws_api_gateway_method.get_method
  ]
}
# Define a stage for the API Gateway
resource "aws_api_gateway_stage" "stage" {
  stage_name = "dev-stage"
  deployment_id = aws_api_gateway_deployment.api_gateway_deployment.id 
  rest_api_id = aws_api_gateway_rest_api.api.id
}

output "aws_api_gateway" {
  value = aws_api_gateway_rest_api.api.name
}

