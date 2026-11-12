resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "my_lambda" {
  function_name = "clab-lambda-function-1"
  handler       = "helloworld_function_1.lambda_handler" 
  # The handler is specified as <filename>.<function_name> where filename is the name of the Python file without the .py extension, 
  # and function_name is the name of the function defined in that file.
  runtime       = "python3.15"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "helloworld_function_1.zip"

  source_code_hash = filebase64sha256("helloworld_function_1.zip")

  environment {
    variables = {
      ENV_VAR1 = "value1"
      ENV_VAR2 = "value2"
    }
  }
}