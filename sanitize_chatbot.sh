#!/bin/bash

# Path to your ChatBot.js file
CHATBOT_FILE="src/ChatBot.js"

# Backup the original file
# cp "$CHATBOT_FILE" "${CHATBOT_FILE}.bak"

# Replace sensitive values with placeholders
sed -i '' 's/region: ".*"/region: "REGION_PLACEHOLDER"/' "$CHATBOT_FILE"
sed -i '' 's/IdentityPoolId: ".*"/IdentityPoolId: "IDENTITY_POOL_ID_PLACEHOLDER"/' "$CHATBOT_FILE"
sed -i '' 's/botId: ".*"/botId: "BOT_ID_PLACEHOLDER"/' "$CHATBOT_FILE"
sed -i '' 's/botAliasId: ".*"/botAliasId: "BOT_ALIAS_ID_PLACEHOLDER"/' "$CHATBOT_FILE"

echo "Sensitive information in $CHATBOT_FILE has been replaced with placeholders."

