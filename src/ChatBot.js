import React, { useState, useRef, useEffect } from "react";
import AWS from "aws-sdk";
import { FaPaperPlane } from "react-icons/fa";
import ReactMarkdown from "react-markdown";
import agentAvatar from "./images/agent.jpg";
import customerAvatar from "./images/customer.jpg";
import onlineShopIcon from "./images/online-shop.png"; // Import the new icon

function ChatBot({ theme }) {
  AWS.config.update({
    region: "REGION_PLACEHOLDER",
    credentials: new AWS.CognitoIdentityCredentials({
      IdentityPoolId: "IDENTITY_POOL_ID_PLACEHOLDER",
    }),
  });

  const [inputText, setInputText] = useState("");
  const [messages, setMessages] = useState([]);
  const [isTyping, setIsTyping] = useState(false);
  const [quickReplies, setQuickReplies] = useState([]);
  const messagesEndRef = useRef(null);
  const notificationSound = useRef(new Audio("/notification.mp3"));

  const lexRuntimeV2 = new AWS.LexRuntimeV2();

  useEffect(() => {
    // Clear chat history and show initial greeting
    const greeting = getTimeBasedGreeting();
    setMessages([
      {
        from: "bot",
        text: `${greeting}! How can I assist you today?`,
        timestamp: new Date(),
      },
    ]);
  }, []); // Empty dependency array ensures this runs only once on component mount

  useEffect(() => {
    scrollToBottom();
    if (messages.length > 1) {
      notificationSound.current
        .play()
        .catch((error) => console.error("Error playing sound:", error));
    }
  }, [messages]);

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  };

  const getTimeBasedGreeting = () => {
    const hour = new Date().getHours();
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  };

  const formatTimestamp = (date) => {
    if (!(date instanceof Date)) {
      date = new Date(date);
    }
    return date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  };

  const handleSubmit = (event) => {
    event.preventDefault();
    if (inputText.trim() !== "") {
      sendMessage(inputText);
    }
  };

  const sendMessage = (text) => {
    if (text.trim() === "") return;

    const newMessage = { from: "user", text: text, timestamp: new Date() };
    setMessages((prevMessages) => [...prevMessages, newMessage]);
    setInputText("");
    setIsTyping(true);
    setQuickReplies([]);

    AWS.config.credentials.get((err) => {
      if (err) {
        console.error("Error retrieving credentials", err);
        setIsTyping(false);
        return;
      }

      const params = {
        botId: "BOT_ID_PLACEHOLDER",
        botAliasId: "BOT_ALIAS_ID_PLACEHOLDER",
        localeId: "en_US",
        sessionId: AWS.config.credentials.identityId,
        text: text,
      };

      lexRuntimeV2.recognizeText(params, (err, data) => {
        setIsTyping(false);
        if (err) {
          console.error(err);
        } else if (data) {
          const botMessage = {
            from: "bot",
            text: data.messages[0].content,
            timestamp: new Date(),
          };
          setMessages((prevMessages) => [...prevMessages, botMessage]);

          // Check for quick replies in the bot's response
          if (data.messages[0].contentType === "CustomPayload") {
            try {
              const payload = JSON.parse(data.messages[0].content);
              if (payload.quickReplies) {
                setQuickReplies(payload.quickReplies);
              }
            } catch (error) {
              console.error("Error parsing custom payload:", error);
            }
          }
        }
      });
    });
  };

  const handleInputChange = (e) => {
    setInputText(e.target.value);
  };

  return (
    <div className={`chatbot ${theme}`}>
      <div className="chat-header">
        <img src={onlineShopIcon} alt="Online Shop" className="bot-icon" />
        <h2>Akme Shop</h2>
      </div>
      <div className="chat-window">
        {messages.map((msg, idx) => (
          <div key={idx} className={`message ${msg.from}`}>
            <div className="avatar">
              <img
                src={msg.from === "bot" ? agentAvatar : customerAvatar}
                alt={msg.from}
              />
            </div>
            <div className="message-content-wrapper">
              <div className="message-content">
                {msg.from === "bot" ? (
                  <ReactMarkdown>{msg.text}</ReactMarkdown>
                ) : (
                  msg.text
                )}
              </div>
              <div className="message-timestamp">
                {formatTimestamp(msg.timestamp)}
              </div>
            </div>
          </div>
        ))}
        {isTyping && (
          <div className="message bot">
            <div className="avatar">
              <img src={agentAvatar} alt="Agent" />
            </div>
            <div className="message-content typing">
              <div className="dot"></div>
              <div className="dot"></div>
              <div className="dot"></div>
            </div>
          </div>
        )}
        <div ref={messagesEndRef} />
      </div>
      {quickReplies.length > 0 && (
        <div className="quick-replies">
          {quickReplies.map((reply, index) => (
            <button key={index} onClick={() => sendMessage(reply)}>
              {reply}
            </button>
          ))}
        </div>
      )}
      <form className="input-form" onSubmit={handleSubmit}>
        <input
          type="text"
          value={inputText}
          placeholder="Type your message..."
          onChange={handleInputChange}
        />
        <button type="submit">
          <FaPaperPlane />
        </button>
      </form>
    </div>
  );
}

export default ChatBot;
