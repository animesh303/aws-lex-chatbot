# AWS Amplify Application Deployment Guide

This guide provides instructions for deploying the AWS Amplify application and integrating it with AWS Lex services.

## Prerequisites

1. Install Node.js and npm (Node Package Manager)
2. Install the AWS Amplify CLI:
   ```
   npm install -g @aws-amplify/cli
   ```
3. Configure your AWS account:
   ```
   amplify configure
   ```

## Deployment Steps

1. Clone the repository and navigate to the project directory.

2. Initialize the Amplify project:
   ```
   amplify init
   ```

3. Add authentication:
   ```
   amplify add auth
   ```

4. Add hosting:
   ```
   amplify add hosting
   ```
5. Update the `src/ChatBot.js` file with your Identity Pool ID and AWS Region.
   1. Refer to `src/amplifyconfiguration.json`.
   2. Update the `src/ChatBot.js` file with your Lex bot configuration.
   ```
   region: "us-east-1" // Replace with AWS Region
   IdentityPoolId: "us-east-1:idens-poolid-xxxxx" // Replace with Identity Pool ID
   ```

6. Create an AWS Lex v2 bot in the AWS Console.

   1. Configure the Lex bot with intents and sample utterances.
   2. Build and publish the Lex bot.
   3. Update the `src/ChatBot.js` file with your Lex bot configuration.

   ```
   botId: "BOTIDXXXX", // Replace with your actual Bot ID
   botAliasId: "ALIASIDXXX", // Replace with your actual Bot Alias ID
   ```

7. Push the changes to AWS:
   ```
   amplify push
   ```

8. Deploy the application:
   ```
   amplify publish
   ```

## Additional Notes

- The application uses Cognito for authentication. Ensure that the Cognito User Pool is properly configured.
- The Lambda function `awslexchatbot37b47add37b47addCustomMessage` is used for custom authentication messages. Update it if needed.
- The application is hosted using Amplify Hosting. You can find the hosting details in the AWS Amplify Console.

For more information on AWS Amplify and Lex integration, refer to the official AWS documentation.