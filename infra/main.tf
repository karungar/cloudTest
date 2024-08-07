#Backend configuration for Terraform Cloud 
terraform {
 cloud {
   organization = "Shirubia"

   workspaces {
     name = "sylviaResume"
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
# Create an IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_role" {
  name               = "mylambdaRole"
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
  function_name     = "resume-function"
  description       = "Lambda execution Function"
  handler           = "lambda-function.lambda_handler"
  runtime           = "python3.11"
  role              = aws_iam_role.lambda_role.arn
  filename          = "${path.module}/../Backend/lambda-function.zip"
  timeout           = 10
}
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
  name          = "resumeapi"
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
