# aws-lambda-hello
This example repo contains the code for hello world & a shell script that can build & deploy a lambda function to AWS using the latest `provided.al2` runtime from sratch.


### Prerequisites
- AWS CLI (Should be configured & logged in with default region)
- Go
- jq

## How to run?
Parameters are optional. Defaults will be used unless specified.
```
deploy.sh functionName roleName
```

## Features

The script will do the following:
- Create lambda execution role
- Create lambda function
- Build & deploy latest code (current directory) to Lambda