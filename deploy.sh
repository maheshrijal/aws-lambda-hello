#!/bin/sh

set -e

echo "Compiling & Deploying go to AWS Lambda!"

echo "Creating Go Binary!"
make

echo "Zip file contents!"
zip main.zip main

echo "Upload function to Lambda!"
aws lambda update-function-code --function-name "$1" --zip-file fileb://main.zip
