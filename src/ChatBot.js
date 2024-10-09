import React, { useState } from "react";
import AWS from "aws-sdk";

function ChatBot() {
  AWS.config.update({
    region: "us-east-1", // e.g., 'us-east-1'
    credentials: new AWS.CognitoIdentityCredentials({
      IdentityPoolId: "us-east-1:809a7f66-17b6-49c3-b651-30a4bd97f465",
    }),
  });
  const [inputText, setInputText] = useState("");
  const [messages, setMessages] = useState([]);

  //   const lexRuntime = new AWS.LexRuntime();

  // Use LexRuntimeV2 instead of LexRuntime
  const lexRuntimeV2 = new AWS.LexRuntimeV2();

  const handleSubmit = (event) => {
    event.preventDefault();

    if (inputText.trim() === "") return;

    const newMessage = { from: "user", text: inputText };
    setMessages((prevMessages) => [...prevMessages, newMessage]);

    // Ensure credentials are loaded
    AWS.config.credentials.get((err) => {
      if (err) {
        console.error("Error retrieving credentials", err);
        // Optionally, handle the error in your UI
        return;
      }

      // Now that credentials are loaded, you can get the identityId
      //   const params = {
      //     botAlias: "$LATEST",
      //     botName: "SampleBot",
      //     inputText: inputText,
      //     userId: AWS.config.credentials.identityId,
      //   };

      const params = {
        botId: "HJA3PMZYLR", // Replace with your actual Bot ID
        botAliasId: "ZZMEXHWZEJ", // Replace with your actual Bot Alias ID
        localeId: "en_US", // This should match the locale created in the script
        sessionId: AWS.config.credentials.identityId,
        text: inputText,
      };

      //   lexRuntime.postText(params, (err, data) => {
      //     if (err) {
      //       console.error(err);
      //       // Optionally handle the error in your UI
      //     } else if (data) {
      //       const botMessage = { from: "bot", text: data.message };
      //       setMessages((prevMessages) => [...prevMessages, botMessage]);
      //     }
      //   });
      lexRuntimeV2.recognizeText(params, (err, data) => {
        if (err) {
          console.error(err);
        } else if (data) {
          const botMessage = { from: "bot", text: data.messages[0].content };
          setMessages((prevMessages) => [...prevMessages, botMessage]);
        }
      });
    });

    setInputText("");
  };

  return (
    <div className="chatbot">
      <div className="chat-window">
        {messages.map((msg, idx) => (
          <div key={idx} className={`message ${msg.from}`}>
            <p>{msg.text}</p>
          </div>
        ))}
      </div>
      <form className="input-form" onSubmit={handleSubmit}>
        <input
          type="text"
          value={inputText}
          placeholder="Type your message..."
          onChange={(e) => setInputText(e.target.value)}
        />
        <button type="submit">Send</button>
      </form>
    </div>
  );
}

export default ChatBot;
