#!/bin/bash

functionName="helloWorld"
roleName="lambda-ex"
functionZipFile="hello.zip"

if ! aws --version; then
    echo "aws CLI is not installed."
    exit 1
fi

if ! aws sts get-caller-identity; then
    echo "AWS Authentication failed"
    exit 1
fi

if [[ -n "$1" ]]; then
    functionName=$1
    echo "Found parameter: $functionName, Lambda function name will be set to $functionName"
fi

if [ -n "$2" ]; then
    roleName=$2
    echo "Found parameter: $roleName, Lambda exeuction role  will be set to $roleName"
fi

echo "Check if Execution role : $roleName exists"

execution_role_info=$(aws iam get-role --role-name "$roleName" --output json)

if [[ $? -ne 0 ]]; then
    echo "Execution role '$roleName' does not exist"
    echo ""
    echo "Creating lambda execution role: '$roleName'"
    if [ -e "./trust-policy.json" ]; then
        echo "Found trust policy in current path. Using it to create lambda execution role"
        if ! aws iam create-role --role-name "${roleName}" --assume-role-policy-document file://trust-policy.json; then
            echo "Failed to create execution role."
            exit 1
        fi
    else
        echo "Using default trust policy to create role."
        if ! aws iam create-role --role-name "${roleName}" --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'; then
            echo "Failed to create execution role."
            exit 1
        fi
    fi
    echo ""
    echo "Attach permissions to the execution role for CloudWatch."
    if ! aws iam attach-role-policy --role-name "$roleName" --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole; then
        echo "Failed to attach policy to execution role."
        exit 1
    fi
else
    role_arn=$(echo "$execution_role_info}" | jq -r '.Role.Arn')
    echo "Execution role '$roleName' exists with ARN: '$role_arn'"
    echo "Skipping role creation"
fi

lambda_function_info=$(aws lambda get-function --function-name "$functionName" 2>&1)

if [[ $? -ne 0 ]]; then
    echo "Lambda function '$functionName' does not exist."
    echo "Create lambda function: '$functionName' with latest custom runtime for AWS: provided.al2"
    echo "Creating Go Binary!"
    make build
    echo "Zip file contents!"
    zip ${functionZipFile} bootstrap
    echo "Proceed to create lambda function"
    echo "functionName: ${functionName}"
    echo "role_arn: ${role_arn}"
    echo "functionZipFile: ${functionZipFile}"
    if ! aws lambda create-function --function-name "${functionName}" --runtime provided.al2 --handler bootstrap --role "${role_arn}" --zip-file fileb://"${functionZipFile}"; then
        echo "Failed to create lambda function."
        exit 1
    fi
else
    echo "Lambda function '$functionName' exists. Proceed to update function with latest code."
    echo "$lambda_function_info"
    echo "Compiling & Deploying go to AWS Lambda!"
    echo "Creating Go Binary!"
    make build
    echo "Zip file contents!"
    zip ${functionZipFile} bootstrap
    echo "Upload function to Lambda!"
    if ! aws lambda update-function-code --function-name "${functionName}" --zip-file fileb://"${functionZipFile}"; then
        echo "Failed to update lambda function code."
        exit 1
    fi
fi
