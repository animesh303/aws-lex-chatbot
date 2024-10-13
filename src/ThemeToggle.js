import React from "react";
import { FaSun, FaMoon } from "react-icons/fa";

function ThemeToggle({ theme, toggleTheme }) {
  return (
    <button className="theme-toggle" onClick={toggleTheme}>
      {theme === "light" ? <FaMoon /> : <FaSun />}
    </button>
  );
}

export default ThemeToggle;
