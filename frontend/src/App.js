import React from "react";
import "@/App.css";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Dashboard from "@/components/Dashboard";
import GovBankDemo from "@/components/GovBankDemo";

function App() {
  return (
    <div className="App">
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/gov" element={<GovBankDemo />} />
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default App;
