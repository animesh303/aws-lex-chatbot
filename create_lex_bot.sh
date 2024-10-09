#!/bin/bash

# File to store variables
TEMP_FILE="lex_bot_variables.tmp"

# Function to handle errors
handle_error() {
    echo "Error occurred in command: $1" >&2
    echo "Continuing with the next step..." >&2
}

# Function to save variable to temp file
save_variable() {
    echo "$1=$2" >> "$TEMP_FILE"
}

# Function to load variable from temp file
load_variable() {
    local var_name=$1
    local var_value
    var_value=$(grep "^$var_name=" "$TEMP_FILE" | cut -d'=' -f2)
    if [ -n "$var_value" ]; then
        eval "$var_name=$var_value"
        echo "Loaded $var_name from file"
    fi
}

# Load existing variables if file exists
if [ -f "$TEMP_FILE" ]; then
    echo "Loading existing variables from $TEMP_FILE"
    load_variable ROLE_ARN
    load_variable ACCOUNT_ID
    load_variable BOT_ID
    load_variable LOCALE_CREATED
    load_variable INTENT_ID
    load_variable BOT_VERSION
    load_variable BOT_ALIAS_ID
else
    echo "No existing variables found. Creating new file."
    > "$TEMP_FILE"
fi

# Create IAM role for Lex bot if not already loaded
if [ -z "$ROLE_ARN" ]; then
    echo "Creating IAM role for Lex bot..."
    ROLE_ARN=$(aws iam create-role --role-name LexBotRole --assume-role-policy-document '{
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "lexv2.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
      ]
    }' --query 'Role.Arn' --output text) || handle_error "create-role"
    save_variable "ROLE_ARN" "$ROLE_ARN"
fi

# Attach policy to the role (this is idempotent, so we can always run it)
echo "Attaching policy to the role..."
aws iam attach-role-policy --role-name LexBotRole --policy-arn arn:aws:iam::aws:policy/AmazonLexFullAccess || handle_error "attach-role-policy"

# Get AWS Account ID if not already loaded
if [ -z "$ACCOUNT_ID" ]; then
    echo "Getting AWS Account ID..."
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text) || handle_error "get-caller-identity"
    save_variable "ACCOUNT_ID" "$ACCOUNT_ID"
fi

# Create Lex bot if not already loaded
if [ -z "$BOT_ID" ]; then
    echo "Creating Lex bot..."
    BOT_ID=$(aws lexv2-models create-bot \
      --bot-name "ChatBotSample" \
      --data-privacy '{"childDirected": false}' \
      --bot-type "Bot" \
      --description "A sample chatbot for demonstration" \
      --idle-session-ttl-in-seconds 300 \
      --role-arn "$ROLE_ARN" \
      --query 'botId' --output text) || handle_error "create-bot"
    save_variable "BOT_ID" "$BOT_ID"
fi

sleep 10
# Create bot locale if it doesn't exist
if [ -z "$LOCALE_CREATED" ]; then
    echo "Creating bot locale..."
    aws lexv2-models create-bot-locale \
      --bot-id "$BOT_ID" \
      --bot-version "DRAFT" \
      --locale-id "en_US" \
      --nlu-intent-confidence-threshold 0.40 || handle_error "create-bot-locale"
    save_variable "LOCALE_CREATED" "true"
fi

sleep 10

# Create intent if not already loaded
if [ -z "$INTENT_ID" ]; then
    echo "Creating intent..."
    INTENT_ID=$(aws lexv2-models create-intent \
      --bot-id "$BOT_ID" \
      --bot-version "DRAFT" \
      --locale-id "en_US" \
      --intent-name "Greetings" \
      --description "Welcome the user" \
      --query 'intentId' --output text) || handle_error "create-intent"
    save_variable "INTENT_ID" "$INTENT_ID"
fi

# Update intent with sample utterances and responses
echo "Updating intent with sample utterances and responses..."
aws lexv2-models update-intent \
  --bot-id "$BOT_ID" \
  --bot-version "DRAFT" \
  --locale-id "en_US" \
  --intent-id "$INTENT_ID" \
  --intent-name "Greetings" \
  --sample-utterances '[
    {"utterance": "Hello"},
    {"utterance": "Hi"},
    {"utterance": "Greetings"},
    {"utterance": "Good morning"},
    {"utterance": "Good afternoon"},
    {"utterance": "Hey there"}
  ]' \
  --fulfillment-code-hook '{"enabled": false}' \
  --dialog-code-hook '{"enabled": false}' \
  --initial-response-setting '{
  "initialResponse": {
    "messageGroups": [
      {
        "message": {
          "plainTextMessage": {
            "value": "Hello! How can I assist you today?"
          }
        }
      }
    ]}
  }' \
  --input-contexts '[]' \
  --output-contexts '[]' \
  > /dev/null 2>&1 || handle_error "update-intent"

# Build the bot (this is idempotent, so we can always run it)
echo "Building the bot..."
aws lexv2-models build-bot-locale \
  --bot-id "$BOT_ID" \
  --bot-version "DRAFT" \
  --locale-id "en_US" || handle_error "build-bot-locale"

# Create a bot version if not already created
if [ -z "$BOT_VERSION" ]; then
    echo "Creating a bot version..."
    BOT_VERSION=$(aws lexv2-models create-bot-version \
      --bot-id "$BOT_ID" \
      --description "Initial version" \
      --bot-version-locale-specification '{"en_US": {"sourceBotVersion": "DRAFT"}}' \
      --query 'botVersion' \
      --output text) || handle_error "create-bot-version"
    save_variable "BOT_VERSION" "$BOT_VERSION"

    echo "Waiting for bot version to be available..."
    aws lexv2-models wait bot-version-available \
      --bot-id "$BOT_ID" \
      --bot-version "$BOT_VERSION" || handle_error "wait-bot-version-available"
fi

# Create a bot alias if not already created
if [ -z "$BOT_ALIAS_ID" ]; then
    echo "Creating a bot alias..."
    BOT_ALIAS_ID=$(aws lexv2-models create-bot-alias \
      --bot-alias-name "PROD" \
      --bot-id "$BOT_ID" \
      --bot-version "$BOT_VERSION" \
      --query 'botAliasId' --output text) || handle_error "create-bot-alias"
    save_variable "BOT_ALIAS_ID" "$BOT_ALIAS_ID"
fi

echo "Script execution completed."
echo "Bot ID: $BOT_ID"
echo "Bot Alias ID: $BOT_ALIAS_ID"
echo "Please update your src/ChatBot.js file with these values."
echo "Variables have been saved to $TEMP_FILE"