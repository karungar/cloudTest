# Backend configuration for Terraform Cloud 
terraform {
  cloud {
    organization = "Shirubia"

    workspaces {
      name = "Cloud-Resume-API-"
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
  name               = "lambdaExecutionRole"
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

#Attach the necessary policies to the Lambda execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

#Create a policy to provide DynamoDB full access
resource "aws_iam_policy" "dynamodb_full_access" {
  name   = "DynamoAccessPolicy"
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
  policy_arn = aws_iam_policy.dynamodb_full_access.arn   
}

#Upload the function code in a zip file

resource "aws_lambda_function" "lambda" {
  function_name     = "lambda_function"
  description       = "Lambda execution Function"
  handler           = "lambda_function.lambda_handler"
  runtime           = "python3.11"
  role              = aws_iam_role.lambda_role.arn
  filename          = "${path.module}/../project_files/lambda_function.zip"
  timeout           = 10
}
output "aws_lambda_function" {
  value = aws_lambda_function.lambda.function_name
}
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
  uri= aws_lambda_function.lambda.invoke_arn
}

#Allow API Gateway to invoke the Lambda Function
resource "aws_lambda_permission" "api" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
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

