#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is required but not installed. Please install jq and try again."
    exit 1
fi

# Check if lex_bot_variables.tmp exists
if [ ! -f lex_bot_variables.tmp ]; then
    echo "lex_bot_variables.tmp file not found. Please run create_lex_bot.sh first."
    exit 1
fi

# Read values from amplifyconfiguration.json
REGION=$(jq -r '.aws_project_region' src/amplifyconfiguration.json)
IDENTITY_POOL_ID=$(jq -r '.aws_cognito_identity_pool_id' src/amplifyconfiguration.json)

# Read Bot ID and Bot Alias ID from lex_bot_variables.tmp
source lex_bot_variables.tmp

# Check if BOT_ID and BOT_ALIAS_ID are set
if [ -z "$BOT_ID" ] || [ -z "$BOT_ALIAS_ID" ]; then
    echo "BOT_ID or BOT_ALIAS_ID not found in lex_bot_variables.tmp"
    exit 1
fi

# Update ChatBot.js
sed -i '' "s/region: \".*\"/region: \"$REGION\"/" src/ChatBot.js
sed -i '' "s/IdentityPoolId: \".*\"/IdentityPoolId: \"$IDENTITY_POOL_ID\"/" src/ChatBot.js
sed -i '' "s/botId: \".*\"/botId: \"$BOT_ID\"/" src/ChatBot.js
sed -i '' "s/botAliasId: \".*\"/botAliasId: \"$BOT_ALIAS_ID\"/" src/ChatBot.js

echo "ChatBot.js has been updated with the new configuration."
