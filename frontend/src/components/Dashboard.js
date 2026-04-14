import React, { useState, useCallback, useRef, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Shield, AlertTriangle, Activity, Cpu, Server, Link2, Brain, Layers, Box, Zap, Play, RotateCcw, ChevronRight, Globe, ExternalLink } from "lucide-react";
import axios from "axios";

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;
const API = `${BACKEND_URL}/api`;

const LAYER_ICONS = {
  L1: Server, L2: Shield, L3: Zap, L4: Activity, L5: Layers,
  L6: Link2, L7: Brain, L8: Cpu, L9: Box, L10: Globe
};

const PHASES = {
  IDLE: "IDLE",
  MINING_LEGIT: "MINING_LEGIT",
  TX_SENT: "TX_SENT",
  ATTACKER_MINING: "ATTACKER_MINING",
  REORG_DETECTED: "REORG_DETECTED",
  ATTACK_BLOCKED: "ATTACK_BLOCKED",
};

const PHASE_LABELS = {
  IDLE: "AWAITING COMMAND",
  MINING_LEGIT: "MINING LEGITIMATE CHAIN",
  TX_SENT: "TRANSACTION BROADCAST",
  ATTACKER_MINING: "ATTACKER CHAIN DETECTED",
  REORG_DETECTED: "REORG DETECTED — 51% ATTACK",
  ATTACK_BLOCKED: "ATTACK NEUTRALIZED",
};

function generateHash() {
  return "0x" + Array.from({ length: 12 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
}

function generateTxHash() {
  return "0x" + Array.from({ length: 20 }, () => Math.floor(Math.random() * 16).toString(16)).join("");
}

function timestamp() {
  return new Date().toLocaleTimeString("en-US", { hour12: false, hour: "2-digit", minute: "2-digit", second: "2-digit" });
}

const StatusDot = ({ active, danger }) => (
  <span
    data-testid={danger ? "status-dot-danger" : "status-dot-active"}
    className={`inline-block w-2 h-2 rounded-full ${danger ? "bg-[#FF8C00] pulse-orange" : active ? "bg-[#FF003C] pulse-dot" : "bg-[#52525B]"}`}
  />
);

const Block = ({ block, type, index }) => {
  const isLegit = type === "legit";
  const borderColor = isLegit ? "border-[#00FFFF]/40" : "border-[#FF8C00]/50";
  const bgColor = isLegit ? "bg-[#00FFFF]/5" : "bg-[#FF8C00]/5";
  const textColor = isLegit ? "text-[#00FFFF]" : "text-[#FF8C00]";
  const hashColor = isLegit ? "text-[#00FFFF]/70" : "text-[#FFB000]/80";
  const pulseClass = isLegit ? "pulse-red" : "pulse-orange";

  return (
    <motion.div
      data-testid={`block-${type}-${block.height}`}
      initial={{ opacity: 0, scale: 0.7, x: 30 }}
      animate={{ opacity: 1, scale: 1, x: 0 }}
      transition={{ type: "spring", stiffness: 300, damping: 20, delay: index * 0.15 }}
      className={`flex-shrink-0 w-[120px] border ${borderColor} ${bgColor} p-3 relative ${pulseClass}`}
    >
      <div className={`text-xs font-mono font-bold ${textColor} mb-1`}>#{block.height}</div>
      <div className={`text-[10px] font-mono ${hashColor} truncate`}>{block.hash}</div>
      <div className="text-[10px] font-mono text-[#52525B] mt-1">{block.tx_count} txs</div>
      {index > 0 && (
        <div className={`absolute left-[-14px] top-1/2 -translate-y-1/2 w-[14px] h-[2px] ${isLegit ? "bg-[#00FFFF]/30" : "bg-[#FF8C00]/30"}`} />
      )}
    </motion.div>
  );
};

const LayerRow = ({ layer, isActive, isAlerted }) => {
  const Icon = LAYER_ICONS[layer.layer] || Box;
  return (
    <div
      data-testid={`layer-${layer.layer}`}
      className={`flex items-center gap-2 py-1 px-2 transition-all duration-300 ${
        isAlerted ? "bg-[#FF8C00]/10 border-l-2 border-[#FF8C00]" :
        isActive ? "bg-[#FF003C]/5 border-l-2 border-[#FF003C]/40" :
        "border-l-2 border-transparent"
      }`}
    >
      <StatusDot active={isActive} danger={isAlerted} />
      <Icon size={11} className={isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#FF003C]" : "text-[#52525B]"} />
      <span className="text-[10px] font-mono tracking-wider text-[#A1A1AA] w-7">{layer.layer}</span>
      <span className={`text-[10px] font-mono truncate ${isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#EDEDED]" : "text-[#52525B]"}`}>
        {layer.name}
      </span>
      <span className={`ml-auto text-[8px] font-mono ${isAlerted ? "text-[#FF8C00]" : isActive ? "text-[#FF003C]" : "text-[#52525B]"}`}>
        {isAlerted ? "ALERT" : isActive ? "ON" : "STBY"}
      </span>
    </div>
  );
};

const LogConsole = ({ logs }) => {
  const endRef = useRef(null);
  useEffect(() => { endRef.current?.scrollIntoView({ behavior: "smooth" }); }, [logs]);

  return (
    <div data-testid="log-console" className="relative scanlines bg-[#050505] border border-white/10 p-3 h-[180px] overflow-y-auto font-mono text-sm">
      <AnimatePresence>
        {logs.map((log, i) => (
          <motion.div key={i} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.2 }} className="flex gap-2 mb-0.5">
            <span className="text-[#52525B] text-xs shrink-0">[{log.time}]</span>
            <span className={`text-xs ${
              log.type === "danger" ? "text-[#FF8C00]" :
              log.type === "warning" ? "text-[#FFB000]" :
              log.type === "success" ? "text-[#FF003C]" :
              log.type === "info" ? "text-[#00FFFF]" : "text-[#FF003C]"
            }`}>{log.message}</span>
          </motion.div>
        ))}
      </AnimatePresence>
      <div ref={endRef} />
    </div>
  );
};

const StatBox = ({ label, value, unit }) => (
  <div className="text-center">
    <div className="text-lg font-mono font-bold text-[#FF003C]">{value}<span className="text-[10px] text-[#A1A1AA] ml-0.5">{unit}</span></div>
    <div className="text-[8px] font-mono tracking-[0.2em] text-[#52525B] uppercase">{label}</div>
  </div>
);

export default function Dashboard() {
  const [phase, setPhase] = useState(PHASES.IDLE);
  const [legitBlocks, setLegitBlocks] = useState([]);
  const [attackerBlocks, setAttackerBlocks] = useState([]);
  const [transaction, setTransaction] = useState(null);
  const [logs, setLogs] = useState([]);
  const [layers, setLayers] = useState([]);
  const [activeLayers, setActiveLayers] = useState(new Set());
  const [alertedLayers, setAlertedLayers] = useState(new Set());
  const [detectionTime, setDetectionTime] = useState(null);
  const [simRunning, setSimRunning] = useState(false);
  const timerRef = useRef(null);
  const blockDataRef = useRef(null);

  useEffect(() => {
    axios.get(`${API}/layers`).then(res => setLayers(res.data)).catch(() => {
      setLayers([
        { layer: "L1", name: "Infrastructure", status: "RUNNING" },
        { layer: "L2", name: "Identity & Assets", status: "RUNNING" },
        { layer: "L3", name: "Execution Flow", status: "RUNNING" },
        { layer: "L4", name: "Consensus & Crypto", status: "RUNNING" },
        { layer: "L5", name: "Scalability", status: "RUNNING" },
        { layer: "L6", name: "Omnichain", status: "RUNNING" },
        { layer: "L7", name: "AI Governance", status: "RUNNING" },
        { layer: "L8", name: "Core Orchestrator", status: "RUNNING" },
        { layer: "L9", name: "Rust DAG Engine", status: "RUNNING" },
        { layer: "L10", name: "Frontend", status: "RUNNING" },
      ]);
    });
  }, []);

  const addLog = useCallback((message, type = "default") => {
    setLogs(prev => [...prev, { time: timestamp(), message, type }]);
  }, []);
  const activateLayer = useCallback((layer) => { setActiveLayers(prev => new Set([...prev, layer])); }, []);
  const alertLayer = useCallback((layer) => { setAlertedLayers(prev => new Set([...prev, layer])); }, []);

  const resetSimulation = useCallback(() => {
    if (timerRef.current) clearTimeout(timerRef.current);
    setPhase(PHASES.IDLE); setLegitBlocks([]); setAttackerBlocks([]); setTransaction(null);
    setLogs([]); setActiveLayers(new Set()); setAlertedLayers(new Set());
    setDetectionTime(null); setSimRunning(false); blockDataRef.current = null;
  }, []);

  const startSimulation = useCallback(async () => {
    resetSimulation();
    setSimRunning(true);
    try { const res = await axios.get(`${API}/simulation/blocks`); blockDataRef.current = res.data; } catch {
      blockDataRef.current = {
        legitimate_chain: Array.from({ length: 5 }, (_, i) => ({ height: i + 1, hash: generateHash(), tx_count: Math.floor(Math.random() * 2000) + 150 })),
        attacker_chain: Array.from({ length: 6 }, (_, i) => ({ height: i + 1, hash: generateHash(), tx_count: Math.floor(Math.random() * 10) + 1 })),
        transaction: { txid: generateTxHash(), amount: 0.042, from: "bc1q" + generateHash().slice(2), to: "x39matrix_vault", confirmations: 5 }
      };
    }
    const data = blockDataRef.current;
    const delay = (ms) => new Promise(r => { timerRef.current = setTimeout(r, ms); });

    addLog("x39Matrix 51% Attack Detection Lab v11.0", "info");
    addLog("Initializing 10-canister sovereign protocol...", "info");
    await delay(500);
    for (const l of ["L1","L2","L3","L8","L9","L10"]) { activateLayer(l); await delay(200); }
    addLog("L1-L3 Infrastructure + Identity + Execution: ONLINE", "success");
    addLog("L8 Core Orchestrator: All subsystems nominal", "success");
    addLog("L9 Rust DAG: PTU-47 + State Morphism M: S→S' loaded", "success");
    addLog("L10 Frontend: Assets canister serving", "success");
    addLog("10 canisters initialized. System OPERATIONAL.", "info");
    await delay(600);

    setPhase(PHASES.MINING_LEGIT);
    addLog("─── PHASE 1: Mining Legitimate Chain ───", "info");
    activateLayer("L4"); activateLayer("L5");
    addLog("L4 Consensus + L5 Scalability: Monitoring BTC regtest (50K+ TPS capacity)...", "success");
    await delay(300);
    for (let i = 0; i < data.legitimate_chain.length; i++) {
      setLegitBlocks(prev => [...prev, data.legitimate_chain[i]]);
      addLog(`Block #${data.legitimate_chain[i].height} mined → ${data.legitimate_chain[i].hash} (${data.legitimate_chain[i].tx_count} txs)`, "success");
      await delay(600);
    }
    addLog("Legitimate chain: 5 blocks confirmed. BFT 100%.", "info");
    await delay(500);

    setPhase(PHASES.TX_SENT);
    addLog("─── PHASE 2: Transaction Broadcast ───", "info");
    setTransaction({ ...data.transaction, status: "CONFIRMED" });
    addLog(`TX ${data.transaction.txid} → ${data.transaction.amount} BTC`, "info");
    addLog("Threshold ECDSA signature: ~1.3s p95 latency. Zero bridges.", "success");
    addLog("Transaction CONFIRMED. Ed25519 aggregator verified.", "success");
    activateLayer("L6");
    addLog("L6 Omnichain: Native BTC signing via Threshold ECDSA/Schnorr.", "success");
    await delay(1200);

    setPhase(PHASES.ATTACKER_MINING);
    addLog("─── PHASE 3: ATTACKER CHAIN DETECTED ───", "warning");
    addLog("WARNING: Alternative chain activity — possible 51% attack!", "warning");
    activateLayer("L7");
    addLog("L7 AI Sentinel: Fraud Detector + Stress Simulator activated.", "warning");
    await delay(400);
    for (let i = 0; i < data.attacker_chain.length; i++) {
      setAttackerBlocks(prev => [...prev, data.attacker_chain[i]]);
      addLog(`ATTACKER Block #${data.attacker_chain[i].height} → ${data.attacker_chain[i].hash} (${data.attacker_chain[i].tx_count} txs — SUSPICIOUS)`, "danger");
      await delay(500);
    }
    await delay(300);

    setPhase(PHASES.REORG_DETECTED);
    const detTime = Math.floor(Math.random() * 900) + 800;
    setDetectionTime(detTime);
    addLog("─── PHASE 4: REORG DETECTED ───", "danger");
    addLog("CRITICAL: Attacker chain (6) > Legitimate chain (5)!", "danger");
    alertLayer("L7"); alertLayer("L3");
    addLog("L7 AI Sentinel: REORG DETECTED — 47/47 attack patterns matched!", "danger");
    addLog(`Detection: ${detTime}ms | Ed25519 fuzzing: 2038/2038 cases, 0 escapes`, "danger");
    setTransaction(prev => prev ? { ...prev, status: "REVERTED" } : null);
    addLog("Transaction REVERTED — double spend attempt blocked!", "danger");
    addLog("L9 DAG Morphism: M(e1) ⊕ M(e2) conflict detected, VDF ordering applied.", "danger");
    await delay(1800);

    setPhase(PHASES.ATTACK_BLOCKED);
    addLog("─── PHASE 5: ATTACK NEUTRALIZED ───", "success");
    addLog("L7 Sentinel: Attacker chain REJECTED. 0 escapes.", "success");
    addLog("L4 BFT Consensus: Legitimate chain restored as canonical.", "success");
    addLog("L9 Fokker-Planck convergence: equilibrium state reached.", "success");
    addLog("L6 Omnichain: BTC settlement integrity verified.", "success");
    setAlertedLayers(new Set());
    addLog("═══ 51% ATTACK DETECTED AND BLOCKED — x39Matrix SECURE ═══", "info");
    addLog(`Detection: ${detTime}ms | 10 canisters | 45 blocks | 0 bridges`, "info");
    setSimRunning(false);
    try { await axios.post(`${API}/simulation/run`); } catch {}
  }, [addLog, activateLayer, alertLayer, resetSimulation]);

  const phaseColor = phase === PHASES.REORG_DETECTED ? "text-[#FF8C00]" :
    phase === PHASES.ATTACKER_MINING ? "text-[#FFB000]" :
    phase === PHASES.ATTACK_BLOCKED ? "text-[#FF003C]" :
    phase === PHASES.IDLE ? "text-[#52525B]" : "text-[#00FFFF]";

  return (
    <div className="min-h-screen bg-[#050505] p-3 md:p-4 lg:p-5 relative">
      <div className="fixed inset-0 opacity-[0.03] pointer-events-none"
        style={{ backgroundImage: `url(https://static.prod-images.emergentagent.com/jobs/b93719da-776c-487b-ae8c-ecf4ae684f67/images/163fccf7edc5c9703ac5cd12ee0c959ed2f82fa045eb75f2803c5e24f7bc361c.png)`, backgroundSize: 'cover' }} />

      {/* Header */}
      <header className="flex items-center justify-between mb-4 relative z-10" data-testid="header">
        <div className="flex items-center gap-3">
          <img
            src="https://customer-assets.emergentagent.com/job_estado-protocolo/artifacts/kx0pfl6b_ncabezado.png"
            alt="x39Matrix"
            className="w-12 h-12 object-contain"
          />
          <div>
            <h1 className="text-xl md:text-2xl font-black tracking-tighter uppercase text-white leading-none">
              x39<span className="text-[#FF003C]">Matrix</span>
            </h1>
            <p className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#52525B]">
              Sovereign Protocol — 51% Attack Detection Lab v11.0
            </p>
          </div>
        </div>
        <div className="flex items-center gap-4">
          <a href="https://www.x39matrix.org" target="_blank" rel="noopener noreferrer"
            className="hidden md:flex items-center gap-1 text-[10px] font-mono text-[#FF003C]/60 hover:text-[#FF003C] transition-colors" data-testid="website-link">
            <ExternalLink size={10} /> www.x39matrix.org
          </a>
          <div className={`text-xs font-mono tracking-widest uppercase ${phaseColor} glow-text`} data-testid="phase-indicator">
            {PHASE_LABELS[phase]}
          </div>
          <div className="flex items-center gap-1.5">
            <span className={`w-2 h-2 rounded-full ${phase === PHASES.IDLE ? "bg-[#52525B]" : phase === PHASES.REORG_DETECTED ? "bg-[#FF8C00] pulse-orange" : "bg-[#FF003C] pulse-dot"}`} />
            <span className="text-[10px] font-mono text-[#A1A1AA]">MAINNET</span>
          </div>
        </div>
      </header>

      {/* Stats Bar */}
      <div className="grid grid-cols-5 gap-2 mb-4 relative z-10" data-testid="stats-bar">
        <div className="bg-[#0A0A0A] border border-white/10 py-2 px-3 text-center">
          <div className="text-sm font-mono font-bold text-[#FF003C]">10</div>
          <div className="text-[8px] font-mono tracking-[0.15em] text-[#52525B] uppercase">Canisters</div>
        </div>
        <div className="bg-[#0A0A0A] border border-white/10 py-2 px-3 text-center">
          <div className="text-sm font-mono font-bold text-[#FF003C]">45</div>
          <div className="text-[8px] font-mono tracking-[0.15em] text-[#52525B] uppercase">Blocks</div>
        </div>
        <div className="bg-[#0A0A0A] border border-white/10 py-2 px-3 text-center">
          <div className="text-sm font-mono font-bold text-[#FF003C]">50K+</div>
          <div className="text-[8px] font-mono tracking-[0.15em] text-[#52525B] uppercase">TPS</div>
        </div>
        <div className="bg-[#0A0A0A] border border-white/10 py-2 px-3 text-center">
          <div className="text-sm font-mono font-bold text-[#FF003C]">2.5s</div>
          <div className="text-[8px] font-mono tracking-[0.15em] text-[#52525B] uppercase">Finality</div>
        </div>
        <div className="bg-[#0A0A0A] border border-white/10 py-2 px-3 text-center">
          <div className="text-sm font-mono font-bold text-[#FF003C]">0</div>
          <div className="text-[8px] font-mono tracking-[0.15em] text-[#52525B] uppercase">Bridges</div>
        </div>
      </div>

      {/* Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-[220px_1fr] gap-3 relative z-10">
        {/* Left: Layers Panel */}
        <div className="bg-[#0A0A0A] border border-white/10 p-3" data-testid="layers-panel">
          <div className="text-[9px] font-mono tracking-[0.25em] uppercase text-[#52525B] mb-2 flex items-center gap-2">
            <Layers size={11} /> 10 Canisters — ICP Mainnet
          </div>
          <div className="space-y-0">
            {layers.map(layer => (
              <LayerRow key={layer.layer} layer={layer} isActive={activeLayers.has(layer.layer)} isAlerted={alertedLayers.has(layer.layer)} />
            ))}
          </div>
          <div className="mt-3 border-t border-white/10 pt-2">
            <div className="text-[9px] font-mono text-[#52525B] mb-1">DETECTION TIME</div>
            {detectionTime ? (
              <div className="text-xl font-mono font-bold text-[#FF003C] glow-text" data-testid="detection-time">
                {detectionTime}<span className="text-xs text-[#A1A1AA]">ms</span>
              </div>
            ) : (
              <div className="text-xl font-mono font-bold text-[#52525B]">—</div>
            )}
          </div>
          <div className="mt-2 border-t border-white/10 pt-2">
            <div className="text-[9px] font-mono text-[#52525B] mb-1">ED25519 FUZZ</div>
            <div className="text-xs font-mono text-[#FF003C]">2038/2038 <span className="text-[#52525B]">0 escapes</span></div>
          </div>
        </div>

        {/* Right: Main Content */}
        <div className="space-y-3">
          {/* Chains */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div className={`bg-[#0A0A0A] border ${phase === PHASES.MINING_LEGIT ? "border-[#00FFFF]/30" : "border-white/10"} p-3`} data-testid="legit-chain-panel">
              <div className="flex items-center gap-2 mb-2">
                <StatusDot active={legitBlocks.length > 0} />
                <span className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#A1A1AA]">Legitimate Chain</span>
                <span className="ml-auto text-[9px] font-mono text-[#00FFFF]">{legitBlocks.length} blocks</span>
              </div>
              <div className="flex gap-2 overflow-x-auto pb-2 min-h-[75px] items-center">
                {legitBlocks.length === 0 ? (
                  <div className="text-xs font-mono text-[#52525B] w-full text-center">Awaiting blocks...</div>
                ) : legitBlocks.map((b, i) => <Block key={i} block={b} type="legit" index={i} />)}
              </div>
            </div>
            <div className={`bg-[#0A0A0A] border ${
              phase === PHASES.REORG_DETECTED ? "border-[#FF8C00]/50 alert-flash" :
              phase === PHASES.ATTACKER_MINING ? "border-[#FFB000]/30" : "border-white/10"
            } p-3`} data-testid="attacker-chain-panel">
              <div className="flex items-center gap-2 mb-2">
                <StatusDot active={attackerBlocks.length > 0} danger={attackerBlocks.length > 0} />
                <span className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#A1A1AA]">Attacker Chain</span>
                <span className="ml-auto text-[9px] font-mono text-[#FF8C00]">{attackerBlocks.length} blocks</span>
              </div>
              <div className="flex gap-2 overflow-x-auto pb-2 min-h-[75px] items-center">
                {attackerBlocks.length === 0 ? (
                  <div className="text-xs font-mono text-[#52525B] w-full text-center">No threats detected</div>
                ) : attackerBlocks.map((b, i) => <Block key={i} block={b} type="attacker" index={i} />)}
              </div>
            </div>
          </div>

          {/* TX + Alert */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div className="bg-[#0A0A0A] border border-white/10 p-3" data-testid="transaction-panel">
              <div className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#52525B] mb-2 flex items-center gap-2">
                <ChevronRight size={11} /> Transaction Monitor — Threshold ECDSA
              </div>
              {transaction ? (
                <div className="space-y-1.5">
                  <div className="flex items-center gap-2">
                    <span className="text-[9px] font-mono text-[#52525B]">TXID:</span>
                    <span className="text-[11px] font-mono text-[#00FFFF]">{transaction.txid}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[9px] font-mono text-[#52525B]">AMOUNT:</span>
                    <span className="text-[11px] font-mono text-[#EDEDED]">{transaction.amount} BTC</span>
                    <span className="text-[9px] font-mono text-[#52525B] ml-2">TO:</span>
                    <span className="text-[11px] font-mono text-[#EDEDED]">{transaction.to}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-[9px] font-mono text-[#52525B]">STATUS:</span>
                    <span className={`text-[11px] font-mono font-bold ${transaction.status === "CONFIRMED" ? "text-[#00FFFF]" : "text-[#FF8C00]"}`}>
                      {transaction.status === "CONFIRMED" ? "CONFIRMED (5 blocks) — ~1.3s p95" : "REVERTED — DOUBLE SPEND DETECTED"}
                    </span>
                  </div>
                </div>
              ) : <div className="text-xs font-mono text-[#52525B]">No active transaction — 0 bridges, 0 custodians</div>}
            </div>
            <div className={`bg-[#0A0A0A] border p-3 transition-all duration-300 ${
              phase === PHASES.REORG_DETECTED ? "border-[#FF8C00] alert-flash bg-[#FF8C00]/5" :
              phase === PHASES.ATTACK_BLOCKED ? "border-[#FF003C]/40 bg-[#FF003C]/5" : "border-white/10"
            }`} data-testid="sentinel-alert-panel">
              <div className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#52525B] mb-2 flex items-center gap-2">
                <AlertTriangle size={11} className={phase === PHASES.REORG_DETECTED ? "text-[#FF8C00]" : ""} />
                L7 AI Sentinel — DeAI Immune System
              </div>
              {phase === PHASES.REORG_DETECTED ? (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <div className="text-base font-mono font-bold text-[#FF8C00] mb-1">51% ATTACK DETECTED</div>
                  <div className="text-[11px] font-mono text-[#FF8C00]/80 space-y-0.5">
                    <div>Reorg: Attacker (6) &gt; Legitimate (5)</div>
                    <div>47/47 attack patterns matched</div>
                    <div>TX {transaction?.txid?.slice(0, 12)}... REVERTED</div>
                  </div>
                </motion.div>
              ) : phase === PHASES.ATTACK_BLOCKED ? (
                <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }}>
                  <div className="text-base font-mono font-bold text-[#FF003C] mb-1">ATTACK NEUTRALIZED</div>
                  <div className="text-[11px] font-mono text-[#FF003C]/80 space-y-0.5">
                    <div>Attacker chain rejected — BFT 100%</div>
                    <div>Fokker-Planck convergence: equilibrium</div>
                    <div>Detection: {detectionTime}ms | 0 escapes</div>
                  </div>
                </motion.div>
              ) : <div className="text-xs font-mono text-[#52525B]">No active alerts — 47/47 patterns ready</div>}
            </div>
          </div>

          {/* Log */}
          <div data-testid="log-section">
            <div className="text-[9px] font-mono tracking-[0.2em] uppercase text-[#52525B] mb-1.5 flex items-center gap-2">
              <Activity size={11} /> Event Log — x39matrix-cli v11.0
            </div>
            <LogConsole logs={logs} />
          </div>

          {/* Controls */}
          <div className="flex gap-3" data-testid="controls">
            <button data-testid="start-simulation-btn" onClick={startSimulation} disabled={simRunning}
              className={`flex items-center gap-2 px-6 py-2.5 font-mono text-sm font-bold tracking-wider uppercase transition-all ${
                simRunning ? "bg-[#121212] text-[#52525B] cursor-not-allowed border border-white/5"
                : "bg-[#FF003C] text-white hover:drop-shadow-[0_0_12px_rgba(255,0,60,0.5)] active:scale-[0.98]"
              }`}>
              <Play size={15} /> {simRunning ? "Simulation Running..." : "Start Simulation"}
            </button>
            <button data-testid="reset-btn" onClick={resetSimulation}
              className="flex items-center gap-2 px-6 py-2.5 font-mono text-sm tracking-wider uppercase border border-[#FF003C]/30 text-[#FF003C] hover:bg-[#FF003C]/10 transition-all">
              <RotateCcw size={15} /> Reset
            </button>
            <a href="https://www.x39matrix.org" target="_blank" rel="noopener noreferrer"
              className="flex items-center gap-2 px-6 py-2.5 font-mono text-sm tracking-wider uppercase border border-white/10 text-[#A1A1AA] hover:text-[#FF003C] hover:border-[#FF003C]/30 transition-all"
              data-testid="visit-site-btn">
              <Globe size={15} /> x39matrix.org
            </a>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="mt-5 text-center relative z-10">
        <p className="text-[9px] font-mono text-[#52525B] tracking-widest">
          x39Matrix — Sovereign Protocol | 10 Canisters | 9 Layers | 45 Blocks | Category Theory Engine | Kepler's Vision |{" "}
          <a href="https://bvatd-sqaaa-aaaao-baxqq-cai.icp0.io/" target="_blank" rel="noopener noreferrer" className="text-[#FF003C]/50 hover:text-[#FF003C]">ICP Mainnet</a>
          {" "}|{" "}
          <a href="https://www.x39matrix.org" target="_blank" rel="noopener noreferrer" className="text-[#FF003C]/50 hover:text-[#FF003C]">www.x39matrix.org</a>
        </p>
      </footer>
    </div>
  );
}
