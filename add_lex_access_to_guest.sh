#!/bin/bash

# Read the Cognito Identity Pool ID from amplifyconfiguration.json
IDENTITY_POOL_ID=$(jq -r '.aws_cognito_identity_pool_id' src/amplifyconfiguration.json)

if [ -z "$IDENTITY_POOL_ID" ]; then
    echo "Error: Could not find aws_cognito_identity_pool_id in amplifyconfiguration.json"
    exit 1
fi

echo "Found Identity Pool ID: $IDENTITY_POOL_ID"

# Get the ARN of the unauthenticated role
UNAUTH_ROLE_ARN=$(aws cognito-identity get-identity-pool-roles --identity-pool-id "$IDENTITY_POOL_ID" --query 'Roles.unauthenticated' --output text)

if [ -z "$UNAUTH_ROLE_ARN" ]; then
    echo "Error: Could not find unauthenticated role for Identity Pool $IDENTITY_POOL_ID"
    exit 1
fi

echo "Found unauthenticated role ARN: $UNAUTH_ROLE_ARN"

# Extract the role name from the ARN
UNAUTH_ROLE_NAME=$(echo "$UNAUTH_ROLE_ARN" | awk -F'/' '{print $NF}')

echo "Attaching AmazonLexFullAccess policy to role: $UNAUTH_ROLE_NAME"

# Attach the AmazonLexFullAccess policy to the unauthenticated role
aws iam attach-role-policy \
    --role-name "$UNAUTH_ROLE_NAME" \
    --policy-arn arn:aws:iam::aws:policy/AmazonLexFullAccess

if [ $? -eq 0 ]; then
    echo "Successfully attached AmazonLexFullAccess policy to $UNAUTH_ROLE_NAME"
else
    echo "Error: Failed to attach AmazonLexFullAccess policy to $UNAUTH_ROLE_NAME"
    exit 1
fi
