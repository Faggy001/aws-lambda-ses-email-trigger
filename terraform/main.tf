resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_email_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ses_policy" {
  name = "lambda_ses_send_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["ses:SendEmail", "ses:SendRawEmail"],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["iam:ListAccessKeys"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.ses_policy.arn
}

resource "aws_lambda_function" "send_email" {
  filename         = "${path.module}/../GroupB_lambda_email.zip"
  function_name    = "send_email_lambda"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.12"
  source_code_hash = filebase64sha256("${path.module}/../GroupB_lambda_email.zip")

  environment {
    variables = {
      SET_EXPIRY     = tostring(var.expiry_days)
      KEY_USER_NAME  = var.iam_user
      TO_EMAILS      = var.recipient_email
      FROM_EMAIL     = var.sender_email
      REGION         = var.aws_region
    }
  }
}

resource "aws_ses_email_identity" "verified_sender" {
  email = var.sender_email
}

# CloudWatch Log Group ()
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.send_email.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda_ses_iam_policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ses:SendEmail",
          "ses:SendRawEmail",
          "iam:ListAccessKeys"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}
