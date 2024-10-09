# ChatBot Deployment using AWS Amplify

This guide provides instructions for deploying the AWS Amplify application and integrating it with AWS Lex services.

## Prerequisites

1. Install Node.js and npm (Node Package Manager)
2. Install the AWS Amplify CLI:
   ```bash
   $ npm install -g @aws-amplify/cli
   ```

3. Create an IAM user for Amplify:

   Create IAM user in the AWS Console or using AWS CLI for Amplify if not done already. Below are the steps to create IAM user using AWS CLI.

   a. Create the IAM user:
   ```bash
   $ aws iam create-user --user-name amplify-dev
   ```

   b. Attach the AdministratorAccess-Amplify policy:
   ```bash
   $ aws iam attach-user-policy --user-name amplify-dev --policy-arn arn:aws:iam::aws:policy/AdministratorAccess-Amplify
   ```

   c. Create access keys for CLI access:
   ```bash
   $ aws iam create-access-key --user-name amplify-dev
   ```

   This command will output the access key ID and secret access key. Make sure to save these securely, as you won't be able to retrieve the secret access key again.

   d. Configure the AWS CLI with the new credentials:
   ```bash
   $ aws configure --profile amplify-dev
   
   AWS Access Key ID [None]: <AccessKeyId>
   AWS Secret Access Key [None]: <SecretAccessKey>
   Default region name [None]: <aws-region>
   Default output format [None]: json
   ```

   Enter the access key ID and secret access key when prompted, and specify your preferred region and output format.

3. Configure your AWS Applify to use the AWS account:
    This step will guide you through setting up your AWS account for use with Amplify:
   
      1. Run the command and press Enter when prompted to sign in to the AWS Console.
      
      2. Press enter till it asks for accessKeyId.
      
      3. Enter the access key ID and secret access key for the IAM user when prompted.
      
      4. Specify the AWS Region you want to use (e.g., us-east-1).
      
      5. Choose a profile name `amplify-dev`. This will ensure that Amplify uses the correct IAM user for deployments.

      ```bash
      $ amplify configure

      Follow these steps to set up access to your AWS account:

      Sign in to your AWS administrator account:
      https://console.aws.amazon.com/
      Press Enter to continue

      Specify the AWS Region
      ? region:  us-east-1
      Follow the instructions at
      https://docs.amplify.aws/cli/start/install/#configure-the-amplify-cli

      to complete the user creation in the AWS console
      https://console.aws.amazon.com/iamv2/home#/users/create
      Press Enter to continue

      Enter the access key of the newly created user:
      ? accessKeyId:  ********************
      ? secretAccessKey:  ****************************************
      This would update/create the AWS Profile in your local machine
      ? Profile Name:  amplify-dev

      Successfully set up the new user.
      ```

   Note: Ensure you have the necessary permissions to create and manage AWS resources.


## Deployment Steps

1. Clone the repository and navigate to the project directory.

2. Initialize the Amplify project:
   ```bash
   $ amplify init

   Note: It is recommended to run this command from the root of your app directory
   ? Enter a name for the project awslexchatbot
   The following configuration will be applied:

   Project information
   | Name: awslexchatbot
   | Environment: dev
   | Default editor: Visual Studio Code
   | App type: javascript
   | Javascript framework: react
   | Source Directory Path: src
   | Distribution Directory Path: build
   | Build Command: npm run-script build
   | Start Command: npm run-script start

   ? Initialize the project with the above configuration? Yes
   Using default provider  awscloudformation
   ? Select the authentication method you want to use: AWS profile

   ? Please choose the profile you want to use amplify-dev
   Adding backend environment dev to AWS Amplify app: ddjfc564rfbh1

   Deployment completed.
   Deploying root stack awslexchatbot ...
   Deployment state saved successfully.
   ✔ Initialized provider successfully.
   ✅ Initialized your environment successfully.
   ✅ Your project has been successfully initialized and connected to the cloud!
   ```

3. Add authentication:
   Add authentication to your project using the following command. Ensure to allow unauthenticated logins.
   ```bash
   $ amplify add auth

   Using service: Cognito, provided by: awscloudformation
   
   The current configured provider is Amazon Cognito. 
   
   Do you want to use the default authentication and security configuration? Manual configuration
   Select the authentication/authorization services that you want to use: User Sign-Up, Sign-In, connected with AWS IAM controls (Enables per-user Storage features for ima
   ges or other content, Analytics, and more)
   Provide a friendly name for your resource that will be used to label this category in the project: awslexchatbotfc9c0b90fc9c0b90
   Enter a name for your identity pool. awslexchatbotfc9c0b90_identitypool_fc9c0b90
   Allow unauthenticated logins? (Provides scoped down permissions that you can control via AWS IAM) Yes
   Do you want to enable 3rd party authentication providers in your identity pool? No
   Provide a name for your user pool: awslexchatbotfc9c0b90_userpool_fc9c0b90
   Warning: you will not be able to edit these selections. 
   How do you want users to be able to sign in? Email
   Do you want to add User Pool Groups? No
   Do you want to add an admin queries API? No
   Multifactor authentication (MFA) user login options: OFF
   Email based user registration/forgot password: Disabled (Uses SMS/TOTP as an alternative)
   Please specify an SMS verification message: Your verification code is {####}
   Do you want to override the default password policy for this User Pool? No
   Warning: you will not be able to edit these selections. 
   What attributes are required for signing up? Email
   Specify the app's refresh token expiration period (in days): 30
   Do you want to specify the user attributes this app can read and write? No
   Do you want to enable any of the following capabilities? 
   Do you want to use an OAuth flow? No
   ? Do you want to configure Lambda Triggers for Cognito? No
   ✅ Successfully added auth resource awslexchatbotfc9c0b90fc9c0b90 locally
   ```

4. Add hosting:
   ```bash
   $ amplify add hosting

   ✔ Select the plugin module to execute · Hosting with Amplify Console (Managed hosting with custom domains, Continuous deployment)
   ? Choose a type Manual deployment
   ```
5. Push the changes to AWS:
   ```bash
   $ amplify push

   ✔ Successfully pulled backend environment dev from the cloud.
   ✔ Are you sure you want to continue? (Y/n) · yes

   Deployment completed.
   Deployed root stack awslexchatbot 
   Deployed auth awslexchatbotfc9c0b90fc9c0b90 
   Deployed hosting amplifyhosting 
   Deployment state saved successfully.
   ```

6. Update the `src/ChatBot.js` file with your Identity Pool ID and AWS Region.
   1. Refer to `src/amplifyconfiguration.json`.
   2. Update the `src/ChatBot.js` file with Identity Pool ID and region configuration.
      ```bash
      region: "us-east-1" // Replace with AWS Region
      IdentityPoolId: "us-east-1:idens-poolid-xxxxx" // Replace with Identity Pool ID
      ```

7. Create an AWS Lex v2 bot. Optionally, use the provided shell script `create_lex_bot.sh`:
   Make the script executable and run it:

   ```bash
   chmod +x create_lex_bot.sh
   ./create_lex_bot.sh
   ```
   This script will create the IAM role, Lex bot, intent, and bot alias. It will output the Bot ID and Bot Alias ID at the end.

8. Update the `src/ChatBot.js` file with the Bot ID and Bot Alias ID output by the script.

   ```bash
   botId: "DMD6BQTHBB", // Replace with your actual Bot ID
   botAliasId: "TSTALIASID", // Replace with your actual Bot Alias ID
   ```

9. Add Lex access to the unauthenticated (guest) role:
   Make the script executable and run it:

   ```bash
   chmod +x add_lex_access_to_guest.sh
   ./add_lex_access_to_guest.sh
   ```
   This script will attach the AmazonLexFullAccess policy to the unauthenticated role associated with your Cognito Identity Pool, allowing guest users to interact with your Lex bot.

10. Deploy the application:
    ```bash
    $ amplify publish

    ✔ Successfully pulled backend environment dev from the cloud.
    ? Do you still want to publish the frontend? Yes
    Publish started for amplifyhosting

    Creating an optimized production build...
    Compiled successfully.

    File sizes after gzip:

    The project was built assuming it is hosted at /.
    You can control this with the homepage field in your package.json.
    ✔ Zipping artifacts completed.
    ✔ Deployment complete!
    https://dev.dpy922bvgnzv9.amplifyapp.com
    ```

## Additional Notes

- The application uses Cognito for authentication. Ensure that the Cognito User Pool is properly configured.
- The Lambda function `awslexchatbot37b47add37b47addCustomMessage` is used for custom authentication messages. Update it if needed.
- The application is hosted using Amplify Hosting. You can find the hosting details in the AWS Amplify Console.

For more information on AWS Amplify and Lex integration, refer to the official AWS documentation.

## Troubleshooting

### Missing Deployment Bucket

If you encounter an error message similar to the following when running `amplify init`:

```
✖ There was an error initializing your environment.
🛑 Could not find a deployment bucket for the specified backend environment. This environment may have been deleted.
```

This usually indicates that the Amplify environment has been corrupted or deleted. To resolve this, follow these cleanup steps:

1. Remove the existing Amplify configuration:
   ```bash
   rm -rf amplify .amplify
   ```

2. Delete the `aws-exports.js` file if it exists:
   ```bash
   rm -f src/aws-exports.js
   ```

3. Reinitialize your Amplify project:
   ```bash
   amplify init
   ```

4. When prompted, choose to create a new environment rather than using an existing one.

5. Follow the prompts to set up your new environment.


Remember to update your source code with any new configuration details (like the new `aws-exports.js` file) that are generated during this process.