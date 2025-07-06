#!/bin/bash
echo "Zipping Lambda function for GroupB..."
cd lambda
zip -r ../GroupB_lambda_email.zip .
cd ..
echo "Done. Created GroupB lambda_email.zip"
