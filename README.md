# aws-lambda-hello
Hello World! In AWS Lambda.


### Create trust policy for Lambda
```
aws iam create-role --role-name lambda-ex --assume-role-policy-document file://trust-policy.json
```

### Add permissions for the created role
```
aws iam attach-role-policy --role-name lambda-ex --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### Compile the GO Program
```
make
```

### Zip the file contents
```
zip main.zip main
```

### Create Lambda function & upload the zip file
The IAM role is from the previous command
```
aws lambda create-function --function-name my-function --runtime go1.x --role arn:aws:iam::248491707577:role/lambda-ex --handler main --zip-file fileb://main.zip
```

### Script Usage
```
./deploy.sh function_name
```