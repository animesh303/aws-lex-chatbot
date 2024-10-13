import React, { useState } from "react";
import ChatBot from "./ChatBot";
import ThemeToggle from "./ThemeToggle";
import "./App.css";

function App() {
  const [theme, setTheme] = useState("light");

  const toggleTheme = () => {
    setTheme(theme === "light" ? "dark" : "light");
  };

  return (
    <div className={`App ${theme}`}>
      <ThemeToggle theme={theme} toggleTheme={toggleTheme} />
      <ChatBot theme={theme} />
    </div>
  );
}

export default App;
